"""Smoke tests — run with: python __main__.py test  OR  python -m pytest test_blockchain.py -q"""

from __future__ import annotations

import hashlib

from blockchain import (
    BENCH_MINER_ADDRESS,
    GENESIS_TS,
    BenchArgs,
    Block,
    Transaction,
    bench_run,
    leading_zero_bits,
    merkle_root,
)


def test_leading_zero_bits():
    assert leading_zero_bits(bytes(32)) == 256
    h = bytearray(32)
    h[1] = 0b0001_0000
    assert leading_zero_bits(bytes(h)) == 11


def test_sha256_empty():
    assert (
        hashlib.sha256(b"").hexdigest()
        == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    )


def test_empty_merkle():
    assert merkle_root([]) == bytes(32)


def test_mine_bits():
    tx = Transaction.coinbase(BENCH_MINER_ADDRESS, 50, 1)
    b = Block(index=1, timestamp=GENESIS_TS + 1, prev_hash=bytes(32), transactions=[tx])
    attempts = b.mine(8)
    assert attempts > 0
    assert leading_zero_bits(b.hash) >= 8


def test_bench_smoke():
    r = bench_run(BenchArgs(difficulty=4, blocks=1, txs_per_block=0))
    assert r.hashes > 0


def run_tests() -> int:
    tests = [
        test_leading_zero_bits,
        test_sha256_empty,
        test_empty_merkle,
        test_mine_bits,
        test_bench_smoke,
    ]
    failed = 0
    for t in tests:
        try:
            t()
            print(f"  ok  {t.__name__}")
        except Exception as e:
            print(f" FAIL {t.__name__}: {e}")
            failed += 1
    if failed:
        print(f"{failed} TEST(S) FAILED")
        return 1
    print("ALL TESTS PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(run_tests())