use ed25519_dalek::{Signature, Signer, SigningKey, Verifier, VerifyingKey};

use crate::hash::{Digest, Hash, Sha256, finish};

/// Um endereço é a chave pública Ed25519 do dono da carteira.
pub type Address = [u8; 32];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SignError {
    KeyDoesNotMatchSender,
    CannotSignCoinbase,
}

impl std::fmt::Display for SignError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        std::fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for SignError {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Transaction {
    /// `None` indica uma transação coinbase (recompensa de mineração).
    pub from: Option<Address>,
    pub to: Address,
    pub amount: u64,
    /// Diferencia transações idênticas do mesmo remetente (evita replay).
    pub nonce: u64,
    pub signature: Option<[u8; 64]>,
}

impl Transaction {
    pub fn coinbase(to: Address, amount: u64, block_index: u64) -> Self {
        Self { from: None, to, amount, nonce: block_index, signature: None }
    }

    pub fn is_coinbase(&self) -> bool {
        self.from.is_none()
    }

    /// Hash do conteúdo da transação (sem a assinatura). É o que é assinado.
    pub fn hash(&self) -> Hash {
        let mut h = Sha256::new();
        match &self.from {
            Some(from) => {
                h.update([1u8]);
                h.update(from);
            }
            None => h.update([0u8]),
        }
        h.update(self.to);
        h.update(self.amount.to_le_bytes());
        h.update(self.nonce.to_le_bytes());
        finish(h)
    }

    pub fn sign(&mut self, key: &SigningKey) -> Result<(), SignError> {
        let from = self.from.ok_or(SignError::CannotSignCoinbase)?;
        if from != key.verifying_key().to_bytes() {
            return Err(SignError::KeyDoesNotMatchSender);
        }
        self.signature = Some(key.sign(&self.hash()).to_bytes());
        Ok(())
    }

    /// Verifica a assinatura. Coinbases não têm assinatura; suas regras
    /// são verificadas no nível do bloco.
    pub fn has_valid_signature(&self) -> bool {
        let Some(from) = self.from else {
            return self.signature.is_none();
        };
        let Some(sig_bytes) = self.signature else {
            return false;
        };
        let Ok(public_key) = VerifyingKey::from_bytes(&from) else {
            return false;
        };
        let sig = Signature::from_bytes(&sig_bytes);
        public_key.verify(&self.hash(), &sig).is_ok()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn key(seed: u8) -> SigningKey {
        SigningKey::from_bytes(&[seed; 32])
    }

    #[test]
    fn assinatura_valida_e_adulteracao_detectada() {
        let alice = key(1);
        let bob = key(2);
        let mut tx = Transaction {
            from: Some(alice.verifying_key().to_bytes()),
            to: bob.verifying_key().to_bytes(),
            amount: 10,
            nonce: 0,
            signature: None,
        };
        assert!(!tx.has_valid_signature());
        tx.sign(&alice).unwrap();
        assert!(tx.has_valid_signature());

        tx.amount = 1_000;
        assert!(!tx.has_valid_signature());
    }

    #[test]
    fn nao_e_possivel_assinar_com_a_chave_de_outra_pessoa() {
        let alice = key(1);
        let bob = key(2);
        let mut tx = Transaction {
            from: Some(alice.verifying_key().to_bytes()),
            to: bob.verifying_key().to_bytes(),
            amount: 10,
            nonce: 0,
            signature: None,
        };
        assert_eq!(tx.sign(&bob), Err(SignError::KeyDoesNotMatchSender));
    }
}
