const std = @import("std");

pub const Sha256 = std.crypto.hash.sha2.Sha256;
pub const Hash = [Sha256.digest_length]u8;

/// Alimenta o hasher com um inteiro em little-endian, garantindo o mesmo
/// hash independentemente da arquitetura.
pub fn updateInt(hasher: *Sha256, comptime T: type, value: T) void {
    hasher.update(&std.mem.toBytes(std.mem.nativeToLittle(T, value)));
}

pub fn hex(bytes: anytype) [bytes.len * 2]u8 {
    return std.fmt.bytesToHex(bytes, .lower);
}

/// Primeiros 8 bytes em hexadecimal — suficiente para exibição.
pub fn shortHex(bytes: anytype) [16]u8 {
    return std.fmt.bytesToHex(bytes[0..8].*, .lower);
}

/// Quantidade de bits zero no início do hash (medida da prova de trabalho).
pub fn leadingZeroBits(hash: Hash) u16 {
    var count: u16 = 0;
    for (hash) |byte| {
        if (byte == 0) {
            count += 8;
        } else {
            count += @clz(byte);
            break;
        }
    }
    return count;
}

test leadingZeroBits {
    var h: Hash = @splat(0);
    try std.testing.expectEqual(@as(u16, 256), leadingZeroBits(h));
    h[1] = 0b0001_0000;
    try std.testing.expectEqual(@as(u16, 11), leadingZeroBits(h));
}
