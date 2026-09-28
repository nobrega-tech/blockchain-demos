package blockchain

import (
	"crypto/sha256"
	"encoding/binary"
	"testing"
)

func TestLeadingZeroBits(t *testing.T) {
	var h [32]byte
	if got := LeadingZeroBits(h); got != 256 {
		t.Fatalf("zeros: got %d", got)
	}
	h[1] = 0b0001_0000
	if got := LeadingZeroBits(h); got != 11 {
		t.Fatalf("partial: got %d want 11", got)
	}
}

func TestMineBitsAndTamper(t *testing.T) {
	const diff = 8
	b := newBlock(1, []Transaction{{From: RewardSender, To: "alice", Amount: 50}}, "00")
	attempts := b.MineBits(diff)
	if attempts == 0 {
		t.Fatal("expected at least one hash attempt")
	}
	raw := b.rawDigest()
	if LeadingZeroBits(raw) < diff {
		t.Fatalf("PoW bits not satisfied: %s", b.Hash)
	}
	b.Transactions[0].Amount = 999
	if b.rawDigest() == raw {
		t.Fatal("tamper should change digest")
	}
}

func TestRunBenchSmoke(t *testing.T) {
	r := RunBench(4, 1, 0)
	if r.Impl != "go" || r.DifficultyUnit != "bits" || r.Blocks != 1 {
		t.Fatalf("unexpected result: %+v", r)
	}
	if r.Hashes == 0 {
		t.Fatal("expected hashes > 0")
	}
}

func TestBenchCoinbaseHashMatchesRustLayout(t *testing.T) {
	tx := benchTx{from: nil, to: benchMinerAddress, amount: 50, nonce: 1}
	got := tx.hash()

	h := sha256.New()
	h.Write([]byte{0})
	h.Write(benchMinerAddress[:])
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], 50)
	h.Write(buf[:])
	binary.LittleEndian.PutUint64(buf[:], 1)
	h.Write(buf[:])
	var want [32]byte
	copy(want[:], h.Sum(nil))

	if got != want {
		t.Fatalf("coinbase hash layout mismatch\n got %x\nwant %x", got, want)
	}
	if merkleRoot(nil) != ([32]byte{}) {
		t.Fatal("empty merkle must be zero")
	}
	if merkleRoot([]benchTx{tx}) != got {
		t.Fatal("single-tx merkle is the tx hash")
	}
}