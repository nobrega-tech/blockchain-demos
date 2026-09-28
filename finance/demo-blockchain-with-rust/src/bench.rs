//! Modo benchmark: minera N blocos e emite uma linha JSON em stdout.

use std::time::Instant;

use demo_blockchain::Block;
use demo_blockchain::{Blockchain, Options};
use demo_blockchain::Transaction;
use demo_blockchain::Wallet;

#[derive(Debug)]
pub struct BenchArgs {
    pub difficulty: u32,
    pub blocks: u32,
    pub txs_per_block: u32,
}

impl Default for BenchArgs {
    fn default() -> Self {
        Self { difficulty: 16, blocks: 5, txs_per_block: 0 }
    }
}

/// Parseia `bench [--difficulty N] [--blocks N] [--txs-per-block N]`.
pub fn parse_args(args: &[String]) -> Result<BenchArgs, String> {
    let mut out = BenchArgs::default();
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--difficulty" => {
                i += 1;
                out.difficulty = args.get(i).ok_or("faltou valor de --difficulty")?
                    .parse().map_err(|_| "difficulty invalida")?;
            }
            "--blocks" => {
                i += 1;
                out.blocks = args.get(i).ok_or("faltou valor de --blocks")?
                    .parse().map_err(|_| "blocks invalido")?;
            }
            "--txs-per-block" => {
                i += 1;
                out.txs_per_block = args.get(i).ok_or("faltou valor de --txs-per-block")?
                    .parse().map_err(|_| "txs-per-block invalido")?;
            }
            other => return Err(format!("flag desconhecida no bench: {other}")),
        }
        i += 1;
    }
    Ok(out)
}

pub fn run(args: BenchArgs) {
    let mut miner = Wallet::from_seed("bench-miner", [9; 32]);
    let sink = Wallet::from_seed("bench-sink", [8; 32]);

    // Genese minerado fora do cronometro.
    let mut chain = Blockchain::new(Options {
        difficulty: args.difficulty,
        genesis_timestamp: 1_700_000_000,
        ..Default::default()
    });

    let mut hashes: u64 = 0;
    let start = Instant::now();

    for b in 0..args.blocks {
        // Coinbase + txs assinadas opcionais (gastam da coinbase do bloco anterior).
        if args.txs_per_block > 0 {
            // Garante saldo: no primeiro bloco so cabem txs se ja houver saldo;
            // minera-se so a coinbase quando ainda nao ha fundos suficientes.
            let spendable = chain.spendable_balance(&miner.address());
            let want = args.txs_per_block as u64;
            let n = want.min(spendable).min(Block::MAX_TRANSACTIONS as u64 - 1);
            for _ in 0..n {
                let tx = miner.send(sink.address(), 1).expect("assinar");
                chain.add_transaction(tx).expect("mempool");
            }
        }

        let index = chain.blocks.len() as u64;
        let mut txs = Vec::with_capacity(chain.pending.len() + 1);
        txs.push(Transaction::coinbase(miner.address(), chain.mining_reward, index));
        txs.append(&mut chain.pending);

        let mut block = Block::new(index, 1_700_000_000 + b as i64 + 1, chain.latest().hash, txs);
        let attempts = block.mine(chain.difficulty);
        hashes += attempts;
        chain.blocks.push(block);
        let _ = b;
    }

    let elapsed = start.elapsed();
    let total_ms = elapsed.as_millis() as u64;
    let secs = elapsed.as_secs_f64();
    let hashes_per_sec = if secs > 0.0 { hashes as f64 / secs } else { 0.0 };

    // Uma unica linha JSON em stdout.
    println!(
        "{{\"impl\":\"rust\",\"difficulty\":{},\"difficulty_unit\":\"bits\",\"blocks\":{},\"txs_per_block\":{},\"total_ms\":{},\"hashes\":{},\"hashes_per_sec\":{}}}",
        args.difficulty,
        args.blocks,
        args.txs_per_block,
        total_ms,
        hashes,
        format!("{:.6}", hashes_per_sec).trim_end_matches('0').trim_end_matches('.')
    );
}