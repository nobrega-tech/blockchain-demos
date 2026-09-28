# Playground API (Go + Zig engine)

HTTP gateway in Go. Consensus / wallets / PoW live in the Zig shared library
`demo-blockchain-with-zig` (`blockchain_engine`).

## Build the Zig engine

```bash
cd ../demo-blockchain-with-zig
zig build engine -Doptimize=ReleaseFast
```

Produces `zig-out/bin/blockchain_engine.dll` (Windows) and the import lib.

## Run the API

From this directory (`finance/api-go`):

```bash
go run .
# or
go build -o api-go.exe . && ./api-go.exe -addr :8080 -difficulty 12
```

Optional: `BLOCKCHAIN_ENGINE_DLL` = absolute path to the shared library.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Engine status |
| GET | `/wallets` | Registered wallets |
| POST | `/wallets` | `{ "name": "Alice" }` (optional `seed` hex) |
| GET | `/balance/{addr}` | Balance (hex address or wallet name) |
| GET | `/chain` | Chain JSON from Zig |
| GET | `/transactions/pending` | Mempool |
| POST | `/transactions` | `{ "from", "to", "amount" }` (name or hex) |
| POST | `/mine?miner=Alice` | Mine pending (+ coinbase) |
| GET | `/validate` | Full chain validation |

CORS allows `localhost` / `127.0.0.1` for the vinext frontend.

From the repo root you can also use `mise run api` (builds the Zig engine first) or `mise run playground`.
