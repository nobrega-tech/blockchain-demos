package blockchain

import (
	"errors"
	"strings"
	"testing"
)

const testDifficulty = 2

func TestGenesis(t *testing.T) {
	bc := New(testDifficulty, 50)
	blocks := bc.Blocks()

	if len(blocks) != 1 {
		t.Fatalf("esperava 1 bloco, obteve %d", len(blocks))
	}
	if !strings.HasPrefix(blocks[0].Hash, "00") {
		t.Errorf("gênese sem prova de trabalho: %s", blocks[0].Hash)
	}
	if err := bc.Validate(); err != nil {
		t.Errorf("cadeia nova deveria ser válida: %v", err)
	}
}

func TestMineAndBalances(t *testing.T) {
	bc := New(testDifficulty, 50)

	if _, err := bc.MinePending("alice"); err != nil {
		t.Fatal(err)
	}
	if got := bc.Balance("alice"); got != 50 {
		t.Fatalf("alice: esperava 50, obteve %d", got)
	}

	if err := bc.AddTransaction(Transaction{From: "alice", To: "bob", Amount: 30}); err != nil {
		t.Fatal(err)
	}
	block, err := bc.MinePending("carol")
	if err != nil {
		t.Fatal(err)
	}

	if block.PrevHash != bc.Blocks()[1].Hash {
		t.Error("novo bloco não aponta para o anterior")
	}
	for addr, want := range map[string]int64{"alice": 20, "bob": 30, "carol": 50} {
		if got := bc.Balance(addr); got != want {
			t.Errorf("%s: esperava %d, obteve %d", addr, want, got)
		}
	}
	if len(bc.Pending()) != 0 {
		t.Error("pendentes deveriam estar vazias após mineração")
	}
	if err := bc.Validate(); err != nil {
		t.Errorf("cadeia deveria ser válida: %v", err)
	}
}

func TestInsufficientFunds(t *testing.T) {
	bc := New(testDifficulty, 50)
	bc.MinePending("alice")

	if err := bc.AddTransaction(Transaction{From: "alice", To: "bob", Amount: 40}); err != nil {
		t.Fatal(err)
	}
	// Os 40 pendentes já comprometem o saldo; mais 20 excede os 50.
	err := bc.AddTransaction(Transaction{From: "alice", To: "bob", Amount: 20})
	if !errors.Is(err, ErrInsufficientFunds) {
		t.Errorf("esperava ErrInsufficientFunds, obteve %v", err)
	}
}

func TestInvalidTransactions(t *testing.T) {
	bc := New(testDifficulty, 50)
	cases := []Transaction{
		{From: "", To: "bob", Amount: 1},
		{From: "alice", To: "", Amount: 1},
		{From: "alice", To: "bob", Amount: 0},
		{From: "alice", To: "alice", Amount: 1},
		{From: RewardSender, To: "bob", Amount: 1},
	}
	for _, tx := range cases {
		if err := bc.AddTransaction(tx); !errors.Is(err, ErrInvalidTransaction) {
			t.Errorf("%+v: esperava ErrInvalidTransaction, obteve %v", tx, err)
		}
	}
}

func TestTamperDetection(t *testing.T) {
	bc := New(testDifficulty, 50)
	bc.MinePending("alice")
	bc.AddTransaction(Transaction{From: "alice", To: "bob", Amount: 10})
	bc.MinePending("alice")

	// Adulteração direta do conteúdo de um bloco.
	bc.blocks[1].Transactions[0].Amount = 1_000_000
	if err := bc.Validate(); err == nil {
		t.Fatal("adulteração do conteúdo não foi detectada")
	}

	// Mesmo re-minerando o bloco adulterado, o encadeamento quebra.
	bc.blocks[1].Mine(testDifficulty)
	if err := bc.Validate(); err == nil {
		t.Fatal("quebra de encadeamento não foi detectada")
	}
}
