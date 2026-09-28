package blockchain

import (
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"math/bits"
	"time"
)

// LeadingZeroBits conta bits zero no início de um digest de 32 bytes.
func LeadingZeroBits(digest [32]byte) int {
	count := 0
	for _, b := range digest {
		if b == 0 {
			count += 8
			continue
		}
		count += bits.LeadingZeros8(b)
		break
	}
	return count
}

// MineBits: PoW em bits sobre o digest JSON legado (testes). A API HTTP
// continua em CalculateHash/Mine (prefixo hex). O modo -bench usa mineBinary.
func (b *Block) MineBits(difficulty int) uint64 {
	var attempts uint64
	for {
		payload, _ := json.Marshal(struct {
			Index        int
			Timestamp    int64
			Transactions []Transaction
			PrevHash     string
			Nonce        int
		}{b.Index, b.Timestamp, b.Transactions, b.PrevHash, b.Nonce})
		raw := sha256.Sum256(payload)
		attempts++
		if LeadingZeroBits(raw) >= difficulty {
			b.Hash = hex.EncodeToString(raw[:])
			return attempts
		}
		b.Nonce++
	}
}

func (b *Block) rawDigest() [32]byte {
	payload, _ := json.Marshal(struct {
		Index        int
		Timestamp    int64
		Transactions []Transaction
		PrevHash     string
		Nonce        int
	}{b.Index, b.Timestamp, b.Transactions, b.PrevHash, b.Nonce})
	return sha256.Sum256(payload)
}

// ---- Bench-only: mesmo modelo de digest do Rust/Zig ----

// Pubkey Ed25519 de seed [9;32] (= Wallet::from_seed("bench-miner", [9;32])).
var benchMinerAddress = mustDecode32("fd1724385aa0c75b64fb78cd602fa1d991fdebf76b13c58ed702eac835e9f618")

func mustDecode32(s string) [32]byte {
	b, err := hex.DecodeString(s)
	if err != nil || len(b) != 32 {
		panic("bench miner address")
	}
	var out [32]byte
	copy(out[:], b)
	return out
}

// benchTx espelha Transaction do Rust/Zig (from=nil => coinbase).
type benchTx struct {
	from   *[32]byte
	to     [32]byte
	amount uint64
	nonce  uint64
}

func (tx benchTx) hash() [32]byte {
	h := sha256.New()
	if tx.from == nil {
		h.Write([]byte{0})
	} else {
		h.Write([]byte{1})
		h.Write((*tx.from)[:])
	}
	h.Write(tx.to[:])
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], tx.amount)
	h.Write(buf[:])
	binary.LittleEndian.PutUint64(buf[:], tx.nonce)
	h.Write(buf[:])
	var out [32]byte
	copy(out[:], h.Sum(nil))
	return out
}

func merkleRoot(txs []benchTx) [32]byte {
	if len(txs) == 0 {
		return [32]byte{}
	}
	level := make([][32]byte, len(txs))
	for i, tx := range txs {
		level[i] = tx.hash()
	}
	for len(level) > 1 {
		next := make([][32]byte, 0, (len(level)+1)/2)
		for i := 0; i < len(level); i += 2 {
			left := level[i]
			right := left
			if i+1 < len(level) {
				right = level[i+1]
			}
			h := sha256.New()
			h.Write(left[:])
			h.Write(right[:])
			var dig [32]byte
			copy(dig[:], h.Sum(nil))
			next = append(next, dig)
		}
		level = next
	}
	return level[0]
}

type benchBlock struct {
	index        uint64
	timestamp    int64
	prevHash     [32]byte
	transactions []benchTx
	nonce        uint64
	hash         [32]byte
}

// header sem nonce: index||timestamp||prev||merkle (todos LE / raw bytes).
func (b *benchBlock) headerPrefix() []byte {
	merkle := merkleRoot(b.transactions)
	prefix := make([]byte, 0, 8+8+32+32)
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], b.index)
	prefix = append(prefix, buf[:]...)
	binary.LittleEndian.PutUint64(buf[:], uint64(b.timestamp))
	prefix = append(prefix, buf[:]...)
	prefix = append(prefix, b.prevHash[:]...)
	prefix = append(prefix, merkle[:]...)
	return prefix
}

func (b *benchBlock) mineBinary(difficulty int) uint64 {
	prefix := b.headerPrefix()
	b.nonce = 0
	var nonceBuf [8]byte
	for {
		h := sha256.New()
		h.Write(prefix)
		binary.LittleEndian.PutUint64(nonceBuf[:], b.nonce)
		h.Write(nonceBuf[:])
		var candidate [32]byte
		copy(candidate[:], h.Sum(nil))
		if LeadingZeroBits(candidate) >= difficulty {
			b.hash = candidate
			return b.nonce + 1
		}
		b.nonce++
	}
}

// BenchResult é a linha JSON emitida pelo modo -bench.
type BenchResult struct {
	Impl           string  `json:"impl"`
	Difficulty     int     `json:"difficulty"`
	DifficultyUnit string  `json:"difficulty_unit"`
	Blocks         int     `json:"blocks"`
	TxsPerBlock    int     `json:"txs_per_block"`
	TotalMs        int64   `json:"total_ms"`
	Hashes         uint64  `json:"hashes"`
	HashesPerSec   float64 `json:"hashes_per_sec"`
}

// RunBench minera `blocks` blocos além do gênese com digest binário+Merkle+bits
// idêntico ao Rust/Zig. Timestamps fixos. Com txsPerBlock==0: só coinbase
// (to=pubkey seed[9;32], amount=50, nonce=index) — contagens de hash devem bater.
func RunBench(difficulty, blocks, txsPerBlock int) BenchResult {
	if difficulty < 0 {
		difficulty = 0
	}
	if blocks < 0 {
		blocks = 0
	}
	if txsPerBlock < 0 {
		txsPerBlock = 0
	}

	const (
		miningReward uint64 = 50
		genesisTs    int64  = 1_700_000_000
	)

	genesis := benchBlock{
		index:     0,
		timestamp: genesisTs,
		prevHash:  [32]byte{},
	}
	genesis.mineBinary(difficulty)

	chain := []benchBlock{genesis}
	miner := benchMinerAddress

	var hashes uint64
	start := time.Now()

	for i := 0; i < blocks; i++ {
		index := uint64(len(chain))
		txs := make([]benchTx, 0, 1+txsPerBlock)
		txs = append(txs, benchTx{
			from:   nil,
			to:     miner,
			amount: miningReward,
			nonce:  index,
		})
		for t := 0; t < txsPerBlock; t++ {
			sink := [32]byte{}
			sink[0] = 8
			from := miner
			txs = append(txs, benchTx{
				from:   &from,
				to:     sink,
				amount: 1,
				nonce:  uint64(t),
			})
		}
		block := benchBlock{
			index:        index,
			timestamp:    genesisTs + int64(i) + 1,
			prevHash:     chain[len(chain)-1].hash,
			transactions: txs,
		}
		attempts := block.mineBinary(difficulty)
		hashes += attempts
		chain = append(chain, block)
	}

	elapsed := time.Since(start)
	ms := elapsed.Milliseconds()
	var hps float64
	if elapsed.Seconds() > 0 {
		hps = float64(hashes) / elapsed.Seconds()
	}

	return BenchResult{
		Impl:           "go",
		Difficulty:     difficulty,
		DifficultyUnit: "bits",
		Blocks:         blocks,
		TxsPerBlock:    txsPerBlock,
		TotalMs:        ms,
		Hashes:         hashes,
		HashesPerSec:   hps,
	}
}