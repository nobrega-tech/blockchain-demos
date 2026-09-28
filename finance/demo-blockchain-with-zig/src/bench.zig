const std = @import("std");
const Io = std.Io;
const bc = @import("blockchain");

const Blockchain = bc.Blockchain;
const Block = bc.Block;
const Wallet = bc.Wallet;
const Transaction = bc.Transaction;

pub const Args = struct {
    difficulty: u8 = 16,
    blocks: u32 = 5,
    txs_per_block: u32 = 0,
};

pub fn parseArgs(args: []const []const u8) !Args {
    var out: Args = .{};
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--difficulty")) {
            i += 1;
            if (i >= args.len) return error.MissingDifficulty;
            out.difficulty = try std.fmt.parseInt(u8, args[i], 10);
        } else if (std.mem.eql(u8, args[i], "--blocks")) {
            i += 1;
            if (i >= args.len) return error.MissingBlocks;
            out.blocks = try std.fmt.parseInt(u32, args[i], 10);
        } else if (std.mem.eql(u8, args[i], "--txs-per-block")) {
            i += 1;
            if (i >= args.len) return error.MissingTxs;
            out.txs_per_block = try std.fmt.parseInt(u32, args[i], 10);
        } else {
            return error.UnknownFlag;
        }
    }
    return out;
}

pub fn run(gpa: std.mem.Allocator, io: Io, out: *Io.Writer, args: Args) !void {
    var miner = try Wallet.fromSeed("bench-miner", @splat(9));
    const sink = try Wallet.fromSeed("bench-sink", @splat(8));

    var chain = try Blockchain.init(gpa, .{
        .difficulty = args.difficulty,
        .genesis_timestamp = 1_700_000_000,
    });
    defer chain.deinit();

    var hashes: u64 = 0;
    const start = Io.Clock.awake.now(io);

    var b: u32 = 0;
    while (b < args.blocks) : (b += 1) {
        if (args.txs_per_block > 0) {
            const spendable = chain.spendableBalance(miner.address());
            const want: u64 = args.txs_per_block;
            const cap: u64 = Block.max_transactions - 1;
            const n = @min(want, @min(spendable, cap));
            var t: u64 = 0;
            while (t < n) : (t += 1) {
                const tx = try miner.send(sink.address(), 1);
                try chain.addTransaction(tx);
            }
        }

        const index: u64 = chain.blocks.items.len;
        const txs = try gpa.alloc(Transaction, chain.pending.items.len + 1);
        errdefer gpa.free(txs);
        txs[0] = .coinbase(miner.address(), chain.mining_reward, index);
        @memcpy(txs[1..], chain.pending.items);

        var block: Block = .{
            .index = index,
            .timestamp = 1_700_000_000 + @as(i64, @intCast(b)) + 1,
            .prev_hash = chain.latest().hash,
            .transactions = txs,
        };
        hashes += block.mine(chain.difficulty);
        try chain.blocks.append(gpa, block);
        chain.pending.clearRetainingCapacity();
    }

    const elapsed_ms = Io.Clock.awake.now(io).toMilliseconds() - start.toMilliseconds();
    const secs: f64 = @as(f64, @floatFromInt(elapsed_ms)) / 1000.0;
    const hps: f64 = if (secs > 0) @as(f64, @floatFromInt(hashes)) / secs else 0;

    try out.print(
        "{{\"impl\":\"zig\",\"difficulty\":{d},\"difficulty_unit\":\"bits\",\"blocks\":{d},\"txs_per_block\":{d},\"total_ms\":{d},\"hashes\":{d},\"hashes_per_sec\":{d:.6}}}\n",
        .{ args.difficulty, args.blocks, args.txs_per_block, elapsed_ms, hashes, hps },
    );
}