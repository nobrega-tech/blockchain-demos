use std::collections::{HashMap, HashSet};

use crate::block::Block;
use crate::transaction::{Address, Transaction};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TransactionError {
    InvalidSignature,
    CoinbaseNotAllowed,
    ZeroAmount,
    InsufficientFunds,
    DuplicateTransaction,
    MempoolFull,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ValidationError {
    InvalidGenesis,
    InvalidIndex,
    BrokenLink,
    InvalidProofOfWork,
    InvalidCoinbase,
    InvalidSignature,
    InsufficientFunds,
    DuplicateTransaction,
}

pub struct Options {
    /// Bits zero exigidos no início do hash de cada bloco.
    pub difficulty: u32,
    pub mining_reward: u64,
    pub genesis_timestamp: i64,
}

impl Default for Options {
    fn default() -> Self {
        Self { difficulty: 16, mining_reward: 50, genesis_timestamp: 1_700_000_000 }
    }
}

pub struct Blockchain {
    pub blocks: Vec<Block>,
    /// Transações aceitas aguardando o próximo bloco (mempool).
    pub pending: Vec<Transaction>,
    pub difficulty: u32,
    pub mining_reward: u64,
}

impl Blockchain {
    pub fn new(options: Options) -> Self {
        let mut genesis = Block::new(0, options.genesis_timestamp, [0; 32], Vec::new());
        genesis.mine(options.difficulty);
        Self {
            blocks: vec![genesis],
            pending: Vec::new(),
            difficulty: options.difficulty,
            mining_reward: options.mining_reward,
        }
    }

    pub fn latest(&self) -> &Block {
        self.blocks.last().expect("a cadeia sempre tem o bloco gênesis")
    }

    /// Saldo confirmado (apenas blocos minerados).
    pub fn balance_of(&self, address: &Address) -> u64 {
        let mut balance: u64 = 0;
        for tx in self.blocks.iter().flat_map(|b| &b.transactions) {
            if tx.to == *address {
                balance += tx.amount;
            }
            if tx.from.as_ref() == Some(address) {
                balance -= tx.amount;
            }
        }
        balance
    }

    /// Saldo confirmado menos o que já está comprometido na mempool.
    pub fn spendable_balance(&self, address: &Address) -> u64 {
        let committed: u64 = self
            .pending
            .iter()
            .filter(|tx| tx.from.as_ref() == Some(address))
            .map(|tx| tx.amount)
            .sum();
        self.balance_of(address) - committed
    }

    /// Valida e coloca uma transação na mempool.
    pub fn add_transaction(&mut self, tx: Transaction) -> Result<(), TransactionError> {
        let from = tx.from.ok_or(TransactionError::CoinbaseNotAllowed)?;
        if tx.amount == 0 {
            return Err(TransactionError::ZeroAmount);
        }
        if !tx.has_valid_signature() {
            return Err(TransactionError::InvalidSignature);
        }
        if self.pending.len() + 1 >= Block::MAX_TRANSACTIONS {
            return Err(TransactionError::MempoolFull);
        }
        if self.contains_transaction(&tx) {
            return Err(TransactionError::DuplicateTransaction);
        }
        if self.spendable_balance(&from) < tx.amount {
            return Err(TransactionError::InsufficientFunds);
        }
        self.pending.push(tx);
        Ok(())
    }

    /// Minera um bloco com a coinbase para `miner` e todas as transações
    /// pendentes, adicionando-o à cadeia.
    pub fn mine_pending(&mut self, miner: Address, timestamp: i64) -> &Block {
        let index = self.blocks.len() as u64;
        let mut txs = Vec::with_capacity(self.pending.len() + 1);
        txs.push(Transaction::coinbase(miner, self.mining_reward, index));
        txs.append(&mut self.pending);

        let mut block = Block::new(index, timestamp, self.latest().hash, txs);
        block.mine(self.difficulty);
        self.blocks.push(block);
        self.latest()
    }

    /// Revalida a cadeia inteira do zero: encadeamento, prova de trabalho,
    /// assinaturas, regras da coinbase e saldos.
    pub fn validate(&self) -> Result<(), ValidationError> {
        use ValidationError::*;

        let genesis = self.blocks.first().ok_or(InvalidGenesis)?;
        if genesis.index != 0
            || !genesis.transactions.is_empty()
            || genesis.prev_hash != [0; 32]
            || !genesis.has_valid_proof_of_work(self.difficulty)
        {
            return Err(InvalidGenesis);
        }

        let mut balances: HashMap<Address, u64> = HashMap::new();
        let mut seen = HashSet::new();

        for pair in self.blocks.windows(2) {
            let (prev, block) = (&pair[0], &pair[1]);
            if block.index != prev.index + 1 {
                return Err(InvalidIndex);
            }
            if block.prev_hash != prev.hash {
                return Err(BrokenLink);
            }
            if !block.has_valid_proof_of_work(self.difficulty) {
                return Err(InvalidProofOfWork);
            }

            let txs = &block.transactions;
            match txs.first() {
                Some(cb)
                    if cb.is_coinbase()
                        && cb.amount == self.mining_reward
                        && cb.nonce == block.index => {}
                _ => return Err(InvalidCoinbase),
            }

            for (i, tx) in txs.iter().enumerate() {
                if i > 0 && tx.is_coinbase() {
                    return Err(InvalidCoinbase);
                }
                if !tx.has_valid_signature() {
                    return Err(InvalidSignature);
                }
                if !seen.insert(tx.hash()) {
                    return Err(DuplicateTransaction);
                }
                if let Some(from) = &tx.from {
                    let sender = balances.get_mut(from).ok_or(InsufficientFunds)?;
                    if *sender < tx.amount {
                        return Err(InsufficientFunds);
                    }
                    *sender -= tx.amount;
                }
                *balances.entry(tx.to).or_insert(0) += tx.amount;
            }
        }
        Ok(())
    }

    fn contains_transaction(&self, tx: &Transaction) -> bool {
        let tx_hash = tx.hash();
        self.pending
            .iter()
            .chain(self.blocks.iter().flat_map(|b| &b.transactions))
            .any(|t| t.hash() == tx_hash)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::wallet::Wallet;

    fn test_chain() -> Blockchain {
        Blockchain::new(Options { difficulty: 8, ..Default::default() })
    }

    #[test]
    fn fluxo_completo_minerar_transferir_validar() {
        let mut chain = test_chain();
        let mut alice = Wallet::from_seed("alice", [1; 32]);
        let bob = Wallet::from_seed("bob", [2; 32]);

        chain.mine_pending(alice.address(), 1);
        assert_eq!(chain.balance_of(&alice.address()), 50);

        chain.add_transaction(alice.send(bob.address(), 20).unwrap()).unwrap();
        chain.mine_pending(bob.address(), 2);

        assert_eq!(chain.balance_of(&alice.address()), 30);
        assert_eq!(chain.balance_of(&bob.address()), 70);
        assert_eq!(chain.validate(), Ok(()));
    }

    #[test]
    fn rejeita_gasto_maior_que_o_saldo_inclusive_somando_a_mempool() {
        let mut chain = test_chain();
        let mut alice = Wallet::from_seed("alice", [1; 32]);
        let bob = Wallet::from_seed("bob", [2; 32]);

        let tx = alice.send(bob.address(), 1).unwrap();
        assert_eq!(chain.add_transaction(tx), Err(TransactionError::InsufficientFunds));

        chain.mine_pending(alice.address(), 1);
        chain.add_transaction(alice.send(bob.address(), 40).unwrap()).unwrap();
        let tx = alice.send(bob.address(), 20).unwrap();
        assert_eq!(chain.add_transaction(tx), Err(TransactionError::InsufficientFunds));
    }

    #[test]
    fn rejeita_replay_e_assinatura_forjada() {
        let mut chain = test_chain();
        let mut alice = Wallet::from_seed("alice", [1; 32]);
        let mut mallory = Wallet::from_seed("mallory", [3; 32]);

        chain.mine_pending(alice.address(), 1);
        let tx = alice.send(mallory.address(), 10).unwrap();
        chain.add_transaction(tx).unwrap();
        assert_eq!(chain.add_transaction(tx), Err(TransactionError::DuplicateTransaction));
        chain.mine_pending(mallory.address(), 2);
        assert_eq!(chain.add_transaction(tx), Err(TransactionError::DuplicateTransaction));

        // Mallory tenta gastar o dinheiro de Alice assinando com a própria chave.
        let mut forged = Transaction {
            from: Some(alice.address()),
            to: mallory.address(),
            amount: 30,
            nonce: 99,
            signature: None,
        };
        forged.signature = mallory.send(mallory.address(), 1).unwrap().signature;
        assert_eq!(chain.add_transaction(forged), Err(TransactionError::InvalidSignature));
    }

    #[test]
    fn adulterar_um_bloco_invalida_a_cadeia() {
        let mut chain = test_chain();
        let mut alice = Wallet::from_seed("alice", [1; 32]);
        let bob = Wallet::from_seed("bob", [2; 32]);

        chain.mine_pending(alice.address(), 1);
        chain.add_transaction(alice.send(bob.address(), 10).unwrap()).unwrap();
        chain.mine_pending(alice.address(), 2);
        chain.mine_pending(alice.address(), 3);
        assert_eq!(chain.validate(), Ok(()));

        let difficulty = chain.difficulty;

        // Alterar o valor muda o hash do bloco: a prova de trabalho não bate mais.
        chain.blocks[2].transactions[1].amount = 45;
        assert_eq!(chain.validate(), Err(ValidationError::InvalidProofOfWork));

        // Reminerar o bloco não basta: a assinatura de Alice não cobre o novo valor.
        chain.blocks[2].mine(difficulty);
        assert_eq!(chain.validate(), Err(ValidationError::InvalidSignature));

        // Restaurando a transação e reminerando, o bloco seguinte ainda aponta
        // para o hash antigo — seria preciso refazer o trabalho da cadeia toda.
        chain.blocks[2].transactions[1].amount = 10;
        chain.blocks[2].timestamp = 999;
        chain.blocks[2].mine(difficulty);
        assert_eq!(chain.validate(), Err(ValidationError::BrokenLink));
    }
}
