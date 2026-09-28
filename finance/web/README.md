# Blockchain Playground (vinext)

Frontend vinext that talks **only** to the Go API in `../api-go`.
The consensus engine is Zig (`../demo-blockchain-with-zig` as a shared library).

## Run

1. Build the Zig engine and start the Go API (see `../api-go/README.md`).
2. In this directory:

```bash
bun install
bun run dev
```

Open the vinext URL (usually `http://localhost:3000`).
Optional: `NEXT_PUBLIC_API_URL=http://127.0.0.1:8080`.
