//! Uma blockchain didática: transações assinadas com Ed25519, blocos
//! encadeados por SHA-256 e consenso por prova de trabalho (proof-of-work).

pub const Hash = @import("hash.zig").Hash;
pub const Address = @import("transaction.zig").Address;
pub const Transaction = @import("transaction.zig").Transaction;
pub const Wallet = @import("wallet.zig").Wallet;
pub const Block = @import("block.zig").Block;
pub const Blockchain = @import("blockchain.zig").Blockchain;

pub const hex = @import("hash.zig").hex;
pub const shortHex = @import("hash.zig").shortHex;

test {
    _ = @import("hash.zig");
    _ = @import("transaction.zig");
    _ = @import("wallet.zig");
    _ = @import("block.zig");
    _ = @import("blockchain.zig");
}
