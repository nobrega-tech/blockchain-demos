# Blockchain em Python

Demo didática alinhada ao bench justo de Rust/Zig/C/ASM/Go:

- Header binário LE: `index || timestamp || prev_hash || merkle_root || nonce`
- PoW em **bits** zero no início do SHA-256
- **Cache do prefixo** via `hashlib.sha256().copy()` (como Rust/Zig)
- Coinbase no bench: `from=None`, `to=pubkey(seed[9;32])`, `amount=50`, `nonce=index`
- Timestamps fixos `1700000000 + i`
- Só stdlib (`hashlib`)

## Uso

```bat
cd D:\Playground\demo-blockchain-with-python
python __main__.py                 REM demo (dificuldade 12)
python __main__.py 14
python __main__.py test
python __main__.py bench --difficulty 16 --blocks 5 --txs-per-block 0
python __main__.py bench --difficulty 18 --blocks 3 --txs-per-block 0
```

Opcional com pytest:

```bat
python -m pytest test_blockchain.py -q
```

## Nota de desempenho

Python será bem mais lento que Rust/Zig/C no HPS (interpretado + overhead de
`hashlib.copy()` por tentativa). Os **hash counts** devem coincidir — mesmo trabalho de PoW.