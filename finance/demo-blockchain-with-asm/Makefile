CC ?= zig cc
CFLAGS ?= -O3 -Wall -Wextra -std=c11 -DDEMO_USE_ASM_MINE -DDEMO_IMPL_NAME=\"asm\"
SRCS = src/sha256.c src/pow_mine.S src/blockchain.c src/main.c
BIN = demo-blockchain.exe

.PHONY: all clean test bench

all: $(BIN)

$(BIN): $(SRCS) src/blockchain.h src/sha256.h
	$(CC) $(CFLAGS) -Isrc -o $(BIN) $(SRCS)

test: $(BIN)
	./$(BIN) test

bench: $(BIN)
	./$(BIN) bench --difficulty 16 --blocks 5 --txs-per-block 0

clean:
	rm -f $(BIN)