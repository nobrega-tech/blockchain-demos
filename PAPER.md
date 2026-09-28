# Blockchain didática: do ledger ao bench justo

Texto introdutório (didático + técnico) para quem está começando. Complementa as
demos em `finance/` e o [README](./README.md). Ideias de extensão: [IDEAS.md](./IDEAS.md).

## 1. O problema: um livro-razão compartilhado

Um **ledger** (livro-razão) registra transferências de valor entre participantes.
Num banco tradicional, uma autoridade central mantém a verdade. Numa blockchain
pública, muitos computadores guardam cópias e precisam **concordar** sobre a
ordem das transações sem confiar cegamente uns nos outros.

As demos deste repositório são **didáticas**: mostram os blocos de construção
(hash, PoW, Merkle, validação) sem pretender ser redes de produção.

## 2. Transação

Uma **transação** diz: “A envia X para B”.

Nas demos mais completas (Rust/Zig), o remetente **assina** o conteúdo com
Ed25519; o endereço é a chave pública. Isso impede que Mallory gaste o saldo de
Alice só porque inventou uma mensagem.

Campos típicos nas demos ricas:

- `from` / `to` (endereços)
- `amount`
- `nonce` (anti-replay: duas txs idênticas não colidem)
- `signature` (ausente na coinbase)

Go (API HTTP) usa endereços-string sem assinatura — ótimo para aprender o fluxo
HTTP, mas o **bench justo** (`-bench`) alinhou o digest ao das outras langs.

## 3. Mempool

Antes de entrar num bloco, txs válidas ficam numa fila: a **mempool**.

Regras comuns ao aceitar uma tx:

- assinatura ok (quando existir)
- saldo suficiente (incluindo o já “reservado” por txs pendentes)
- não duplicar a mesma tx

Quando um minerador **fecha um bloco**, esvazia (parte da) mempool e inclui as
txs escolhidas.

## 4. Bloco e encadeamento

Um **bloco** agrupa txs e aponta para o bloco anterior:

```
Bloco N:  …  prev_hash = hash(Bloco N-1)
```

Alterar um bloco antigo muda seu hash; o próximo bloco deixa de apontar
corretamente — a cadeia **quebra**. Por isso “blockchain”: uma lista ligada por
hashes.

O **gênesis** é o bloco 0 (sem antecessor real; `prev` costuma ser zeros).

## 5. Hash e integridade

**SHA-256** resume bytes num digest de 32 bytes. Propriedades úteis:

- determinístico
- mudança mínima no input → digest irreconhecível
- difícil achar pré-imagem (inverter o hash)

Nas demos justas, o hash do bloco **não** é um JSON solto: é o SHA-256 de um
**cabeçalho binário** little-endian:

`index || timestamp || prev_hash || merkle_root || nonce`

## 6. Merkle root

Em vez de hashear todas as txs de novo no loop de mineração, hasheia-se uma
**raiz de Merkle** das txs:

- cada tx → folha
- pares de hashes → nós internos (folha ímpar repete a si mesma)
- a raiz entra no header

Qualquer alteração numa tx muda a raiz e, portanto, o hash do bloco.

## 7. Prova de trabalho (PoW)

**PoW** exige achar um `nonce` tal que o hash do header comece com um número
mínimo de **bits zero** (`difficulty`).

Mineração (ideia):

1. Montar o header (prefixo fixo + nonce)
2. SHA-256
3. Contar bits zero no início
4. Se insuficiente, `nonce++` e repetir

**Prefix cache (midstate):** o prefixo (index, ts, prev, merkle) não muda durante
a busca. Absorve-se uma vez no hasher; a cada tentativa só se acrescenta o nonce
e finaliza. Mesmo resultado, bem menos trabalho por tentativa.

A **coinbase** (recompensa) cria moedas novas para o minerador (`from = nil` nas
demos Rust/Zig; layout equivalente no bench das outras langs).

## 8. Carteira (wallet)

Uma **carteira** guarda chaves e cria txs assinadas. Nas demos:

- gerar/from-seed (Ed25519)
- `address()` = chave pública
- `send(to, amount)` → tx assinada com nonce crescente

## 9. Validação da cadeia

`validate()` (ou equivalente) percorre a cadeia e verifica, entre outros:

- índices e `prev_hash` coerentes
- hash/PoW de cada bloco
- regras da coinbase
- assinaturas e saldos (modelo account nas demos ricas)
- ausência de txs duplicadas

Adulterar um amount quebra PoW ou assinatura; reminerar um bloco no meio quebra
o link com o seguinte.

## 10. Como as demos se mapeiam

| Pasta | Papel |
|---|---|
| Go | API HTTP didática + `-bench` justo |
| Rust / Zig | Modelo completo (Ed25519, Merkle, PoW bits) |
| C / ASM | Mesmo digest; ASM acelera o loop de PoW |
| Python | Mesmo modelo com `hashlib` + `copy()` |

Todas no caminho `bench` (params iguais) devem reportar os **mesmos `hashes`**
(tentativas de PoW). O que muda é tempo e HPS.

## 11. Bench justo — o que comparar

Parâmetros típicos: `difficulty=16`, `blocks=5`, `txs_per_block=0`.

Compare:

- **hashes** — devem bater (mesmo trabalho)
- **total_ms / hashes_per_sec** — custo de runtime / qualidade do SHA-256
- **CPU / RSS** — uso de recurso durante a mineração (amostragem no host)

Não compare a API HTTP hex do Go com o PoW bits do Rust: workloads diferentes.

## 12. Próximos passos

Ver [IDEAS.md](./IDEAS.md) (P2P, UTXO, SPV, forks, contratos toy, GPU…).

---

*Material de estudo. Não use estas demos como blockchain de produção.*