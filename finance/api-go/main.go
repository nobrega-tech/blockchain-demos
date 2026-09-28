package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/nobrega-tech/blockchain-demos/finance/api-go/engine"
)

type walletInfo struct {
	Name    string `json:"name"`
	Address string `json:"address"`
	SeedHex string `json:"seed,omitempty"` // only returned on create
}

var (
	walletsMu sync.RWMutex
	wallets   = map[string]walletInfo{} // address hex -> info
	byName    = map[string]string{}     // name -> address hex
)

func main() {
	addr := flag.String("addr", ":8080", "HTTP listen address")
	difficulty := flag.Uint("difficulty", 12, "PoW difficulty in leading zero bits (Zig engine)")
	reward := flag.Uint64("reward", 50, "mining reward (coinbase)")
	flag.Parse()

	genesisTS := time.Now().Unix()
	if err := engine.Create(uint8(*difficulty), *reward, genesisTS); err != nil {
		log.Fatal(err)
	}
	defer engine.Destroy()

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{
			"ok":         true,
			"engine":     "zig",
			"difficulty": *difficulty,
			"reward":     *reward,
			"blocks":     engine.BlockCount(),
			"pending":    engine.PendingCount(),
		})
	})

	mux.HandleFunc("GET /wallets", handleListWallets)
	mux.HandleFunc("POST /wallets", handleCreateWallet)
	mux.HandleFunc("GET /balance/{addr}", handleBalance)
	mux.HandleFunc("GET /chain", handleChain)
	mux.HandleFunc("GET /transactions/pending", handlePending)
	mux.HandleFunc("POST /transactions", handleSubmitTx)
	mux.HandleFunc("POST /mine", handleMine)
	mux.HandleFunc("GET /validate", handleValidate)

	handler := corsMiddleware(mux)

	go func() {
		ch := make(chan os.Signal, 1)
		signal.Notify(ch, os.Interrupt, syscall.SIGTERM)
		<-ch
		engine.Destroy()
		os.Exit(0)
	}()

	log.Printf("playground API on %s (Zig engine, difficulty=%d bits, reward=%d)", *addr, *difficulty, *reward)
	log.Fatal(http.ListenAndServe(*addr, handler))
}

func handleListWallets(w http.ResponseWriter, r *http.Request) {
	walletsMu.RLock()
	defer walletsMu.RUnlock()
	list := make([]walletInfo, 0, len(wallets))
	for _, wi := range wallets {
		list = append(list, walletInfo{Name: wi.Name, Address: wi.Address})
	}
	writeJSON(w, http.StatusOK, list)
}

func handleCreateWallet(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Name string `json:"name"`
		Seed string `json:"seed"` // optional 64-char hex
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid JSON: "+err.Error())
		return
	}
	body.Name = strings.TrimSpace(body.Name)
	if body.Name == "" {
		writeError(w, http.StatusBadRequest, "name required")
		return
	}

	walletsMu.Lock()
	defer walletsMu.Unlock()
	if _, exists := byName[body.Name]; exists {
		writeError(w, http.StatusConflict, "wallet name already exists")
		return
	}

	var seed [32]byte
	if body.Seed != "" {
		b, err := hex.DecodeString(strings.TrimPrefix(body.Seed, "0x"))
		if err != nil || len(b) != 32 {
			writeError(w, http.StatusBadRequest, "seed must be 32 bytes hex (64 chars)")
			return
		}
		copy(seed[:], b)
	} else {
		if _, err := rand.Read(seed[:]); err != nil {
			writeError(w, http.StatusInternalServerError, "rng failed")
			return
		}
	}

	addr, err := engine.WalletRegister(seed)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	addrHex := hex.EncodeToString(addr[:])
	wi := walletInfo{
		Name:    body.Name,
		Address: addrHex,
		SeedHex: hex.EncodeToString(seed[:]),
	}
	wallets[addrHex] = walletInfo{Name: body.Name, Address: addrHex}
	byName[body.Name] = addrHex
	writeJSON(w, http.StatusCreated, wi)
}

func handleBalance(w http.ResponseWriter, r *http.Request) {
	addr, err := resolveAddr(r.PathValue("addr"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"address": hex.EncodeToString(addr[:]),
		"balance": engine.Balance(addr),
	})
}

func handleChain(w http.ResponseWriter, r *http.Request) {
	raw, err := engine.ChainJSON()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(raw)
}

func handlePending(w http.ResponseWriter, r *http.Request) {
	raw, err := engine.PendingJSON()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(raw)
}

func handleSubmitTx(w http.ResponseWriter, r *http.Request) {
	var body struct {
		From   string `json:"from"`
		To     string `json:"to"`
		Amount uint64 `json:"amount"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid JSON: "+err.Error())
		return
	}
	from, err := resolveAddr(body.From)
	if err != nil {
		writeError(w, http.StatusBadRequest, "from: "+err.Error())
		return
	}
	to, err := resolveAddr(body.To)
	if err != nil {
		writeError(w, http.StatusBadRequest, "to: "+err.Error())
		return
	}
	if body.Amount == 0 {
		writeError(w, http.StatusBadRequest, "amount must be > 0")
		return
	}
	if err := engine.SubmitTx(from, to, body.Amount); err != nil {
		writeError(w, http.StatusUnprocessableEntity, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{
		"from":   hex.EncodeToString(from[:]),
		"to":     hex.EncodeToString(to[:]),
		"amount": body.Amount,
	})
}

func handleMine(w http.ResponseWriter, r *http.Request) {
	minerQ := r.URL.Query().Get("miner")
	if minerQ == "" {
		var body struct {
			Miner string `json:"miner"`
		}
		_ = json.NewDecoder(r.Body).Decode(&body)
		minerQ = body.Miner
	}
	miner, err := resolveAddr(minerQ)
	if err != nil {
		writeError(w, http.StatusBadRequest, "miner: "+err.Error())
		return
	}
	if err := engine.Mine(miner, time.Now().Unix()); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{
		"ok":     true,
		"blocks": engine.BlockCount(),
		"miner":  hex.EncodeToString(miner[:]),
	})
}

func handleValidate(w http.ResponseWriter, r *http.Request) {
	ok, msg := engine.Validate()
	if ok {
		writeJSON(w, http.StatusOK, map[string]any{"valid": true})
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"valid": false, "error": msg})
}

func resolveAddr(s string) ([32]byte, error) {
	s = strings.TrimSpace(s)
	walletsMu.RLock()
	if addrHex, ok := byName[s]; ok {
		walletsMu.RUnlock()
		return parseAddr(addrHex)
	}
	walletsMu.RUnlock()
	return parseAddr(s)
}

func parseAddr(s string) ([32]byte, error) {
	var out [32]byte
	s = strings.TrimPrefix(strings.TrimSpace(s), "0x")
	b, err := hex.DecodeString(s)
	if err != nil || len(b) != 32 {
		return out, errOr("address must be 32-byte hex or known wallet name", err)
	}
	copy(out[:], b)
	return out, nil
}

func errOr(msg string, err error) error {
	if err != nil {
		return err
	}
	return &simpleError{msg}
}

type simpleError struct{ s string }

func (e *simpleError) Error() string { return e.s }

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin == "" || strings.HasPrefix(origin, "http://localhost") || strings.HasPrefix(origin, "http://127.0.0.1") {
			if origin == "" {
				w.Header().Set("Access-Control-Allow-Origin", "*")
			} else {
				w.Header().Set("Access-Control-Allow-Origin", origin)
			}
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}