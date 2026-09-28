# Ideias de projetos

Extensões das demos em `finance/` e direções novas para estudar blockchain
na prática. Cada item é um projeto concreto (escopo pequeno → médio).

## Extensões das demos atuais

1. **Gossip P2P** — nós TCP/UDP trocam blocos e txs; inventário (`inv`/`getdata`);
   simular partição de rede e reconciliação.
2. **Retarget de dificuldade** — a cada N blocos ajustar bits zero com base no
   tempo médio; comparar regras estilo Bitcoin vs suavizadas.
3. **UTXO vs account model** — reimplementar saldos com conjunto UTXO (outpoints,
   coinbase maturity) e contraste com o modelo de contas das demos.
4. **Assinaturas em todas as langs** — alinhar Go/C/ASM/Python ao Ed25519 do
   Rust/Zig; mesmo vetor de teste e mesma rejeição de forge/replay.
5. **Mempool com taxas** — priorizar txs por fee; bloco limitado; eviction sob
   pressão; métricas de throughput.
6. **Persistência** — gravar cadeia em arquivo/SQLite; reabrir e `validate()`;
   checkpoint periódico do tip.
7. **CLI unificada de bench** — wrapper que chama Go/Rust/Zig/C/ASM/Python com
   os mesmos flags e agrega JSON num CSV (sem depender de pastas externas).

## Clientes leves e verificação

8. **SPV / light client** — baixar só headers + Merkle proof de uma tx; verificar
   inclusão sem o bloco completo.
9. **Prova de inclusão compacta** — API `prove(tx_id) → (block_hash, path)`;
   cliente verifica com a raiz do header.
10. **Sync headers-first** — baixar headers, validar PoW/encadeamento, depois
    corpos sob demanda.

## Consenso e forks

11. **Simulador de fork** — duas tips; regra “mais trabalho” (soma de dificuldade);
    orphanagem e reorg com replay de txs.
12. **Mining pool toy** — coordenador distribui job (header parcial); workers
    devolvem shares; payout proporcional.
13. **Ataque 51% didático** — minerador com maioria reescreve N blocos; medir
    custo em hashes vs honestos.
14. **Finalidade probabilística** — gráfico: probabilidade de reorg vs profundidade
    confirmations, para várias dificuldades.

## Contratos e execução

15. **Smart contracts toy** — VM mínima (stack: `ADD`/`IF`/`CHECKSIG`); script
    numa saída; execução na validação do bloco.
16. **WASM contracts** — carregar módulo WASM sandboxed como “contrato”; gas
    meter simples (contagem de instruções).
17. **State channels** — abrir canal off-chain, trocar estados assinados, fechar
    on-chain com disputa por timeout.

## Desempenho e hardware

18. **PoW em GPU** — OpenCL/CUDA ou compute shader: mesmo header LE; comparar
    HPS vs CPU das demos.
19. **SIMD / SHA hardware** — usar SHA-NI (x86) ou Intrinsic; midstate + bench
    lado a lado com a versão portable.
20. **Paralelismo de nonce** — ranges por thread/processo; redução lock-free do
    melhor candidato; fairness do bench.

## Redes e formato

21. **Codec binário estável** — protobuf/flatbuffers/bincode para bloco e tx;
    compatibilidade entre Rust e Zig.
22. **Libp2p ou quic transport** — descoberta, multiplex, backpressure; métricas
    de latência de propagação.
23. **Snapshots + prune** — estado compacto (raiz de contas/UTXO); nós full vs
    pruned.

## Produto / DX

24. **Explorer HTTP** — UI mínima: cadeia, bloco, tx, saldo; alimentada pela API
    Go ou por um adapter comum.
25. **Fuzzing de `validate()`** — mutação de headers/txs; property tests
    “cadeia válida continua válida sob append honesto”.
26. **Testes de interop** — vetores JSON compartilhados (genesis + N blocos) que
    todas as langs devem aceitar/rejeitar igual.

## Como escolher

| Se você quer… | Comece por |
|---|---|
| Redes | 1, 11, 22 |
| Consenso | 2, 11, 13, 14 |
| Modelo de dados | 3, 5, 6 |
| Clientes leves | 8, 9, 10 |
| Contratos | 15, 16, 17 |
| Performance | 18, 19, 20, 7 |
| Qualidade | 4, 25, 26 |

Sugestão: um projeto por vez, com critério de “pronto” mensurável (teste + bench
ou demo CLI).