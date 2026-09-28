"use client";

import { useCallback, useEffect, useMemo, useState } from "react";

const API = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8080";

type Wallet = { name: string; address: string; seed?: string };
type Health = {
  ok: boolean;
  engine: string;
  difficulty: number;
  reward: number;
  blocks: number;
  pending: number;
};
type Tx = {
  from: string | null;
  to: string;
  amount: number;
  nonce: number;
  coinbase?: boolean;
};
type Block = {
  index: number;
  timestamp: number;
  nonce: number;
  hash: string;
  prev_hash: string;
  transactions: Tx[];
};
type Chain = {
  length: number;
  difficulty: number;
  reward: number;
  pending: number;
  chain: Block[];
};

async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error((data as { error?: string }).error ?? res.statusText);
  }
  return data as T;
}

function short(hex: string, n = 8) {
  if (!hex) return "";
  return hex.length <= n * 2 ? hex : `${hex.slice(0, n)}…${hex.slice(-n)}`;
}

export function Playground() {
  const [health, setHealth] = useState<Health | null>(null);
  const [wallets, setWallets] = useState<Wallet[]>([]);
  const [balances, setBalances] = useState<Record<string, number>>({});
  const [chain, setChain] = useState<Chain | null>(null);
  const [pending, setPending] = useState<Tx[]>([]);
  const [valid, setValid] = useState<{ valid: boolean; error?: string } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [newName, setNewName] = useState("");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [amount, setAmount] = useState("10");
  const [miner, setMiner] = useState("");

  const refresh = useCallback(async () => {
    setError(null);
    try {
      const [h, w, c, p, v] = await Promise.all([
        api<Health>("/health"),
        api<Wallet[]>("/wallets"),
        api<Chain>("/chain"),
        api<Tx[]>("/transactions/pending"),
        api<{ valid: boolean; error?: string }>("/validate"),
      ]);
      setHealth(h);
      setWallets(w);
      setChain(c);
      setPending(p);
      setValid(v);
      const bal: Record<string, number> = {};
      await Promise.all(
        w.map(async (wallet) => {
          const b = await api<{ balance: number }>(`/balance/${wallet.address}`);
          bal[wallet.address] = b.balance;
        }),
      );
      setBalances(bal);
      if (!from && w[0]) setFrom(w[0].name);
      if (!to && w[1]) setTo(w[1].name);
      if (!miner && w[0]) setMiner(w[0].name);
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    }
  }, [from, to, miner]);

  useEffect(() => {
    void refresh();
    const t = setInterval(() => void refresh(), 5000);
    return () => clearInterval(t);
  }, [refresh]);

  const run = async (fn: () => Promise<void>) => {
    setBusy(true);
    setError(null);
    try {
      await fn();
      await refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  const statusTone = useMemo(() => {
    if (error) return "text-rose-400";
    if (valid?.valid) return "text-emerald-400";
    return "text-amber-400";
  }, [error, valid]);

  return (
    <main className="min-h-screen bg-slate-950 px-4 py-8 text-slate-100 sm:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-6">
        <header className="flex flex-col gap-2 border-b border-slate-800 pb-6 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-cyan-400">
              Blockchain Playground
            </p>
            <h1 className="mt-2 text-3xl font-semibold tracking-tight sm:text-4xl">
              Transferências com motor Zig
            </h1>
            <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-400">
              UI vinext → API HTTP Go → biblioteca compartilhada Zig (Ed25519, Merkle, PoW em bits).
              API: <code className="mono text-cyan-300">{API}</code>
            </p>
          </div>
          <button
            className="rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-sm hover:bg-slate-800 disabled:opacity-50"
            disabled={busy}
            onClick={() => void refresh()}
            type="button"
          >
            Atualizar
          </button>
        </header>

        <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Stat label="Engine" value={health?.engine ?? "—"} />
          <Stat label="Difficulty (bits)" value={health?.difficulty ?? "—"} />
          <Stat label="Blocos" value={health?.blocks ?? "—"} />
          <Stat label="Pending" value={health?.pending ?? "—"} />
        </section>

        <p className={`text-sm ${statusTone}`}>
          {error
            ? `Erro: ${error}`
            : valid?.valid
              ? "Cadeia válida"
              : `Cadeia inválida: ${valid?.error ?? "—"}`}
        </p>

        <div className="grid gap-6 lg:grid-cols-2">
          <Card title="Carteiras">
            <form
              className="mb-4 flex gap-2"
              onSubmit={(e) => {
                e.preventDefault();
                const name = newName.trim();
                if (!name) return;
                void run(async () => {
                  await api("/wallets", {
                    method: "POST",
                    body: JSON.stringify({ name }),
                  });
                  setNewName("");
                });
              }}
            >
              <input
                className="flex-1 rounded-md border border-slate-700 bg-slate-950 px-3 py-2 text-sm"
                placeholder="Nome (ex.: Alice)"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
              />
              <button
                className="rounded-md bg-cyan-600 px-3 py-2 text-sm font-medium hover:bg-cyan-500 disabled:opacity-50"
                disabled={busy}
                type="submit"
              >
                Criar
              </button>
            </form>
            <ul className="space-y-3">
              {wallets.length === 0 && (
                <li className="text-sm text-slate-500">Nenhuma carteira ainda.</li>
              )}
              {wallets.map((w) => (
                <li
                  key={w.address}
                  className="rounded-lg border border-slate-800 bg-slate-950/60 p-3"
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="font-medium text-cyan-200">{w.name}</span>
                    <span className="text-lg font-semibold tabular-nums">
                      {balances[w.address] ?? "…"}
                    </span>
                  </div>
                  <p className="mono mt-1 break-all text-xs text-slate-500">{w.address}</p>
                </li>
              ))}
            </ul>
          </Card>

          <Card title="Transferir / Minerar">
            <div className="grid gap-3">
              <label className="grid gap-1 text-sm">
                De
                <select
                  className="rounded-md border border-slate-700 bg-slate-950 px-3 py-2"
                  value={from}
                  onChange={(e) => setFrom(e.target.value)}
                >
                  <option value="">—</option>
                  {wallets.map((w) => (
                    <option key={w.address} value={w.name}>
                      {w.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="grid gap-1 text-sm">
                Para
                <select
                  className="rounded-md border border-slate-700 bg-slate-950 px-3 py-2"
                  value={to}
                  onChange={(e) => setTo(e.target.value)}
                >
                  <option value="">—</option>
                  {wallets.map((w) => (
                    <option key={w.address} value={w.name}>
                      {w.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="grid gap-1 text-sm">
                Quantidade
                <input
                  className="rounded-md border border-slate-700 bg-slate-950 px-3 py-2"
                  type="number"
                  min={1}
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                />
              </label>
              <button
                className="rounded-md bg-violet-600 px-3 py-2 text-sm font-medium hover:bg-violet-500 disabled:opacity-50"
                disabled={busy || !from || !to}
                type="button"
                onClick={() =>
                  void run(async () => {
                    await api("/transactions", {
                      method: "POST",
                      body: JSON.stringify({
                        from,
                        to,
                        amount: Number(amount),
                      }),
                    });
                  })
                }
              >
                Enviar para mempool
              </button>

              <hr className="border-slate-800" />

              <label className="grid gap-1 text-sm">
                Minerador
                <select
                  className="rounded-md border border-slate-700 bg-slate-950 px-3 py-2"
                  value={miner}
                  onChange={(e) => setMiner(e.target.value)}
                >
                  <option value="">—</option>
                  {wallets.map((w) => (
                    <option key={w.address} value={w.name}>
                      {w.name}
                    </option>
                  ))}
                </select>
              </label>
              <button
                className="rounded-md bg-amber-600 px-3 py-2 text-sm font-medium hover:bg-amber-500 disabled:opacity-50"
                disabled={busy || !miner}
                type="button"
                onClick={() =>
                  void run(async () => {
                    await api(`/mine?miner=${encodeURIComponent(miner)}`, {
                      method: "POST",
                    });
                  })
                }
              >
                Minerar bloco (PoW Zig)
              </button>
            </div>
          </Card>
        </div>

        <Card title={`Mempool (${pending.length})`}>
          {pending.length === 0 ? (
            <p className="text-sm text-slate-500">Vazio.</p>
          ) : (
            <ul className="space-y-2 text-sm">
              {pending.map((tx, i) => (
                <li key={i} className="mono rounded border border-slate-800 px-3 py-2">
                  {short(tx.from ?? "coinbase")} → {short(tx.to)} : {tx.amount} (nonce {tx.nonce})
                </li>
              ))}
            </ul>
          )}
        </Card>

        <Card title={`Cadeia (${chain?.length ?? 0} blocos)`}>
          <div className="space-y-3">
            {(chain?.chain ?? [])
              .slice()
              .reverse()
              .map((b) => (
                <article
                  key={b.hash}
                  className="rounded-lg border border-slate-800 bg-slate-950/50 p-3 text-sm"
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <span className="font-semibold text-cyan-200">Bloco #{b.index}</span>
                    <span className="text-slate-500">nonce {b.nonce}</span>
                  </div>
                  <p className="mono mt-1 break-all text-xs text-slate-400">hash {b.hash}</p>
                  <p className="mono break-all text-xs text-slate-600">prev {b.prev_hash}</p>
                  <ul className="mt-2 space-y-1 text-xs text-slate-300">
                    {b.transactions.map((tx, i) => (
                      <li key={i}>
                        {tx.coinbase || !tx.from
                          ? `coinbase → ${short(tx.to)} +${tx.amount}`
                          : `${short(tx.from)} → ${short(tx.to)} : ${tx.amount}`}
                      </li>
                    ))}
                  </ul>
                </article>
              ))}
          </div>
        </Card>
      </div>
    </main>
  );
}

function Stat({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-xl border border-slate-800 bg-slate-900/70 p-4">
      <p className="text-xs uppercase tracking-wide text-slate-500">{label}</p>
      <p className="mt-1 text-2xl font-semibold tabular-nums">{value}</p>
    </div>
  );
}

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-xl border border-slate-800 bg-slate-900/40 p-5">
      <h2 className="mb-4 text-lg font-semibold text-slate-100">{title}</h2>
      {children}
    </section>
  );
}