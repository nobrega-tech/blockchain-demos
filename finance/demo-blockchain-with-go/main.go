package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"mamamia/blockchain"
)

func main() {
	addr := flag.String("addr", ":8080", "endereco HTTP")
	difficulty := flag.Int("difficulty", 4, "zeros hex (API) ou bits (-bench)")
	reward := flag.Int64("reward", 50, "recompensa por bloco minerado")
	bench := flag.Bool("bench", false, "modo benchmark: minera N blocos com PoW em bits e imprime JSON")
	blocks := flag.Int("blocks", 5, "blocos alem do genese (so -bench)")
	txsPerBlock := flag.Int("txs-per-block", 0, "txs extras por bloco alem da coinbase (so -bench)")
	flag.Parse()

	if *bench {
		result := blockchain.RunBench(*difficulty, *blocks, *txsPerBlock)
		enc := json.NewEncoder(os.Stdout)
		if err := enc.Encode(result); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		return
	}

	bc := blockchain.New(*difficulty, *reward)
	mux := http.NewServeMux()

	mux.HandleFunc("GET /chain", func(w http.ResponseWriter, r *http.Request) {
		blocks := bc.Blocks()
		writeJSON(w, http.StatusOK, map[string]any{"length": len(blocks), "chain": blocks})
	})

	mux.HandleFunc("GET /transactions/pending", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, bc.Pending())
	})

	mux.HandleFunc("POST /transactions", func(w http.ResponseWriter, r *http.Request) {
		var tx blockchain.Transaction
		if err := json.NewDecoder(r.Body).Decode(&tx); err != nil {
			writeError(w, http.StatusBadRequest, "JSON invalido: "+err.Error())
			return
		}
		if err := bc.AddTransaction(tx); err != nil {
			status := http.StatusBadRequest
			if errors.Is(err, blockchain.ErrInsufficientFunds) {
				status = http.StatusUnprocessableEntity
			}
			writeError(w, status, err.Error())
			return
		}
		writeJSON(w, http.StatusCreated, tx)
	})

	mux.HandleFunc("POST /mine", func(w http.ResponseWriter, r *http.Request) {
		block, err := bc.MinePending(r.URL.Query().Get("miner"))
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		writeJSON(w, http.StatusCreated, block)
	})

	mux.HandleFunc("GET /balance/{addr}", func(w http.ResponseWriter, r *http.Request) {
		a := r.PathValue("addr")
		writeJSON(w, http.StatusOK, map[string]any{"address": a, "balance": bc.Balance(a)})
	})

	mux.HandleFunc("GET /validate", func(w http.ResponseWriter, r *http.Request) {
		if err := bc.Validate(); err != nil {
			writeJSON(w, http.StatusOK, map[string]any{"valid": false, "error": err.Error()})
			return
		}
		writeJSON(w, http.StatusOK, map[string]any{"valid": true})
	})

	log.Printf("blockchain rodando em %s (dificuldade %d)", *addr, *difficulty)
	log.Fatal(http.ListenAndServe(*addr, mux))
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}