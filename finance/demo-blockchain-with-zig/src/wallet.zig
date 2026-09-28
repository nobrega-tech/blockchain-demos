const std = @import("std");
const Ed25519 = std.crypto.sign.Ed25519;
const Transaction = @import("transaction.zig").Transaction;
const Address = @import("transaction.zig").Address;

/// Par de chaves Ed25519 que cria e assina transações.
pub const Wallet = struct {
    name: []const u8,
    key_pair: Ed25519.KeyPair,
    next_nonce: u64 = 0,

    pub fn generate(io: std.Io, name: []const u8) Wallet {
        return .{ .name = name, .key_pair = .generate(io) };
    }

    pub fn fromSeed(name: []const u8, seed: [Ed25519.KeyPair.seed_length]u8) !Wallet {
        return .{ .name = name, .key_pair = try .generateDeterministic(seed) };
    }

    pub fn address(self: Wallet) Address {
        return self.key_pair.public_key.toBytes();
    }

    /// Cria uma transação já assinada para `to`.
    pub fn send(self: *Wallet, to: Address, amount: u64) !Transaction {
        var tx: Transaction = .{
            .from = self.address(),
            .to = to,
            .amount = amount,
            .nonce = self.next_nonce,
        };
        try tx.sign(self.key_pair);
        self.next_nonce += 1;
        return tx;
    }
};

test "carteira gera transações assinadas com nonces distintos" {
    var alice = try Wallet.fromSeed("alice", @splat(1));
    const bob = try Wallet.fromSeed("bob", @splat(2));

    const t1 = try alice.send(bob.address(), 5);
    const t2 = try alice.send(bob.address(), 5);
    try std.testing.expect(t1.hasValidSignature());
    try std.testing.expect(t2.hasValidSignature());
    try std.testing.expect(!std.mem.eql(u8, &t1.hash(), &t2.hash()));
}
