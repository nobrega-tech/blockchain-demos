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

## Resultados (após prefix cache)

Medidos em **uma máquina** (desktop de lab apelidado **Redragon**). São **rodadas únicas**,
não um estudo científico (sem média/desvio, sem isolamento térmico, etc.).

### Ambiente de medição

| Item | Spec (não confidencial) |
|---|---|
| CPU | AMD Ryzen 7 5800X (8 cores / 16 threads, até ~3,8 GHz) |
| RAM | 16 GB |
| SO | Microsoft Windows 11 Pro (build 26200), 64 bits |
| Disco | SSD NVMe (~1 TB) + HDD SATA (~2 TB) disponíveis |

Sem hostname, usuário, seriais, IPs ou chaves — só o necessário para contextualizar o HPS.

Workload justo: LE + Merkle + bits + midstate. **Hash counts idênticos** em todas.

### difficulty = 16 bits, blocks = 5, txs_per_block = 0

`hashes = 242629` em todas as langs.

| Impl | total_ms | hashes/s (aprox.) |
|---|---:|---:|
| **Zig** | 11 | ~22,1 M |
| **Rust** | 13 | ~17,7 M |
| **Go** (`-bench`) | 27 | ~8,7 M |
| **C** | 58 | ~4,2 M |
| **ASM** | ~58 | ~4,1 M |
| **Python** | 256 | ~0,95 M |

### difficulty = 18 bits, blocks = 3, txs_per_block = 0

`hashes = 813846` em todas.

| Impl | total_ms | hashes/s (aprox.) |
|---|---:|---:|
| **Zig** | ~36–39 | ~21–23 M |
| **Rust** | ~45–46 | ~17–18 M |
| **C** | ~194–195 | ~4,2 M |
| **ASM** | ~199 | ~4,1 M |
| **Python** | ~869 | ~0,94 M |

(Ordem estável: **Zig ≳ Rust > Go > C ≈ ASM ≫ Python**.)

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

1. **Hash counts iguais** (`242629` / `813846`) ⇒ mesmo PoW; compare HPS, não “quem minera mais blocos”.
2. **Prefix cache** importa: sem midstate, C/ASM/Python reprocessam o header a cada nonce e ficam artificialmente lentos.
3. Ordem típica de HPS: **Zig ≳ Rust > Go > C ≈ ASM ≫ Python**.
4. A API HTTP do Go (zeros **hex**, hash JSON) **não** é o mesmo workload do bench — use `-bench` para comparar.
5. `txs_per_block > 0` no C/ASM/Python usa txs dummy sem Ed25519; para paridade use `0`.
6. Números acima são **one-shot** na Redragon — use-os como ilustração, não como ranking definitivo.

## Licença / propósito

Material de estudo e benchmark didático — não é uma blockchain de produção.