const std = @import("std");
const Io = std.Io;
const bc = @import("blockchain");
const bench_mod = @import("bench.zig");

const Blockchain = bc.Blockchain;
const Wallet = bc.Wallet;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const out = &stdout_file_writer.interface;
    defer out.flush() catch {};

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    // Modo benchmark: demo-blockchain bench [--difficulty N] [--blocks N] [--txs-per-block N]
    if (args.len > 1 and std.mem.eql(u8, args[1], "bench")) {
        const bench_args = try bench_mod.parseArgs(args[2..]);
        try bench_mod.run(gpa, io, out, bench_args);
        return;
    }

    // Uso: demo-blockchain [dificuldade em bits] (padrao: 18)
    const difficulty: u8 = if (args.len > 1) try std.fmt.parseInt(u8, args[1], 10) else 18;

    var chain = try Blockchain.init(gpa, .{
        .difficulty = difficulty,
        .genesis_timestamp = now(io),
    });
    defer chain.deinit();

    var alice = Wallet.generate(io, "Alice");
    var bob = Wallet.generate(io, "Bob");
    var miner = Wallet.generate(io, "Minerador");
    const wallets = [_]*const Wallet{ &alice, &bob, &miner };

    try out.print("=== Blockchain em Zig ===\n", .{});
    try out.print("Dificuldade: {d} bits zero | Recompensa: {d} moedas\n\n", .{ chain.difficulty, chain.mining_reward });
    for (wallets) |w| try out.print("  {s:<10} {s}\n", .{ w.name, bc.hex(w.address()) });

    try out.print("\n>> Alice minera o primeiro bloco (recebe a recompensa)\n", .{});
    try mine(out, io, &chain, alice);

    try out.print("\n>> Alice envia 30 para Bob e 5 para o Minerador\n", .{});
    try submit(out, &chain, try alice.send(bob.address(), 30));
    try submit(out, &chain, try alice.send(miner.address(), 5));

    try out.print("\n>> Bob tenta gastar mais do que tem (saldo confirmado = 0)\n", .{});
    try submit(out, &chain, try bob.send(alice.address(), 100));

    try out.print("\n>> Bob tenta forjar uma transacao gastando o dinheiro de Alice\n", .{});
    var forged: bc.Transaction = .{ .from = alice.address(), .to = bob.address(), .amount = 10, .nonce = 42 };
    forged.signature = (try bob.send(bob.address(), 1)).signature;
    try submit(out, &chain, forged);

    try out.print("\n>> Minerador fecha o bloco com as transacoes pendentes\n", .{});
    try mine(out, io, &chain, miner);

    try out.print("\n>> Bob repassa 12 para o Minerador\n", .{});
    try submit(out, &chain, try bob.send(miner.address(), 12));
    try mine(out, io, &chain, miner);

    try printChain(out, &chain);

    try out.print("\nSaldos:\n", .{});
    for (wallets) |w| try out.print("  {s:<10} {d:>4} moedas\n", .{ w.name, chain.balanceOf(w.address()) });

    try out.print("\nValidando a cadeia... ", .{});
    try report(out, chain.validate());

    try out.print("\n>> Ataque: alterando o valor da transacao Alice -> Bob de 30 para 3000\n", .{});
    const tx = &chain.blocks.items[2].transactions[1];
    tx.amount = 3000;
    try out.print("Validando a cadeia... ", .{});
    try report(out, chain.validate());

    try out.print(">> Ataque: reminerando o bloco adulterado\n", .{});
    _ = chain.blocks.items[2].mine(chain.difficulty);
    try out.print("Validando a cadeia... ", .{});
    try report(out, chain.validate());

    tx.amount = 30;
    _ = chain.blocks.items[2].mine(chain.difficulty);
    try out.print(">> Valor restaurado: o bloco volta a ter exatamente o hash original\n", .{});
    try out.print("Validando a cadeia... ", .{});
    try report(out, chain.validate());
}

fn now(io: Io) i64 {
    return Io.Clock.real.now(io).toSeconds();
}

fn submit(out: *Io.Writer, chain: *Blockchain, tx: bc.Transaction) !void {
    if (chain.addTransaction(tx)) {
        try out.print("  [ok]    tx {s} aceita na mempool ({d} moedas)\n", .{ bc.shortHex(tx.hash()), tx.amount });
    } else |err| switch (err) {
        error.OutOfMemory => return err,
        else => try out.print("  [recusada] tx {s}: {s}\n", .{ bc.shortHex(tx.hash()), @errorName(err) }),
    }
}

fn mine(out: *Io.Writer, io: Io, chain: *Blockchain, miner: Wallet) !void {
    const start = Io.Clock.awake.now(io);
    const block = try chain.minePending(miner.address(), now(io));
    const elapsed_ms = Io.Clock.awake.now(io).toMilliseconds() - start.toMilliseconds();
    try out.print("  bloco #{d} minerado por {s} em {d} ms (nonce {d}, {d} tx)\n", .{
        block.index, miner.name, elapsed_ms, block.nonce, block.transactions.len,
    });
    try out.flush();
}

fn printChain(out: *Io.Writer, chain: *const Blockchain) !void {
    try out.print("\nCadeia ({d} blocos):\n", .{chain.blocks.items.len});
    for (chain.blocks.items) |block| {
        try out.print("  #{d}  hash {s}\n      prev {s}  nonce {d}\n", .{
            block.index, bc.hex(block.hash), bc.shortHex(block.prev_hash), block.nonce,
        });
        for (block.transactions) |t| {
            const from: [16]u8 = if (t.from) |f| bc.shortHex(f) else "coinbase        ".*;
            try out.print("      {s} -> {s}  {d:>4}\n", .{ from, bc.shortHex(t.to), t.amount });
        }
    }
}

fn report(out: *Io.Writer, result: Blockchain.ValidationError!void) !void {
    if (result) {
        try out.print("VALIDA\n", .{});
    } else |err| {
        try out.print("INVALIDA ({s})\n", .{@errorName(err)});
    }
}