//! C ABI for the playground: Go HTTP talks to this shared library.
const std = @import("std");
const bc = @import("blockchain");

const Blockchain = bc.Blockchain;
const Wallet = bc.Wallet;
const Address = bc.Address;
const Transaction = bc.Transaction;

//
var chain: ?Blockchain = null;
var wallet_by_addr: std.AutoHashMapUnmanaged(Address, Wallet) = .empty;

/// Simple spinlock (Zig 0.16 Thread.Mutex was removed; Io.Mutex needs an Io).
var lock_state: std.atomic.Value(u8) = .init(0);

fn lock() void {
    while (lock_state.cmpxchgWeak(0, 1, .acquire, .monotonic) != null) {
        std.atomic.spinLoopHint();
    }
}

fn unlock() void {
    lock_state.store(0, .release);
}

fn allocator() std.mem.Allocator {
    return std.heap.smp_allocator;
}

fn setErr(err_buf: ?[*]u8, err_len: usize, msg: []const u8) void {
    const buf = err_buf orelse return;
    if (err_len == 0) return;
    const n = @min(msg.len, err_len - 1);
    @memcpy(buf[0..n], msg[0..n]);
    buf[n] = 0;
}

export fn zig_engine_create(difficulty: u8, reward: u64, genesis_ts: i64) callconv(.c) i32 {
    lock();
    defer unlock();
    if (chain != null) return -1;
    const gpa = allocator();
    chain = Blockchain.init(gpa, .{
        .difficulty = difficulty,
        .mining_reward = reward,
        .genesis_timestamp = genesis_ts,
    }) catch return -2;
    return 0;
}

export fn zig_engine_destroy() callconv(.c) void {
    lock();
    defer unlock();
    if (chain) |*c| {
        c.deinit();
        chain = null;
    }
    wallet_by_addr.deinit(allocator());
    wallet_by_addr = .empty;
}

/// Register wallet from 32-byte seed; writes address to out_addr.
export fn zig_wallet_register(seed: *const [32]u8, out_addr: *[32]u8) callconv(.c) i32 {
    lock();
    defer unlock();
    var w = Wallet.fromSeed("", seed.*) catch return -1;
    const addr = w.address();
    out_addr.* = addr;
    const gop = wallet_by_addr.getOrPut(allocator(), addr) catch return -2;
    if (!gop.found_existing) {
        gop.value_ptr.* = w;
    } else {
        gop.value_ptr.key_pair = w.key_pair;
    }
    return 0;
}

export fn zig_balance(addr: *const [32]u8) callconv(.c) u64 {
    lock();
    defer unlock();
    const c = chain orelse return 0;
    return c.balanceOf(addr.*);
}

export fn zig_pending_count() callconv(.c) u64 {
    lock();
    defer unlock();
    const c = chain orelse return 0;
    return c.pending.items.len;
}

export fn zig_block_count() callconv(.c) u64 {
    lock();
    defer unlock();
    const c = chain orelse return 0;
    return c.blocks.items.len;
}

export fn zig_validate(err_buf: ?[*]u8, err_len: usize) callconv(.c) i32 {
    lock();
    defer unlock();
    const c = chain orelse {
        setErr(err_buf, err_len, "engine not initialized");
        return -1;
    };
    c.validate() catch |err| {
        setErr(err_buf, err_len, @errorName(err));
        return 1;
    };
    return 0;
}

export fn zig_submit_tx(
    from_addr: *const [32]u8,
    to_addr: *const [32]u8,
    amount: u64,
    err_buf: ?[*]u8,
    err_len: usize,
) callconv(.c) i32 {
    lock();
    defer unlock();
    const c = &(chain orelse {
        setErr(err_buf, err_len, "engine not initialized");
        return -1;
    });
    const w = wallet_by_addr.getPtr(from_addr.*) orelse {
        setErr(err_buf, err_len, "unknown wallet");
        return -2;
    };
    const tx = w.send(to_addr.*, amount) catch |err| {
        setErr(err_buf, err_len, @errorName(err));
        return -3;
    };
    c.addTransaction(tx) catch |err| {
        if (w.next_nonce > 0) w.next_nonce -= 1;
        setErr(err_buf, err_len, @errorName(err));
        return -4;
    };
    return 0;
}

export fn zig_mine(miner_addr: *const [32]u8, timestamp: i64, err_buf: ?[*]u8, err_len: usize) callconv(.c) i32 {
    lock();
    defer unlock();
    const c = &(chain orelse {
        setErr(err_buf, err_len, "engine not initialized");
        return -1;
    });
    _ = c.minePending(miner_addr.*, timestamp) catch |err| {
        setErr(err_buf, err_len, @errorName(err));
        return -2;
    };
    return 0;
}

/// Write chain summary JSON into buf; returns length or negative error.
export fn zig_chain_json(buf: [*]u8, buflen: usize) callconv(.c) i32 {
    lock();
    defer unlock();
    const c = chain orelse return -1;
    const gpa = allocator();
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);

    list.print(gpa, "{{\"length\":{d},\"difficulty\":{d},\"reward\":{d},\"pending\":{d},\"chain\":[", .{
        c.blocks.items.len,
        c.difficulty,
        c.mining_reward,
        c.pending.items.len,
    }) catch return -2;

    for (c.blocks.items, 0..) |block, bi| {
        if (bi > 0) list.appendSlice(gpa, ",") catch return -2;
        const hash_hex = bc.hex(block.hash);
        const prev_hex = bc.hex(block.prev_hash);
        list.print(gpa, "{{\"index\":{d},\"timestamp\":{d},\"nonce\":{d},\"hash\":\"{s}\",\"prev_hash\":\"{s}\",\"transactions\":[", .{
            block.index,
            block.timestamp,
            block.nonce,
            hash_hex[0..],
            prev_hex[0..],
        }) catch return -2;
        for (block.transactions, 0..) |tx, ti| {
            if (ti > 0) list.appendSlice(gpa, ",") catch return -2;
            const to_hex = bc.hex(tx.to);
            if (tx.from) |from| {
                const from_hex = bc.hex(from);
                list.print(gpa, "{{\"from\":\"{s}\",\"to\":\"{s}\",\"amount\":{d},\"nonce\":{d},\"coinbase\":false}}", .{
                    from_hex[0..],
                    to_hex[0..],
                    tx.amount,
                    tx.nonce,
                }) catch return -2;
            } else {
                list.print(gpa, "{{\"from\":null,\"to\":\"{s}\",\"amount\":{d},\"nonce\":{d},\"coinbase\":true}}", .{
                    to_hex[0..],
                    tx.amount,
                    tx.nonce,
                }) catch return -2;
            }
        }
        list.appendSlice(gpa, "]}") catch return -2;
    }
    list.appendSlice(gpa, "]}") catch return -2;

    if (list.items.len + 1 > buflen) return -3;
    @memcpy(buf[0..list.items.len], list.items);
    buf[list.items.len] = 0;
    return @intCast(list.items.len);
}

export fn zig_pending_json(buf: [*]u8, buflen: usize) callconv(.c) i32 {
    lock();
    defer unlock();
    const c = chain orelse return -1;
    const gpa = allocator();
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    list.appendSlice(gpa, "[") catch return -2;
    for (c.pending.items, 0..) |tx, ti| {
        if (ti > 0) list.appendSlice(gpa, ",") catch return -2;
        const to_hex = bc.hex(tx.to);
        if (tx.from) |from| {
            const from_hex = bc.hex(from);
            list.print(gpa, "{{\"from\":\"{s}\",\"to\":\"{s}\",\"amount\":{d},\"nonce\":{d}}}", .{
                from_hex[0..],
                to_hex[0..],
                tx.amount,
                tx.nonce,
            }) catch return -2;
        } else {
            list.print(gpa, "{{\"from\":null,\"to\":\"{s}\",\"amount\":{d},\"nonce\":{d}}}", .{
                to_hex[0..],
                tx.amount,
                tx.nonce,
            }) catch return -2;
        }
    }
    list.appendSlice(gpa, "]") catch return -2;
    if (list.items.len + 1 > buflen) return -3;
    @memcpy(buf[0..list.items.len], list.items);
    buf[list.items.len] = 0;
    return @intCast(list.items.len);
}