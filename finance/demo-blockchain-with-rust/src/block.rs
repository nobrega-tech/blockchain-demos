use crate::hash::{Digest, Hash, Sha256, finish, leading_zero_bits};
use crate::transaction::Transaction;

#[derive(Debug, Clone)]
pub struct Block {
    pub index: u64,
    pub timestamp: i64,
    pub prev_hash: Hash,
    pub transactions: Vec<Transaction>,
    pub nonce: u64,
    pub hash: Hash,
}

impl Block {
    /// Limite de transações por bloco (incluindo a coinbase).
    pub const MAX_TRANSACTIONS: usize = 256;

    pub fn new(index: u64, timestamp: i64, prev_hash: Hash, transactions: Vec<Transaction>) -> Self {
        Self { index, timestamp, prev_hash, transactions, nonce: 0, hash: [0; 32] }
    }

    /// Raiz de Merkle das transações: qualquer alteração em qualquer
    /// transação muda a raiz e, portanto, o hash do bloco.
    pub fn merkle_root(&self) -> Hash {
        compute_merkle_root(&self.transactions)
    }

    /// Hasher com todo o cabeçalho, exceto o nonce.
    fn header_prefix(&self) -> Sha256 {
        let mut h = Sha256::new();
        h.update(self.index.to_le_bytes());
        h.update(self.timestamp.to_le_bytes());
        h.update(self.prev_hash);
        h.update(self.merkle_root());
        h
    }

    pub fn compute_hash(&self) -> Hash {
        let mut h = self.header_prefix();
        h.update(self.nonce.to_le_bytes());
        finish(h)
    }

    /// Prova de trabalho: incrementa o nonce até o hash ter pelo menos
    /// `difficulty` bits zero no início.
    pub fn mine(&mut self, difficulty: u32) -> u64 {
        // O conteudo nao muda durante a mineracao: calcula o prefixo uma vez.
        let prefix = self.header_prefix();
        self.nonce = 0;
        loop {
            let mut h = prefix.clone();
            h.update(self.nonce.to_le_bytes());
            let candidate = finish(h);
            if leading_zero_bits(&candidate) >= difficulty {
                self.hash = candidate;
                return self.nonce + 1;
            }
            self.nonce += 1;
        }
    }

    pub fn has_valid_proof_of_work(&self, difficulty: u32) -> bool {
        let actual = self.compute_hash();
        actual == self.hash && leading_zero_bits(&actual) >= difficulty
    }
}

fn compute_merkle_root(transactions: &[Transaction]) -> Hash {
    assert!(transactions.len() <= Block::MAX_TRANSACTIONS);
    if transactions.is_empty() {
        return [0; 32];
    }

    let mut level: Vec<Hash> = transactions.iter().map(Transaction::hash).collect();

    // Combina pares até restar um único hash; um nó ímpar é pareado consigo mesmo.
    while level.len() > 1 {
        level = level
            .chunks(2)
            .map(|pair| {
                let right = pair.get(1).unwrap_or(&pair[0]);
                let mut h = Sha256::new();
                h.update(pair[0]);
                h.update(right);
                finish(h)
            })
            .collect();
    }
    level[0]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mineracao_respeita_a_dificuldade_e_detecta_adulteracao() {
        let txs = vec![Transaction::coinbase([7; 32], 50, 1)];
        let mut block = Block::new(1, 1_700_000_000, [0; 32], txs);
        block.mine(12);
        assert!(block.has_valid_proof_of_work(12));

        block.transactions[0].amount = 5_000;
        assert!(!block.has_valid_proof_of_work(12));
    }

    #[test]
    fn raiz_de_merkle_muda_com_qualquer_transacao() {
        let mut txs: Vec<Transaction> =
            (0..5).map(|n| Transaction::coinbase([1; 32], 10, n)).collect();
        let before = compute_merkle_root(&txs);
        txs[4].amount = 11;
        assert_ne!(before, compute_merkle_root(&txs));
    }
}
