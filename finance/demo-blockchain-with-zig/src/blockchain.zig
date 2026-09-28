const std = @import("std");
const Allocator = std.mem.Allocator;
const Block = @import("block.zig").Block;
const Transaction = @import("transaction.zig").Transaction;
const Address = @import("transaction.zig").Address;
const Hash = @import("hash.zig").Hash;

pub const Blockchain = struct {
    gpa: Allocator,
    blocks: std.ArrayList(Block) = .empty,
    /// Transações aceitas aguardando o próximo bloco (mempool).
    pending: std.ArrayList(Transaction) = .empty,
    /// Bits zero exigidos no início do hash de cada bloco.
    difficulty: u8,
    mining_reward: u64,

    pub const Options = struct {
        difficulty: u8 = 16,
        mining_reward: u64 = 50,
        genesis_timestamp: i64 = 1_700_000_000,
    };

    pub const TransactionError = error{
        InvalidSignature,
        CoinbaseNotAllowed,
        ZeroAmount,
        InsufficientFunds,
        DuplicateTransaction,
        MempoolFull,
    } || Allocator.Error;

    pub const ValidationError = error{
        InvalidGenesis,
        InvalidIndex,
        BrokenLink,
        InvalidProofOfWork,
        InvalidCoinbase,
        InvalidSignature,
        InsufficientFunds,
        DuplicateTransaction,
    } || Allocator.Error;

    pub fn init(gpa: Allocator, options: Options) Allocator.Error!Blockchain {
        var chain: Blockchain = .{
            .gpa = gpa,
            .difficulty = options.difficulty,
            .mining_reward = options.mining_reward,
        };
        errdefer chain.deinit();

        var genesis: Block = .{
            .index = 0,
            .timestamp = options.genesis_timestamp,
            .prev_hash = @splat(0),
            .transactions = try gpa.alloc(Transaction, 0),
        };
        _ = genesis.mine(chain.difficulty);
        try chain.blocks.append(gpa, genesis);
        return chain;
    }

    pub fn deinit(self: *Blockchain) void {
        for (self.blocks.items) |block| self.gpa.free(block.transactions);
        self.blocks.deinit(self.gpa);
        self.pending.deinit(self.gpa);
        self.* = undefined;
    }

    pub fn latest(self: *const Blockchain) *const Block {
        return &self.blocks.items[self.blocks.items.len - 1];
    }

    /// Saldo confirmado (apenas blocos minerados).
    pub fn balanceOf(self: *const Blockchain, address: Address) u64 {
        var balance: u64 = 0;
        for (self.blocks.items) |block| {
            for (block.transactions) |tx| {
                if (std.mem.eql(u8, &tx.to, &address)) balance += tx.amount;
                if (tx.from) |from| {
                    if (std.mem.eql(u8, &from, &address)) balance -= tx.amount;
                }
            }
        }
        return balance;
    }

    /// Saldo confirmado menos o que já está comprometido na mempool.
    pub fn spendableBalance(self: *const Blockchain, address: Address) u64 {
        var balance = self.balanceOf(address);
        for (self.pending.items) |tx| {
            if (tx.from) |from| {
                if (std.mem.eql(u8, &from, &address)) balance -= tx.amount;
            }
        }
        return balance;
    }

    /// Valida e coloca uma transação na mempool.
    pub fn addTransaction(self: *Blockchain, tx: Transaction) TransactionError!void {
        const from = tx.from orelse return error.CoinbaseNotAllowed;
        if (tx.amount == 0) return error.ZeroAmount;
        if (!tx.hasValidSignature()) return error.InvalidSignature;
        if (self.pending.items.len + 1 >= Block.max_transactions) return error.MempoolFull;
        if (self.containsTransaction(tx.hash())) return error.DuplicateTransaction;
        if (self.spendableBalance(from) < tx.amount) return error.InsufficientFunds;
        try self.pending.append(self.gpa, tx);
    }

    /// Minera um bloco com a coinbase para `miner` e todas as transações
    /// pendentes, adicionando-o à cadeia.
    pub fn minePending(self: *Blockchain, miner: Address, timestamp: i64) Allocator.Error!*const Block {
        const index: u64 = self.blocks.items.len;
        const txs = try self.gpa.alloc(Transaction, self.pending.items.len + 1);
        errdefer self.gpa.free(txs);
        txs[0] = .coinbase(miner, self.mining_reward, index);
        @memcpy(txs[1..], self.pending.items);

        var block: Block = .{
            .index = index,
            .timestamp = timestamp,
            .prev_hash = self.latest().hash,
            .transactions = txs,
        };
        _ = block.mine(self.difficulty);

        try self.blocks.append(self.gpa, block);
        self.pending.clearRetainingCapacity();
        return self.latest();
    }

    /// Revalida a cadeia inteira do zero: encadeamento, prova de trabalho,
    /// assinaturas, regras da coinbase e saldos.
    pub fn validate(self: *const Blockchain) ValidationError!void {
        const blocks = self.blocks.items;
        if (blocks.len == 0) return error.InvalidGenesis;

        const genesis = blocks[0];
        if (genesis.index != 0 or genesis.transactions.len != 0 or
            !std.mem.eql(u8, &genesis.prev_hash, &@as(Hash, @splat(0))) or
            !genesis.hasValidProofOfWork(self.difficulty))
            return error.InvalidGenesis;

        var balances: std.AutoHashMapUnmanaged(Address, u64) = .empty;
        defer balances.deinit(self.gpa);
        var seen: std.AutoHashMapUnmanaged(Hash, void) = .empty;
        defer seen.deinit(self.gpa);

        for (blocks[1..], blocks[0 .. blocks.len - 1]) |block, prev| {
            if (block.index != prev.index + 1) return error.InvalidIndex;
            if (!std.mem.eql(u8, &block.prev_hash, &prev.hash)) return error.BrokenLink;
            if (!block.hasValidProofOfWork(self.difficulty)) return error.InvalidProofOfWork;

            const txs = block.transactions;
            if (txs.len == 0 or !txs[0].isCoinbase() or
                txs[0].amount != self.mining_reward or txs[0].nonce != block.index)
                return error.InvalidCoinbase;

            for (txs, 0..) |tx, i| {
                if (i > 0 and tx.isCoinbase()) return error.InvalidCoinbase;
                if (!tx.hasValidSignature()) return error.InvalidSignature;

                const gop = try seen.getOrPut(self.gpa, tx.hash());
                if (gop.found_existing) return error.DuplicateTransaction;

                if (tx.from) |from| {
                    const sender = balances.getPtr(from) orelse return error.InsufficientFunds;
                    if (sender.* < tx.amount) return error.InsufficientFunds;
                    sender.* -= tx.amount;
                }
                const receiver = try balances.getOrPutValue(self.gpa, tx.to, 0);
                receiver.value_ptr.* += tx.amount;
            }
        }
    }

    fn containsTransaction(self: *const Blockchain, tx_hash: Hash) bool {
        for (self.pending.items) |p| {
            if (std.mem.eql(u8, &p.hash(), &tx_hash)) return true;
        }
        for (self.blocks.items) |block| {
            for (block.transactions) |t| {
                if (std.mem.eql(u8, &t.hash(), &tx_hash)) return true;
            }
        }
        return false;
    }
};

const testing = std.testing;
const Wallet = @import("wallet.zig").Wallet;

fn testChain() !Blockchain {
    return Blockchain.init(testing.allocator, .{ .difficulty = 8 });
}

test "fluxo completo: minerar, transferir, validar" {
    var chain = try testChain();
    defer chain.deinit();

    var alice = try Wallet.fromSeed("alice", @splat(1));
    const bob = try Wallet.fromSeed("bob", @splat(2));

    _ = try chain.minePending(alice.address(), 1);
    try testing.expectEqual(@as(u64, 50), chain.balanceOf(alice.address()));

    try chain.addTransaction(try alice.send(bob.address(), 20));
    _ = try chain.minePending(bob.address(), 2);

    try testing.expectEqual(@as(u64, 30), chain.balanceOf(alice.address()));
    try testing.expectEqual(@as(u64, 70), chain.balanceOf(bob.address()));
    try chain.validate();
}

test "rejeita gasto maior que o saldo, inclusive somando a mempool" {
    var chain = try testChain();
    defer chain.deinit();
    var alice = try Wallet.fromSeed("alice", @splat(1));
    const bob = try Wallet.fromSeed("bob", @splat(2));

    try testing.expectError(error.InsufficientFunds, chain.addTransaction(try alice.send(bob.address(), 1)));

    _ = try chain.minePending(alice.address(), 1);
    try chain.addTransaction(try alice.send(bob.address(), 40));
    try testing.expectError(error.InsufficientFunds, chain.addTransaction(try alice.send(bob.address(), 20)));
}

test "rejeita replay e assinatura forjada" {
    var chain = try testChain();
    defer chain.deinit();
    var alice = try Wallet.fromSeed("alice", @splat(1));
    var mallory = try Wallet.fromSeed("mallory", @splat(3));

    _ = try chain.minePending(alice.address(), 1);
    const tx = try alice.send(mallory.address(), 10);
    try chain.addTransaction(tx);
    try testing.expectError(error.DuplicateTransaction, chain.addTransaction(tx));
    _ = try chain.minePending(mallory.address(), 2);
    try testing.expectError(error.DuplicateTransaction, chain.addTransaction(tx));

    // Mallory tenta gastar o dinheiro de Alice assinando com a própria chave.
    var forged: Transaction = .{ .from = alice.address(), .to = mallory.address(), .amount = 30, .nonce = 99 };
    forged.signature = (try mallory.send(mallory.address(), 1)).signature;
    try testing.expectError(error.InvalidSignature, chain.addTransaction(forged));
}

test "adulterar um bloco invalida a cadeia" {
    var chain = try testChain();
    defer chain.deinit();
    var alice = try Wallet.fromSeed("alice", @splat(1));
    const bob = try Wallet.fromSeed("bob", @splat(2));

    _ = try chain.minePending(alice.address(), 1);
    try chain.addTransaction(try alice.send(bob.address(), 10));
    _ = try chain.minePending(alice.address(), 2);
    _ = try chain.minePending(alice.address(), 3);
    try chain.validate();

    const tampered = &chain.blocks.items[2];

    // Alterar o valor muda o hash do bloco: a prova de trabalho não bate mais.
    tampered.transactions[1].amount = 45;
    try testing.expectError(error.InvalidProofOfWork, chain.validate());

    // Reminerar o bloco não basta: a assinatura de Alice não cobre o novo valor.
    _ = tampered.mine(chain.difficulty);
    try testing.expectError(error.InvalidSignature, chain.validate());

    // Restaurando a transação e reminerando, o bloco seguinte ainda aponta
    // para o hash antigo — seria preciso refazer o trabalho da cadeia toda.
    tampered.transactions[1].amount = 10;
    tampered.timestamp = 999;
    _ = tampered.mine(chain.difficulty);
    try testing.expectError(error.BrokenLink, chain.validate());
}
