//! Uma blockchain didática: transações assinadas com Ed25519, blocos
//! encadeados por SHA-256 e consenso por prova de trabalho (proof-of-work).

pub mod block;
pub mod blockchain;
pub mod hash;
pub mod transaction;
pub mod wallet;

pub use block::Block;
pub use blockchain::{Blockchain, Options, TransactionError, ValidationError};
pub use hash::{Hash, hex, short_hex};
pub use transaction::{Address, Transaction};
pub use wallet::Wallet;
