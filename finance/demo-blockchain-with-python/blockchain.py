"""Blockchain didática — mesmo modelo de bench justo que Rust/Zig/C/ASM/Go."""

from __future__ import annotations

import hashlib
import struct
import time
from dataclasses import dataclass, field
from typing import List, Optional

HASH_SIZE = 32
MINING_REWARD = 50
GENESIS_TS = 1_700_000_000
HEADER_PREFIX_SIZE = 80  # index(8)+ts(8)+prev(32)+merkle(32)

# Ed25519 pubkey of seed [9;32] — same as Rust/Zig/C/Go fair bench.
BENCH_MINER_ADDRESS = bytes.fromhex(
    "fd1724385aa0c75b64fb78cd602fa1d991fdebf76b13c58ed702eac835e9f618"
)


def u64_le(v: int) -> bytes:
    return struct.pack("<Q", v & 0xFFFFFFFFFFFFFFFF)


def i64_le(v: int) -> bytes:
    return struct.pack("<q", v)


def leading_zero_bits(digest: bytes) -> int:
    """Count leading zero bits (MSB first), matching Rust/Zig/C."""
    count = 0
    for b in digest:
        if b == 0:
            count += 8
            continue
        for shift in range(7, -1, -1):
            if (b >> shift) & 1:
                return count
            count += 1
        break
    return count


@dataclass
class Transaction:
    to: bytes
    amount: int
    nonce: int
    frm: Optional[bytes] = None  # None => coinbase

    @staticmethod
    def coinbase(to: bytes, amount: int, block_index: int) -> "Transaction":
        return Transaction(to=to, amount=amount, nonce=block_index, frm=None)

    def hash(self) -> bytes:
        h = hashlib.sha256()
        if self.frm is None:
            h.update(b"\x00")
        else:
            h.update(b"\x01")
            h.update(self.frm)
        h.update(self.to)
        h.update(u64_le(self.amount))
        h.update(u64_le(self.nonce))
        return h.digest()


def merkle_root(txs: List[Transaction]) -> bytes:
    if not txs:
        return bytes(HASH_SIZE)
    level = [tx.hash() for tx in txs]
    while len(level) > 1:
        nxt = []
        for i in range(0, len(level), 2):
            left = level[i]
            right = level[i + 1] if i + 1 < len(level) else level[i]
            nxt.append(hashlib.sha256(left + right).digest())
        level = nxt
    return level[0]


@dataclass
class Block:
    index: int
    timestamp: int
    prev_hash: bytes
    transactions: List[Transaction] = field(default_factory=list)
    nonce: int = 0
    hash: bytes = field(default_factory=lambda: bytes(HASH_SIZE))

    def header_prefix(self) -> bytes:
        return (
            u64_le(self.index)
            + i64_le(self.timestamp)
            + self.prev_hash
            + merkle_root(self.transactions)
        )

    def mine(self, difficulty: int) -> int:
        """PoW with SHA-256 prefix caching via hashlib.copy()."""
        prefix = self.header_prefix()
        assert len(prefix) == HEADER_PREFIX_SIZE
        base = hashlib.sha256()
        base.update(prefix)

        self.nonce = 0
        while True:
            h = base.copy()
            h.update(u64_le(self.nonce))
            candidate = h.digest()
            if leading_zero_bits(candidate) >= difficulty:
                self.hash = candidate
                return self.nonce + 1
            self.nonce += 1


@dataclass
class Blockchain:
    difficulty: int
    mining_reward: int = MINING_REWARD
    blocks: List[Block] = field(default_factory=list)

    @classmethod
    def create(cls, difficulty: int, genesis_ts: int = GENESIS_TS) -> "Blockchain":
        bc = cls(difficulty=difficulty)
        genesis = Block(index=0, timestamp=genesis_ts, prev_hash=bytes(HASH_SIZE))
        genesis.mine(difficulty)
        bc.blocks.append(genesis)
        return bc

    @property
    def latest(self) -> Block:
        return self.blocks[-1]


@dataclass
class BenchArgs:
    difficulty: int = 16
    blocks: int = 5
    txs_per_block: int = 0


@dataclass
class BenchResult:
    total_ms: int
    hashes: int
    hashes_per_sec: float


def bench_run(args: BenchArgs) -> BenchResult:
    bc = Blockchain.create(args.difficulty, GENESIS_TS)
    hashes = 0
    t0 = time.perf_counter()

    for i in range(args.blocks):
        txs = [Transaction.coinbase(BENCH_MINER_ADDRESS, bc.mining_reward, len(bc.blocks))]
        for t in range(args.txs_per_block):
            txs.append(
                Transaction(
                    to=bytes([8]) + bytes(31),
                    amount=1,
                    nonce=t,
                    frm=BENCH_MINER_ADDRESS,
                )
            )
        block = Block(
            index=len(bc.blocks),
            timestamp=GENESIS_TS + i + 1,
            prev_hash=bc.latest.hash,
            transactions=txs,
        )
        hashes += block.mine(args.difficulty)
        bc.blocks.append(block)

    elapsed = time.perf_counter() - t0
    total_ms = int(elapsed * 1000)
    hps = (hashes / elapsed) if elapsed > 0 else 0.0
    return BenchResult(total_ms=total_ms, hashes=hashes, hashes_per_sec=hps)


def bench_print_json(args: BenchArgs, result: BenchResult) -> None:
    print(
        '{"impl":"python","difficulty":%d,"difficulty_unit":"bits",'
        '"blocks":%d,"txs_per_block":%d,"total_ms":%d,"hashes":%d,'
        '"hashes_per_sec":%.6f}'
        % (
            args.difficulty,
            args.blocks,
            args.txs_per_block,
            result.total_ms,
            result.hashes,
            result.hashes_per_sec,
        )
    )


def demo_run(difficulty: int = 12) -> None:
    bc = Blockchain.create(difficulty, GENESIS_TS)
    print("=== Blockchain em Python ===")
    print(f"Dificuldade: {difficulty} bits | Recompensa: {MINING_REWARD}\n")
    for i in range(3):
        txs = [Transaction.coinbase(BENCH_MINER_ADDRESS, MINING_REWARD, len(bc.blocks))]
        block = Block(
            index=len(bc.blocks),
            timestamp=GENESIS_TS + i + 1,
            prev_hash=bc.latest.hash,
            transactions=txs,
        )
        t0 = time.perf_counter()
        attempts = block.mine(difficulty)
        ms = (time.perf_counter() - t0) * 1000
        print(
            f"  bloco #{block.index} minerado em {ms:.0f} ms "
            f"(nonce {block.nonce}, attempts {attempts})"
        )
        print(f"      hash {block.hash.hex()}")
        bc.blocks.append(block)
    print(f"\nCadeia OK ({len(bc.blocks)} blocos). Use `bench` para medir PoW.")