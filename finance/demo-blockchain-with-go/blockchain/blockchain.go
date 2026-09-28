package blockchain

import (
	"errors"
	"fmt"
	"strings"
	"sync"
)

// RewardSender é o remetente usado nas transações de recompensa de mineração.
const RewardSender = "SYSTEM"

var (
	ErrInvalidTransaction = errors.New("transação inválida")
	ErrInsufficientFunds  = errors.New("saldo insuficiente")
)

// Blockchain mantém a cadeia de blocos e as transações pendentes.
// É segura para uso concorrente.
type Blockchain struct {
	mu         sync.RWMutex
	blocks     []Block
	pending    []Transaction
	difficulty int
	reward     int64
}

// New cria uma blockchain com o bloco gênese já minerado.
func New(difficulty int, reward int64) *Blockchain {
	genesis := newBlock(0, []Transaction{}, "0")
	genesis.Mine(difficulty)

	return &Blockchain{
		blocks:     []Block{genesis},
		pending:    []Transaction{},
		difficulty: difficulty,
		reward:     reward,
	}
}

// AddTransaction valida e adiciona uma transação à fila de pendentes.
func (bc *Blockchain) AddTransaction(tx Transaction) error {
	if tx.From == "" || tx.To == "" || tx.Amount <= 0 {
		return fmt.Errorf("%w: from, to e amount > 0 são obrigatórios", ErrInvalidTransaction)
	}
	if tx.From == RewardSender {
		return fmt.Errorf("%w: remetente %q é reservado", ErrInvalidTransaction, RewardSender)
	}
	if tx.From == tx.To {
		return fmt.Errorf("%w: remetente e destinatário são iguais", ErrInvalidTransaction)
	}

	bc.mu.Lock()
	defer bc.mu.Unlock()

	// Considera também o que já está comprometido em transações pendentes.
	available := bc.balance(tx.From)
	for _, p := range bc.pending {
		if p.From == tx.From {
			available -= p.Amount
		}
	}
	if available < tx.Amount {
		return fmt.Errorf("%w: %s tem %d, precisa de %d", ErrInsufficientFunds, tx.From, available, tx.Amount)
	}

	bc.pending = append(bc.pending, tx)
	return nil
}

// MinePending minera um novo bloco com as transações pendentes mais a
// recompensa para o minerador, e o anexa à cadeia.
func (bc *Blockchain) MinePending(miner string) (Block, error) {
	if miner == "" || miner == RewardSender {
		return Block{}, fmt.Errorf("%w: endereço do minerador inválido", ErrInvalidTransaction)
	}

	bc.mu.Lock()
	defer bc.mu.Unlock()

	txs := append(bc.pending, Transaction{From: RewardSender, To: miner, Amount: bc.reward})
	last := bc.blocks[len(bc.blocks)-1]

	block := newBlock(last.Index+1, txs, last.Hash)
	block.Mine(bc.difficulty)

	bc.blocks = append(bc.blocks, block)
	bc.pending = []Transaction{}
	return block, nil
}

// Balance retorna o saldo confirmado (apenas blocos minerados) de um endereço.
func (bc *Blockchain) Balance(addr string) int64 {
	bc.mu.RLock()
	defer bc.mu.RUnlock()
	return bc.balance(addr)
}

func (bc *Blockchain) balance(addr string) int64 {
	var total int64
	for _, b := range bc.blocks {
		for _, tx := range b.Transactions {
			if tx.From == addr {
				total -= tx.Amount
			}
			if tx.To == addr {
				total += tx.Amount
			}
		}
	}
	return total
}

// Blocks retorna uma cópia da cadeia.
func (bc *Blockchain) Blocks() []Block {
	bc.mu.RLock()
	defer bc.mu.RUnlock()
	return append([]Block(nil), bc.blocks...)
}

// Pending retorna uma cópia das transações pendentes.
func (bc *Blockchain) Pending() []Transaction {
	bc.mu.RLock()
	defer bc.mu.RUnlock()
	return append([]Transaction{}, bc.pending...)
}

// Validate verifica a integridade de toda a cadeia: hashes, prova de trabalho
// e encadeamento. Retorna nil se a cadeia for válida.
func (bc *Blockchain) Validate() error {
	bc.mu.RLock()
	defer bc.mu.RUnlock()

	prefix := strings.Repeat("0", bc.difficulty)
	for i := range bc.blocks {
		b := &bc.blocks[i]
		if b.Index != i {
			return fmt.Errorf("bloco %d: índice incorreto (%d)", i, b.Index)
		}
		if b.Hash != b.CalculateHash() {
			return fmt.Errorf("bloco %d: hash não confere com o conteúdo", i)
		}
		if !strings.HasPrefix(b.Hash, prefix) {
			return fmt.Errorf("bloco %d: prova de trabalho inválida", i)
		}
		if i > 0 && b.PrevHash != bc.blocks[i-1].Hash {
			return fmt.Errorf("bloco %d: prev_hash não aponta para o bloco anterior", i)
		}
	}
	return nil
}
