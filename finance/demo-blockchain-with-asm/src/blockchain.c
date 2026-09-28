#include "blockchain.h"
#include "sha256.h"
#include <stdio.h>
#include <string.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
static double now_secs(void) {
    static LARGE_INTEGER freq;
    static int init_done;
    LARGE_INTEGER c;
    if (!init_done) { QueryPerformanceFrequency(&freq); init_done = 1; }
    QueryPerformanceCounter(&c);
    return (double)c.QuadPart / (double)freq.QuadPart;
}
#else
#include <time.h>
static double now_secs(void) {
    struct timespec ts;
    timespec_get(&ts, TIME_UTC);
    return (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}
#endif

const Address BENCH_MINER_ADDRESS = {
    0xfd,0x17,0x24,0x38,0x5a,0xa0,0xc7,0x5b,0x64,0xfb,0x78,0xcd,0x60,0x2f,0xa1,0xd9,
    0x91,0xfd,0xeb,0xf7,0x6b,0x13,0xc5,0x8e,0xd7,0x02,0xea,0xc8,0x35,0xe9,0xf6,0x18
};

void sha256_bytes(const uint8_t *data, size_t len, Hash out) {
    sha256(data, len, out);
}

static void write_u64_le(uint8_t *dst, uint64_t v) {
    for (int i = 0; i < 8; i++) dst[i] = (uint8_t)((v >> (8 * i)) & 0xff);
}

static void write_i64_le(uint8_t *dst, int64_t v) {
    write_u64_le(dst, (uint64_t)v);
}

uint32_t leading_zero_bits(const Hash hash) {
    uint32_t count = 0;
    for (int i = 0; i < HASH_SIZE; i++) {
        if (hash[i] == 0) {
            count += 8;
        } else {
            uint8_t b = hash[i];
            uint32_t lz = 0;
            while ((b & 0x80) == 0) { lz++; b = (uint8_t)(b << 1); }
            count += lz;
            break;
        }
    }
    return count;
}

void tx_hash(const Transaction *tx, Hash out) {
    SHA256_CTX ctx;
    sha256_init(&ctx);
    if (!tx->has_from) {
        uint8_t z = 0;
        sha256_update(&ctx, &z, 1);
    } else {
        uint8_t one = 1;
        sha256_update(&ctx, &one, 1);
        sha256_update(&ctx, tx->from, ADDRESS_SIZE);
    }
    sha256_update(&ctx, tx->to, ADDRESS_SIZE);
    uint8_t buf[8];
    write_u64_le(buf, tx->amount);
    sha256_update(&ctx, buf, 8);
    write_u64_le(buf, tx->nonce);
    sha256_update(&ctx, buf, 8);
    sha256_final(&ctx, out);
}

void merkle_root(const Transaction *txs, size_t n, Hash out) {
    if (n == 0) {
        memset(out, 0, HASH_SIZE);
        return;
    }
    Hash level[MAX_TXS];
    size_t len = n;
    for (size_t i = 0; i < n; i++) tx_hash(&txs[i], level[i]);
    while (len > 1) {
        size_t next_len = 0;
        for (size_t j = 0; j < len; j += 2) {
            const uint8_t *left = level[j];
            const uint8_t *right = (j + 1 < len) ? level[j + 1] : level[j];
            SHA256_CTX ctx;
            sha256_init(&ctx);
            sha256_update(&ctx, left, HASH_SIZE);
            sha256_update(&ctx, right, HASH_SIZE);
            sha256_final(&ctx, level[next_len]);
            next_len++;
        }
        len = next_len;
    }
    memcpy(out, level[0], HASH_SIZE);
}

void block_header_prefix(const Block *b, uint8_t prefix[HEADER_PREFIX_SIZE]) {
    Hash merkle;
    merkle_root(b->txs, b->tx_count, merkle);
    write_u64_le(prefix + 0, b->index);
    write_i64_le(prefix + 8, b->timestamp);
    memcpy(prefix + 16, b->prev_hash, HASH_SIZE);
    memcpy(prefix + 48, merkle, HASH_SIZE);
}

uint64_t block_mine(Block *b, uint32_t difficulty) {
    uint8_t prefix[HEADER_PREFIX_SIZE];
    block_header_prefix(b, prefix);

#ifdef DEMO_USE_ASM_MINE
    return mine_pow_asm(prefix, difficulty, b->hash, &b->nonce);
#else
    /* Match Rust/Zig: absorb fixed header once, then per-nonce only. */
    SHA256_CTX prefix_ctx;
    sha256_init(&prefix_ctx);
    sha256_update(&prefix_ctx, prefix, HEADER_PREFIX_SIZE);

    b->nonce = 0;
    uint8_t nonce_le[8];
    for (;;) {
        SHA256_CTX ctx = prefix_ctx; /* clone midstate */
        write_u64_le(nonce_le, b->nonce);
        sha256_update(&ctx, nonce_le, 8);
        Hash candidate;
        sha256_final(&ctx, candidate);
        if (leading_zero_bits(candidate) >= difficulty) {
            memcpy(b->hash, candidate, HASH_SIZE);
            return b->nonce + 1;
        }
        b->nonce++;
    }
#endif
}

void blockchain_init(Blockchain *bc, uint32_t difficulty, int64_t genesis_ts) {
    memset(bc, 0, sizeof(*bc));
    bc->difficulty = difficulty;
    bc->mining_reward = MINING_REWARD;
    Block *g = &bc->blocks[0];
    g->index = 0;
    g->timestamp = genesis_ts;
    memset(g->prev_hash, 0, HASH_SIZE);
    g->tx_count = 0;
    block_mine(g, difficulty);
    bc->block_count = 1;
}

static void make_coinbase(Transaction *tx, const Address to, uint64_t amount, uint64_t block_index) {
    memset(tx, 0, sizeof(*tx));
    tx->has_from = 0;
    memcpy(tx->to, to, ADDRESS_SIZE);
    tx->amount = amount;
    tx->nonce = block_index;
}

void bench_run(const BenchArgs *args, BenchResult *out) {
    Blockchain bc;
    blockchain_init(&bc, args->difficulty, GENESIS_TS);

    uint64_t hashes = 0;
    double t0 = now_secs();

    for (uint32_t i = 0; i < args->blocks; i++) {
        if (bc.block_count >= MAX_BLOCKS) break;
        Block *b = &bc.blocks[bc.block_count];
        memset(b, 0, sizeof(*b));
        b->index = (uint64_t)bc.block_count;
        b->timestamp = GENESIS_TS + (int64_t)i + 1;
        memcpy(b->prev_hash, bc.blocks[bc.block_count - 1].hash, HASH_SIZE);

        make_coinbase(&b->txs[0], BENCH_MINER_ADDRESS, bc.mining_reward, b->index);
        b->tx_count = 1;

        /* txs_per_block > 0: unsigned dummy txs (not comparable to Rust/Zig). */
        for (uint32_t t = 0; t < args->txs_per_block && b->tx_count < MAX_TXS; t++) {
            Transaction *tx = &b->txs[b->tx_count++];
            memset(tx, 0, sizeof(*tx));
            tx->has_from = 1;
            memcpy(tx->from, BENCH_MINER_ADDRESS, ADDRESS_SIZE);
            tx->to[0] = 8;
            tx->amount = 1;
            tx->nonce = t;
        }

        hashes += block_mine(b, args->difficulty);
        bc.block_count++;
    }

    double elapsed = now_secs() - t0;
    out->total_ms = (uint64_t)(elapsed * 1000.0);
    out->hashes = hashes;
    out->hashes_per_sec = (elapsed > 0.0) ? ((double)hashes / elapsed) : 0.0;
}

void bench_print_json(const BenchArgs *args, const BenchResult *r) {
#ifdef DEMO_IMPL_NAME
    const char *impl = DEMO_IMPL_NAME;
#else
    const char *impl = "c";
#endif
    printf(
        "{\"impl\":\"%s\",\"difficulty\":%u,\"difficulty_unit\":\"bits\","
        "\"blocks\":%u,\"txs_per_block\":%u,\"total_ms\":%llu,\"hashes\":%llu,"
        "\"hashes_per_sec\":%.6f}\n",
        impl,
        (unsigned)args->difficulty,
        (unsigned)args->blocks,
        (unsigned)args->txs_per_block,
        (unsigned long long)r->total_ms,
        (unsigned long long)r->hashes,
        r->hashes_per_sec);
}

static void hex32(const Hash h, char out[65]) {
    static const char *hexd = "0123456789abcdef";
    for (int i = 0; i < 32; i++) {
        out[i * 2] = hexd[h[i] >> 4];
        out[i * 2 + 1] = hexd[h[i] & 0xf];
    }
    out[64] = 0;
}

void demo_run(uint32_t difficulty) {
    Blockchain bc;
    blockchain_init(&bc, difficulty, GENESIS_TS);
    printf("=== Blockchain em C ===\n");
    printf("Dificuldade: %u bits | Recompensa: %llu\n\n",
           (unsigned)difficulty, (unsigned long long)MINING_REWARD);

    for (uint32_t i = 0; i < 3; i++) {
        Block *b = &bc.blocks[bc.block_count];
        memset(b, 0, sizeof(*b));
        b->index = (uint64_t)bc.block_count;
        b->timestamp = GENESIS_TS + (int64_t)i + 1;
        memcpy(b->prev_hash, bc.blocks[bc.block_count - 1].hash, HASH_SIZE);
        make_coinbase(&b->txs[0], BENCH_MINER_ADDRESS, MINING_REWARD, b->index);
        b->tx_count = 1;
        double t0 = now_secs();
        uint64_t attempts = block_mine(b, difficulty);
        double ms = (now_secs() - t0) * 1000.0;
        char hx[65];
        hex32(b->hash, hx);
        printf("  bloco #%llu minerado em %.0f ms (nonce %llu, attempts %llu)\n",
               (unsigned long long)b->index, ms,
               (unsigned long long)b->nonce, (unsigned long long)attempts);
        printf("      hash %s\n", hx);
        bc.block_count++;
    }
    printf("\nCadeia OK (%zu blocos). Use `bench` para medir PoW.\n", bc.block_count);
}