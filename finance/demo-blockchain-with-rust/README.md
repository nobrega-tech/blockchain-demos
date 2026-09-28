# Blockchain em Rust

Blockchain didática em Rust — port fiel de [`demo-blockchain-with-zig`](../demo-blockchain-with-zig).

- **Carteiras**: pares de chaves Ed25519; o endereço é a chave pública.
- **Transações**: assinadas pelo remetente, com nonce para evitar replay.
- **Blocos**: encadeados por SHA-256, com raiz de Merkle das transações.
- **Consenso**: prova de trabalho (bits zero no início do hash) + recompensa (coinbase).
- **Validação**: revalida a cadeia inteira (encadeamento, PoW, assinaturas, coinbase, saldos).

Dependências: `sha2`, `ed25519-dalek`, `hex` e `getrandom` (Rust não traz criptografia na std).

## Uso

```sh
cargo run --release           # demo (dificuldade 18 bits)
cargo run --release -- 20     # dificuldade customizada
cargo test                    # testes
```

## Estrutura

| Arquivo | Conteúdo |
|---|---|
| `src/hash.rs` | SHA-256, hex e contagem de bits zero |
| `src/transaction.rs` | Transação, assinatura e verificação |
| `src/wallet.rs` | Carteira (chaves e envio) |
| `src/block.rs` | Bloco, Merkle e mineração |
| `src/blockchain.rs` | Cadeia, mempool, saldos e validação |
| `src/main.rs` | Demo com transferências e ataques |

## Benchmark

`sh
cargo run --release -- bench --difficulty 16 --blocks 5 --txs-per-block 0
cargo run --release -- bench --difficulty 18 --blocks 3
`

Imprime uma linha JSON com 	otal_ms, hashes e hashes_per_sec (PoW em bits).
