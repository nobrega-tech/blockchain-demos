use std::error::Error;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

use demo_blockchain::{Blockchain, Options, Transaction, ValidationError, Wallet, hex, short_hex};

mod bench;

fn main() -> Result<(), Box<dyn Error>> {
    let argv: Vec<String> = std::env::args().collect();

    // Modo benchmark: `demo-blockchain bench [--difficulty N] [--blocks N] [--txs-per-block N]`
    if argv.get(1).map(|s| s.as_str()) == Some("bench") {
        let args = bench::parse_args(&argv[2..]).map_err(|e| e)?;
        bench::run(args);
        return Ok(());
    }

    // Uso: demo-blockchain [dificuldade em bits] (padrao: 18)
    let difficulty: u32 = match argv.get(1) {
        Some(arg) => arg.parse()?,
        None => 18,
    };

    let mut chain = Blockchain::new(Options {
        difficulty,
        genesis_timestamp: now(),
        ..Default::default()
    });

    let mut alice = Wallet::generate("Alice");
    let mut bob = Wallet::generate("Bob");
    let miner = Wallet::generate("Minerador");

    println!("=== Blockchain em Rust ===");
    println!("Dificuldade: {} bits zero | Recompensa: {} moedas\n", chain.difficulty, chain.mining_reward);
    for w in [&alice, &bob, &miner] {
        println!("  {:<10} {}", w.name, hex(&w.address()));
    }

    println!("\n>> Alice minera o primeiro bloco (recebe a recompensa)");
    mine(&mut chain, &alice);

    println!("\n>> Alice envia 30 para Bob e 5 para o Minerador");
    submit(&mut chain, alice.send(bob.address(), 30)?);
    submit(&mut chain, alice.send(miner.address(), 5)?);

    println!("\n>> Bob tenta gastar mais do que tem (saldo confirmado = 0)");
    submit(&mut chain, bob.send(alice.address(), 100)?);

    println!("\n>> Bob tenta forjar uma transacao gastando o dinheiro de Alice");
    let mut forged = Transaction {
        from: Some(alice.address()),
        to: bob.address(),
        amount: 10,
        nonce: 42,
        signature: None,
    };
    forged.signature = bob.send(bob.address(), 1)?.signature;
    submit(&mut chain, forged);

    println!("\n>> Minerador fecha o bloco com as transacoes pendentes");
    mine(&mut chain, &miner);

    println!("\n>> Bob repassa 12 para o Minerador");
    submit(&mut chain, bob.send(miner.address(), 12)?);
    mine(&mut chain, &miner);

    print_chain(&chain);

    println!("\nSaldos:");
    for w in [&alice, &bob, &miner] {
        println!("  {:<10} {:>4} moedas", w.name, chain.balance_of(&w.address()));
    }

    print!("\nValidando a cadeia... ");
    report(chain.validate());

    let difficulty = chain.difficulty;

    println!("\n>> Ataque: alterando o valor da transacao Alice -> Bob de 30 para 3000");
    chain.blocks[2].transactions[1].amount = 3000;
    print!("Validando a cadeia... ");
    report(chain.validate());

    println!(">> Ataque: reminerando o bloco adulterado");
    chain.blocks[2].mine(difficulty);
    print!("Validando a cadeia... ");
    report(chain.validate());

    chain.blocks[2].transactions[1].amount = 30;
    chain.blocks[2].mine(difficulty);
    println!(">> Valor restaurado: o bloco volta a ter exatamente o hash original");
    print!("Validando a cadeia... ");
    report(chain.validate());

    Ok(())
}

fn now() -> i64 {
    SystemTime::now().duration_since(UNIX_EPOCH).map_or(0, |d| d.as_secs() as i64)
}

fn submit(chain: &mut Blockchain, tx: Transaction) {
    match chain.add_transaction(tx) {
        Ok(()) => println!("  [ok]    tx {} aceita na mempool ({} moedas)", short_hex(&tx.hash()), tx.amount),
        Err(err) => println!("  [recusada] tx {}: {:?}", short_hex(&tx.hash()), err),
    }
}

fn mine(chain: &mut Blockchain, miner: &Wallet) {
    let start = Instant::now();
    let block = chain.mine_pending(miner.address(), now());
    println!(
        "  bloco #{} minerado por {} em {} ms (nonce {}, {} tx)",
        block.index,
        miner.name,
        start.elapsed().as_millis(),
        block.nonce,
        block.transactions.len(),
    );
}

fn print_chain(chain: &Blockchain) {
    println!("\nCadeia ({} blocos):", chain.blocks.len());
    for block in &chain.blocks {
        println!("  #{}  hash {}", block.index, hex(&block.hash));
        println!("      prev {}  nonce {}", short_hex(&block.prev_hash), block.nonce);
        for t in &block.transactions {
            let from = t.from.map_or_else(|| "coinbase".to_string(), |f| short_hex(&f));
            println!("      {:<16} -> {}  {:>4}", from, short_hex(&t.to), t.amount);
        }
    }
}

fn report(result: Result<(), ValidationError>) {
    match result {
        Ok(()) => println!("VALIDA"),
        Err(err) => println!("INVALIDA ({err:?})"),
    }
}