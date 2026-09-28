#ifndef DEMO_BLOCKCHAIN_H
#define DEMO_BLOCKCHAIN_H

#include <stdint.h>
#include <stddef.h>

#define HASH_SIZE 32
#define ADDRESS_SIZE 32
#define MAX_TXS 256
#define MAX_BLOCKS 64
#define HEADER_PREFIX_SIZE 80 /* index(8)+ts(8)+prev(32)+merkle(32) */
#define MINING_REWARD 50ULL
#define GENESIS_TS 1700000000LL

typedef uint8_t Hash[HASH_SIZE];
typedef uint8_t Address[ADDRESS_SIZE];

typedef struct {
    int has_from; /* 0 = coinbase */
    Address from;
    Address to;
    uint64_t amount;
    uint64_t nonce;
} Transaction;

typedef struct {
    uint64_t index;
    int64_t timestamp;
    Hash prev_hash;
    Transaction txs[MAX_TXS];
    size_t tx_count;
    uint64_t nonce;
    Hash hash;
} Block;

typedef struct {
    Block blocks[MAX_BLOCKS];
    size_t block_count;
    uint32_t difficulty;
    uint64_t mining_reward;
} Blockchain;

typedef struct {
    uint32_t difficulty;
    uint32_t blocks;
    uint32_t txs_per_block;
} BenchArgs;

typedef struct {
    uint64_t total_ms;
    uint64_t hashes;
    double hashes_per_sec;
} BenchResult;

extern const Address BENCH_MINER_ADDRESS;

uint32_t leading_zero_bits(const Hash hash);
void tx_hash(const Transaction *tx, Hash out);
void merkle_root(const Transaction *txs, size_t n, Hash out);
void block_header_prefix(const Block *b, uint8_t prefix[HEADER_PREFIX_SIZE]);
uint64_t block_mine(Block *b, uint32_t difficulty);

void blockchain_init(Blockchain *bc, uint32_t difficulty, int64_t genesis_ts);

void bench_run(const BenchArgs *args, BenchResult *out);
void bench_print_json(const BenchArgs *args, const BenchResult *r);

void demo_run(uint32_t difficulty);

void sha256_bytes(const uint8_t *data, size_t len, Hash out);

/* Optional asm hot-path (defined in asm build as mine_pow_asm). */
#ifdef DEMO_USE_ASM_MINE
uint64_t mine_pow_asm(const uint8_t prefix[HEADER_PREFIX_SIZE], uint32_t difficulty,
                      Hash out_hash, uint64_t *out_nonce);
#endif

#endif