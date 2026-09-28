/* C ABI of blockchain_engine (Zig). Used by finance/api-go via DLL. */
#pragma once
#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

int32_t zig_engine_create(uint8_t difficulty, uint64_t reward, int64_t genesis_ts);
void zig_engine_destroy(void);
int32_t zig_wallet_register(const uint8_t seed[32], uint8_t out_addr[32]);
uint64_t zig_balance(const uint8_t addr[32]);
uint64_t zig_pending_count(void);
uint64_t zig_block_count(void);
int32_t zig_validate(uint8_t *err_buf, size_t err_len);
int32_t zig_submit_tx(const uint8_t from[32], const uint8_t to[32], uint64_t amount,
                      uint8_t *err_buf, size_t err_len);
int32_t zig_mine(const uint8_t miner[32], int64_t timestamp, uint8_t *err_buf, size_t err_len);
int32_t zig_chain_json(uint8_t *buf, size_t buflen);
int32_t zig_pending_json(uint8_t *buf, size_t buflen);

#ifdef __cplusplus
}
#endif