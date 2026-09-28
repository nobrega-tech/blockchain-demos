pub use sha2::{Digest, Sha256};

pub type Hash = [u8; 32];

/// Finaliza o hasher devolvendo um array de tamanho fixo.
pub fn finish(hasher: Sha256) -> Hash {
    hasher.finalize().into()
}

/// Hexadecimal completo.
pub fn hex(bytes: &[u8]) -> String {
    hex::encode(bytes)
}

/// Primeiros 8 bytes em hexadecimal — suficiente para exibição.
pub fn short_hex(bytes: &[u8]) -> String {
    hex::encode(&bytes[..8])
}

/// Quantidade de bits zero no início do hash (medida da prova de trabalho).
pub fn leading_zero_bits(hash: &Hash) -> u32 {
    let mut count = 0;
    for &byte in hash {
        if byte == 0 {
            count += 8;
        } else {
            count += byte.leading_zeros();
            break;
        }
    }
    count
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn conta_bits_zero() {
        let mut h: Hash = [0; 32];
        assert_eq!(leading_zero_bits(&h), 256);
        h[1] = 0b0001_0000;
        assert_eq!(leading_zero_bits(&h), 11);
    }
}
