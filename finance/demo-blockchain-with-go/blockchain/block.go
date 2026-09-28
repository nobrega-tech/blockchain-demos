package blockchain

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"strings"
	"time"
)

// Transaction representa uma transferência de valor entre dois endereços.
type Transaction struct {
	From   string `json:"from"`
	To     string `json:"to"`
	Amount int64  `json:"amount"`
}

// Block é a unidade da cadeia: agrupa transações e aponta para o bloco anterior.
type Block struct {
	Index        int           `json:"index"`
	Timestamp    int64         `json:"timestamp"`
	Transactions []Transaction `json:"transactions"`
	PrevHash     string        `json:"prev_hash"`
	Nonce        int           `json:"nonce"`
	Hash         string        `json:"hash"`
}

func newBlock(index int, txs []Transaction, prevHash string) Block {
	return Block{
		Index:        index,
		Timestamp:    time.Now().Unix(),
		Transactions: txs,
		PrevHash:     prevHash,
	}
}

// CalculateHash retorna o SHA-256 de todos os campos do bloco, exceto o próprio Hash.
func (b *Block) CalculateHash() string {
	payload, _ := json.Marshal(struct {
		Index        int
		Timestamp    int64
		Transactions []Transaction
		PrevHash     string
		Nonce        int
	}{b.Index, b.Timestamp, b.Transactions, b.PrevHash, b.Nonce})

	sum := sha256.Sum256(payload)
	return hex.EncodeToString(sum[:])
}

// Mine executa a prova de trabalho: incrementa o nonce até o hash começar
// com `difficulty` zeros.
func (b *Block) Mine(difficulty int) {
	prefix := strings.Repeat("0", difficulty)
	for {
		b.Hash = b.CalculateHash()
		if strings.HasPrefix(b.Hash, prefix) {
			return
		}
		b.Nonce++
	}
}
