use ed25519_dalek::SigningKey;

use crate::transaction::{Address, SignError, Transaction};

/// Par de chaves Ed25519 que cria e assina transações.
pub struct Wallet {
    pub name: &'static str,
    key: SigningKey,
    next_nonce: u64,
}

impl Wallet {
    /// Gera uma carteira nova com uma semente aleatória do sistema operacional.
    pub fn generate(name: &'static str) -> Self {
        let mut seed = [0u8; 32];
        getrandom::fill(&mut seed).expect("falha ao obter entropia do sistema");
        Self::from_seed(name, seed)
    }

    pub fn from_seed(name: &'static str, seed: [u8; 32]) -> Self {
        Self { name, key: SigningKey::from_bytes(&seed), next_nonce: 0 }
    }

    pub fn address(&self) -> Address {
        self.key.verifying_key().to_bytes()
    }

    /// Cria uma transação já assinada para `to`.
    pub fn send(&mut self, to: Address, amount: u64) -> Result<Transaction, SignError> {
        let mut tx = Transaction {
            from: Some(self.address()),
            to,
            amount,
            nonce: self.next_nonce,
            signature: None,
        };
        tx.sign(&self.key)?;
        self.next_nonce += 1;
        Ok(tx)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn carteira_gera_transacoes_assinadas_com_nonces_distintos() {
        let mut alice = Wallet::from_seed("alice", [1; 32]);
        let bob = Wallet::from_seed("bob", [2; 32]);

        let t1 = alice.send(bob.address(), 5).unwrap();
        let t2 = alice.send(bob.address(), 5).unwrap();
        assert!(t1.has_valid_signature());
        assert!(t2.has_valid_signature());
        assert_ne!(t1.hash(), t2.hash());
    }
}
