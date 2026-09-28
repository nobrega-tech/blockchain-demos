# blockchain-demos

Coleção de demos didáticas de blockchain em várias linguagens, organizadas para
comparar o **mesmo modelo de prova de trabalho** de forma justa.

```
blockchain-demos/          ← raiz do repositório Git
└── finance/               ← demos de blockchain (domínio finance)
    ├── demo-blockchain-with-go/
    ├── demo-blockchain-with-rust/
    ├── demo-blockchain-with-zig/
    ├── demo-blockchain-with-c/
    ├── demo-blockchain-with-asm/
    └── demo-blockchain-with-python/
```

> O diretório `finance/` agrupa estes exemplos. O restante do Playground
> (ex.: `benchmark-harness`) **não** faz parte deste repositório.

## Modelo de bench justo

Todas as implementações (no caminho `bench`) usam o **mesmo digest**:

| Aspecto | Detalhe |
|---|---|
| Header | Little-endian: `index \|\| timestamp \|\| prev_hash \|\| merkle_root \|\| nonce` |
| Hash | SHA-256 |
| PoW | Bits zero no início do hash (`leading_zero_bits`) |
| Cache | Prefixo do header absorvido **uma vez**; por nonce só `update(nonce) + final` |
| Genesis | `prev_hash = [0;32]`, minerado fora do cronômetro |
| Coinbase | `from = nil`, `to = pubkey(seed [9;32])`, `amount = 50`, `nonce = index` |
| Timestamps | Fixos: `1700000000 + i` |
| Saída | Uma linha JSON: `{"impl":"…","difficulty":N,"difficulty_unit":"bits",…}` |

Com `difficulty=16, blocks=5, txs_per_block=0` (e `18/3`), os **`hashes` (tentativas)
devem coincidir** entre as linguagens — mesmo trabalho de PoW. O que muda é o
**tempo / hashes_per_sec** (custo de runtime e qualidade do SHA-256).

Endereço do minerador no bench (pubkey Ed25519 de seed `[9;32]`):

`fd1724385aa0c75b64fb78cd602fa1d991fdebf76b13c58ed702eac835e9f618`

## Demos

| Pasta | Linguagem | Notas |
|---|---|---|
| `finance/demo-blockchain-with-go` | Go | API HTTP didática (PoW hex) + `-bench` com digest justo (bits + Merkle binário) |
| `finance/demo-blockchain-with-rust` | Rust | Modelo completo (Ed25519, Merkle, PoW bits); referência do port |
| `finance/demo-blockchain-with-zig` | Zig 0.16 | Mesmo modelo do Rust; só stdlib |
| `finance/demo-blockchain-with-c` | C | Bench justo + midstate; SHA-256 single-file |
| `finance/demo-blockchain-with-asm` | C + x86-64 ASM | Loop de PoW em assembly; midstate; Merkle/CLI em C |
| `finance/demo-blockchain-with-python` | Python 3 | Stdlib `hashlib` + `copy()` para midstate |

## Como testar

```bat
cd finance\demo-blockchain-with-go
go test ./...

cd ..\demo-blockchain-with-rust
cargo test

cd ..\demo-blockchain-with-zig
zig build test

cd ..\demo-blockchain-with-c
zig cc -O3 -std=c11 -DDEMO_IMPL_NAME=\"c\" -Isrc -o demo-blockchain.exe src\sha256.c src\blockchain.c src\main.c
demo-blockchain.exe test

cd ..\demo-blockchain-with-asm
zig cc -O3 -std=c11 -DDEMO_USE_ASM_MINE -DDEMO_IMPL_NAME=\"asm\" -Isrc -o demo-blockchain.exe src\sha256.c src\pow_mine.S src\blockchain.c src\main.c
demo-blockchain.exe test

cd ..\demo-blockchain-with-python
python __main__.py test
```

## Como rodar o bench

Mesmos parâmetros em todas (exemplo Release / otimizado):

```bat
REM Go
cd finance\demo-blockchain-with-go
go build -ldflags="-s -w" -o demo-blockchain.exe .
demo-blockchain.exe -bench -difficulty 16 -blocks 5 -txs-per-block 0

REM Rust
cd ..\demo-blockchain-with-rust
cargo run --release -- bench --difficulty 16 --blocks 5 --txs-per-block 0

REM Zig
cd ..\demo-blockchain-with-zig
zig build run -Doptimize=ReleaseFast -- bench --difficulty 16 --blocks 5 --txs-per-block 0

REM C
cd ..\demo-blockchain-with-c
demo-blockchain.exe bench --difficulty 16 --blocks 5 --txs-per-block 0

REM ASM
cd ..\demo-blockchain-with-asm
demo-blockchain.exe bench --difficulty 16 --blocks 5 --txs-per-block 0

REM Python
cd ..\demo-blockchain-with-python
python __main__.py bench --difficulty 16 --blocks 5 --txs-per-block 0
```

Repita com `--difficulty 18 --blocks 3` (Go: `-difficulty 18 -blocks 3`).

## Notas de comparação (honestas)

1. **Hash counts iguais** ⇒ mesmo PoW; compare HPS, não “quem minera mais blocos”.
2. **Prefix cache** importa: sem midstate, C/ASM/Python reprocessam o header a cada nonce e ficam artificialmente lentos.
3. Ordem típica de HPS observada: **Zig ≳ Rust ≫ C ≈ ASM ≫ Python**. Go no `-bench` justo fica na faixa do C (digest alinhado).
4. A API HTTP do Go (zeros **hex**, hash JSON) **não** é o mesmo workload do bench — use `-bench` para comparar.
5. `txs_per_block > 0` no C/ASM/Python usa txs dummy sem Ed25519; para paridade use `0`.

## Licença / propósito

Material de estudo e benchmark didático — não é uma blockchain de produção.