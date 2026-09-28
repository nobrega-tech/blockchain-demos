# Blockchain em Zig

Blockchain didática escrita em Zig 0.16, usando apenas a biblioteca padrão.

- **Carteiras**: pares de chaves Ed25519; o endereço é a chave pública.
- **Transações**: assinadas pelo remetente, com nonce para evitar replay.
- **Blocos**: encadeados por SHA-256, com raiz de Merkle das transações.
- **Consenso**: prova de trabalho (bits zero no início do hash) + recompensa (coinbase).
- **Validação**: revalida a cadeia inteira (encadeamento, PoW, assinaturas, coinbase, saldos).

## Uso

```sh
zig build run                              # demo (dificuldade 18 bits)
zig build run -Doptimize=ReleaseFast -- 20 # dificuldade customizada
zig build test                             # testes
```

## Estrutura

| Arquivo | Conteúdo |
|---|---|
| `src/hash.zig` | SHA-256, hex e contagem de bits zero |
| `src/transaction.zig` | Transação, assinatura e verificação |
| `src/wallet.zig` | Carteira (chaves e envio) |
| `src/block.zig` | Bloco, Merkle e mineração |
| `src/blockchain.zig` | Cadeia, mempool, saldos e validação |
| `src/main.zig` | Demo com transferências e ataques |

## Benchmark

`sh
zig build run -Doptimize=ReleaseFast -- bench --difficulty 16 --blocks 5 --txs-per-block 0
zig build run -Doptimize=ReleaseFast -- bench --difficulty 18 --blocks 3
`

Imprime uma linha JSON com 	otal_ms, hashes e hashes_per_sec (PoW em bits).


## Shared library (playground)

```bash
zig build engine -Doptimize=ReleaseFast
```

Emite `zig-out/bin/blockchain_engine` (DLL/so) com a C ABI em `include/blockchain_engine.h`.
Consumida por `finance/api-go`.
