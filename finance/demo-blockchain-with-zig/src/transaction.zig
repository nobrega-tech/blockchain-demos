const std = @import("std");
const Ed25519 = std.crypto.sign.Ed25519;
const hash_mod = @import("hash.zig");
const Hash = hash_mod.Hash;
const Sha256 = hash_mod.Sha256;

/// Um endereço é a chave pública Ed25519 do dono da carteira.
pub const Address = [Ed25519.PublicKey.encoded_length]u8;

pub const Transaction = struct {
    /// `null` indica uma transação coinbase (recompensa de mineração).
    from: ?Address,
    to: Address,
    amount: u64,
    /// Diferencia transações idênticas do mesmo remetente (evita replay).
    nonce: u64,
    signature: ?[Ed25519.Signature.encoded_length]u8 = null,

    pub fn coinbase(to: Address, amount: u64, block_index: u64) Transaction {
        return .{ .from = null, .to = to, .amount = amount, .nonce = block_index };
    }

    pub fn isCoinbase(self: Transaction) bool {
        return self.from == null;
    }

    /// Hash do conteúdo da transação (sem a assinatura). É o que é assinado.
    pub fn hash(self: Transaction) Hash {
        var h = Sha256.init(.{});
        if (self.from) |from| {
            h.update(&[_]u8{1});
            h.update(&from);
        } else {
            h.update(&[_]u8{0});
        }
        h.update(&self.to);
        hash_mod.updateInt(&h, u64, self.amount);
        hash_mod.updateInt(&h, u64, self.nonce);
        return h.finalResult();
    }

    pub fn sign(self: *Transaction, key_pair: Ed25519.KeyPair) !void {
        const from = self.from orelse return error.CannotSignCoinbase;
        if (!std.mem.eql(u8, &from, &key_pair.public_key.toBytes()))
            return error.KeyDoesNotMatchSender;
        const digest = self.hash();
        const sig = try key_pair.sign(&digest, null);
        self.signature = sig.toBytes();
    }

    /// Verifica a assinatura. Coinbases não têm assinatura; suas regras
    /// são verificadas no nível do bloco.
    pub fn hasValidSignature(self: Transaction) bool {
        const from = self.from orelse return self.signature == null;
        const sig_bytes = self.signature orelse return false;
        const public_key = Ed25519.PublicKey.fromBytes(from) catch return false;
        const sig = Ed25519.Signature.fromBytes(sig_bytes);
        const digest = self.hash();
        sig.verify(&digest, public_key) catch return false;
        return true;
    }
};

test "assinatura válida e adulteração detectada" {
    const alice = Ed25519.KeyPair.generateDeterministic(@splat(1)) catch unreachable;
    const bob = Ed25519.KeyPair.generateDeterministic(@splat(2)) catch unreachable;

    var tx: Transaction = .{
        .from = alice.public_key.toBytes(),
        .to = bob.public_key.toBytes(),
        .amount = 10,
        .nonce = 0,
    };
    try std.testing.expect(!tx.hasValidSignature());
    try tx.sign(alice);
    try std.testing.expect(tx.hasValidSignature());

    tx.amount = 1_000;
    try std.testing.expect(!tx.hasValidSignature());
}

test "não é possível assinar com a chave de outra pessoa" {
    const alice = Ed25519.KeyPair.generateDeterministic(@splat(1)) catch unreachable;
    const bob = Ed25519.KeyPair.generateDeterministic(@splat(2)) catch unreachable;
    var tx: Transaction = .{
        .from = alice.public_key.toBytes(),
        .to = bob.public_key.toBytes(),
        .amount = 10,
        .nonce = 0,
    };
    try std.testing.expectError(error.KeyDoesNotMatchSender, tx.sign(bob));
}
