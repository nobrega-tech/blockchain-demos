# Blockchain em Assembly (x86-64 Windows, híbrido C/ASM)

Mesmo modelo de bench justo que Rust/Zig/Go/C, com **cache do prefixo SHA-256** no PoW
(igual Rust/Zig: absorve o header fixo uma vez; por nonce só `update(nonce)+final`).

## Assembly

| Arquivo | Conteúdo |
|---|---|
| `src/pow_mine.S` | Loop de PoW à mão + midstate clone por nonce |
| `src/sha256.c` | SHA-256 portable (`init`/`update`/`final` usados pelo ASM) |
| `src/blockchain.c` / `main.c` | Merkle, CLI, bench (C) |

## Build

```bat
zig cc -O3 -std=c11 -DDEMO_USE_ASM_MINE -DDEMO_IMPL_NAME=\"asm\" -Isrc -o demo-blockchain.exe src/sha256.c src/pow_mine.S src/blockchain.c src/main.c
```

## Uso

```bat
demo-blockchain.exe test
demo-blockchain.exe bench --difficulty 16 --blocks 5 --txs-per-block 0
demo-blockchain.exe bench --difficulty 18 --blocks 3 --txs-per-block 0
```