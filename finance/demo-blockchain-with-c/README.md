# Blockchain em C

Demo didÃ¡tica alinhada ao bench justo de Rust/Zig/Go:

- Blocos encadeados por SHA-256
- PoW em **bits** zero no inÃ­cio do hash
- Header binÃ¡rio LE: `index || timestamp || prev_hash || merkle_root || nonce`
- Coinbase no bench: `from=nil`, `to=pubkey(seed[9;32])`, `amount=50`, `nonce=index`
- Timestamps fixos `1700000000 + i`

SHA-256: implementaÃ§Ã£o single-file em `src/sha256.c` (sem OpenSSL).

## Build (Windows)

Com **zig cc** (recomendado):

```bat
zig cc -O3 -std=c11 -DDEMO_IMPL_NAME=\"c\" -Isrc -o demo-blockchain.exe src/sha256.c src/blockchain.c src/main.c
```

Ou Makefile / CMake:

```bat
make CC="zig cc"
cmake -B build -DCMAKE_C_COMPILER="zig;cc" -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release
```

## Uso

```bat
demo-blockchain.exe              REM demo (dificuldade 12)
demo-blockchain.exe 14           REM demo custom
demo-blockchain.exe test         REM smoke tests
demo-blockchain.exe bench --difficulty 16 --blocks 5 --txs-per-block 0
demo-blockchain.exe bench --difficulty 18 --blocks 3 --txs-per-block 0
```