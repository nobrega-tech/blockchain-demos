const std = @import("std");
const hash_mod = @import("hash.zig");
const Hash = hash_mod.Hash;
const Sha256 = hash_mod.Sha256;
const Transaction = @import("transaction.zig").Transaction;

pub const Block = struct {
    /// Limite de transacoes por bloco (incluindo a coinbase).
    pub const max_transactions = 256;

    index: u64,
    timestamp: i64,
    prev_hash: Hash,
    /// Pertence ao bloco (liberado por `Blockchain.deinit`).
    transactions: []Transaction,
    nonce: u64 = 0,
    hash: Hash = @splat(0),

    /// Raiz de Merkle das transacoes: qualquer alteracao em qualquer
    /// transacao muda a raiz e, portanto, o hash do bloco.
    pub fn merkleRoot(self: Block) Hash {
        return computeMerkleRoot(self.transactions);
    }

    pub fn computeHash(self: Block) Hash {
        var h = Sha256.init(.{});
        hash_mod.updateInt(&h, u64, self.index);
        hash_mod.updateInt(&h, i64, self.timestamp);
        h.update(&self.prev_hash);
        h.update(&self.merkleRoot());
        hash_mod.updateInt(&h, u64, self.nonce);
        return h.finalResult();
    }

    /// Prova de trabalho: incrementa o nonce ate o hash ter pelo menos
    /// `difficulty` bits zero no inicio. Retorna o numero de hashes tentados.
    pub fn mine(self: *Block, difficulty: u8) u64 {
        // O conteudo nao muda durante a mineracao: calcula o prefixo uma vez.
        var prefix = Sha256.init(.{});
        hash_mod.updateInt(&prefix, u64, self.index);
        hash_mod.updateInt(&prefix, i64, self.timestamp);
        prefix.update(&self.prev_hash);
        prefix.update(&self.merkleRoot());

        self.nonce = 0;
        while (true) : (self.nonce += 1) {
            var h = prefix;
            hash_mod.updateInt(&h, u64, self.nonce);
            const candidate = h.finalResult();
            if (hash_mod.leadingZeroBits(candidate) >= difficulty) {
                self.hash = candidate;
                return self.nonce + 1;
            }
        }
    }

    pub fn hasValidProofOfWork(self: Block, difficulty: u8) bool {
        const actual = self.computeHash();
        return std.mem.eql(u8, &actual, &self.hash) and
            hash_mod.leadingZeroBits(actual) >= difficulty;
    }
};

fn computeMerkleRoot(transactions: []const Transaction) Hash {
    std.debug.assert(transactions.len <= Block.max_transactions);
    if (transactions.len == 0) return @splat(0);

    var buf: [Block.max_transactions]Hash = undefined;
    var level = buf[0..transactions.len];
    for (transactions, level) |tx, *leaf| leaf.* = tx.hash();

    // Combina pares ate restar um unico hash; um no impar e pareado consigo mesmo.
    while (level.len > 1) {
        var next_len: usize = 0;
        var j: usize = 0;
        while (j < level.len) : (j += 2) {
            const right = if (j + 1 < level.len) level[j + 1] else level[j];
            var h = Sha256.init(.{});
            h.update(&level[j]);
            h.update(&right);
            level[next_len] = h.finalResult();
            next_len += 1;
        }
        level = level[0..next_len];
    }
    return level[0];
}

test "mineracao respeita a dificuldade e detecta adulteracao" {
    var txs = [_]Transaction{.coinbase(@splat(7), 50, 1)};
    var block: Block = .{
        .index = 1,
        .timestamp = 1_700_000_000,
        .prev_hash = @splat(0),
        .transactions = &txs,
    };
    _ = block.mine(12);
    try std.testing.expect(block.hasValidProofOfWork(12));

    txs[0].amount = 5_000;
    try std.testing.expect(!block.hasValidProofOfWork(12));
}

test "raiz de Merkle muda com qualquer transacao" {
    var txs: [5]Transaction = undefined;
    for (&txs, 0..) |*tx, n| tx.* = .coinbase(@splat(1), 10, n);
    const before = computeMerkleRoot(&txs);
    txs[4].amount = 11;
    try std.testing.expect(!std.mem.eql(u8, &before, &computeMerkleRoot(&txs)));
}