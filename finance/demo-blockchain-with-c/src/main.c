#include "blockchain.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int parse_u32(const char *s, uint32_t *out) {
    char *end = NULL;
    unsigned long v = strtoul(s, &end, 10);
    if (!s[0] || (end && *end)) return 0;
    *out = (uint32_t)v;
    return 1;
}

static int run_bench(int argc, char **argv) {
    BenchArgs args = { .difficulty = 16, .blocks = 5, .txs_per_block = 0 };
    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], "--difficulty") == 0 && i + 1 < argc) {
            if (!parse_u32(argv[++i], &args.difficulty)) return 2;
        } else if (strcmp(argv[i], "--blocks") == 0 && i + 1 < argc) {
            if (!parse_u32(argv[++i], &args.blocks)) return 2;
        } else if (strcmp(argv[i], "--txs-per-block") == 0 && i + 1 < argc) {
            if (!parse_u32(argv[++i], &args.txs_per_block)) return 2;
        } else {
            fprintf(stderr, "flag desconhecida: %s\n", argv[i]);
            return 2;
        }
    }
    BenchResult r;
    bench_run(&args, &r);
    bench_print_json(&args, &r);
    return 0;
}

static int run_tests(void) {
    int fail = 0;
    Hash z;
    memset(z, 0, sizeof z);
    if (leading_zero_bits(z) != 256) {
        fprintf(stderr, "FAIL leading zeros all0\n");
        fail++;
    }

    Hash h;
    memset(h, 0, sizeof h);
    h[1] = 0x10;
    if (leading_zero_bits(h) != 11) {
        fprintf(stderr, "FAIL leading zeros partial got %u\n", leading_zero_bits(h));
        fail++;
    }

    sha256_bytes((const uint8_t *)"", 0, h);
    static const uint8_t empty_sum[32] = {
        0xe3,0xb0,0xc4,0x42,0x98,0xfc,0x1c,0x14,0x9a,0xfb,0xf4,0xc8,0x99,0x6f,0xb9,0x24,
        0x27,0xae,0x41,0xe4,0x64,0x9b,0x93,0x4c,0xa4,0x95,0x99,0x1b,0x78,0x52,0xb8,0x55
    };
    if (memcmp(h, empty_sum, 32) != 0) {
        fprintf(stderr, "FAIL sha256 empty\n");
        fail++;
    }

    Hash merkle;
    merkle_root(NULL, 0, merkle);
    if (memcmp(merkle, z, 32) != 0) {
        fprintf(stderr, "FAIL empty merkle\n");
        fail++;
    }

    Transaction tx;
    memset(&tx, 0, sizeof tx);
    tx.has_from = 0;
    memcpy(tx.to, BENCH_MINER_ADDRESS, 32);
    tx.amount = 50;
    tx.nonce = 1;

    Block b;
    memset(&b, 0, sizeof b);
    b.index = 1;
    b.timestamp = GENESIS_TS + 1;
    b.txs[0] = tx;
    b.tx_count = 1;
    uint64_t attempts = block_mine(&b, 8);
    if (attempts == 0 || leading_zero_bits(b.hash) < 8) {
        fprintf(stderr, "FAIL mine bits\n");
        fail++;
    }

    BenchArgs ba = { .difficulty = 4, .blocks = 1, .txs_per_block = 0 };
    BenchResult br;
    bench_run(&ba, &br);
    if (br.hashes == 0) {
        fprintf(stderr, "FAIL bench smoke\n");
        fail++;
    }

    if (fail == 0) printf("ALL TESTS PASSED\n");
    else printf("%d TEST(S) FAILED\n", fail);
    return fail ? 1 : 0;
}

int main(int argc, char **argv) {
    if (argc >= 2 && strcmp(argv[1], "bench") == 0) {
        return run_bench(argc - 2, argv + 2);
    }
    if (argc >= 2 && strcmp(argv[1], "test") == 0) {
        return run_tests();
    }
    uint32_t diff = 12;
    if (argc >= 2) {
        if (!parse_u32(argv[1], &diff)) {
            fprintf(stderr, "uso: %s [dificuldade] | bench [...] | test\n", argv[0]);
            return 2;
        }
    }
    demo_run(diff);
    return 0;
}