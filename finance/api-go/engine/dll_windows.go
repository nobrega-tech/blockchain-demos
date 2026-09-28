//go:build windows

package engine

import (
	"fmt"
	"os"
	"path/filepath"
	"syscall"
	"unsafe"
)

var (
	dll              *syscall.LazyDLL
	procCreate       *syscall.LazyProc
	procDestroy      *syscall.LazyProc
	procWalletReg    *syscall.LazyProc
	procBalance      *syscall.LazyProc
	procPendingCount *syscall.LazyProc
	procBlockCount   *syscall.LazyProc
	procValidate     *syscall.LazyProc
	procSubmitTx     *syscall.LazyProc
	procMine         *syscall.LazyProc
	procChainJSON    *syscall.LazyProc
	procPendingJSON  *syscall.LazyProc
)

func init() {
	path, err := findDLL()
	if err != nil {
		panic(err)
	}
	dll = syscall.NewLazyDLL(path)
	procCreate = dll.NewProc("zig_engine_create")
	procDestroy = dll.NewProc("zig_engine_destroy")
	procWalletReg = dll.NewProc("zig_wallet_register")
	procBalance = dll.NewProc("zig_balance")
	procPendingCount = dll.NewProc("zig_pending_count")
	procBlockCount = dll.NewProc("zig_block_count")
	procValidate = dll.NewProc("zig_validate")
	procSubmitTx = dll.NewProc("zig_submit_tx")
	procMine = dll.NewProc("zig_mine")
	procChainJSON = dll.NewProc("zig_chain_json")
	procPendingJSON = dll.NewProc("zig_pending_json")
}

func findDLL() (string, error) {
	if p := os.Getenv("BLOCKCHAIN_ENGINE_DLL"); p != "" {
		if _, err := os.Stat(p); err == nil {
			return p, nil
		}
		return "", fmt.Errorf("BLOCKCHAIN_ENGINE_DLL not found: %s", p)
	}
	candidates := []string{
		filepath.Join("..", "demo-blockchain-with-zig", "zig-out", "bin", "blockchain_engine.dll"),
		"blockchain_engine.dll",
		filepath.Join("zig-out", "bin", "blockchain_engine.dll"),
	}
	// Also try relative to executable
	if exe, err := os.Executable(); err == nil {
		dir := filepath.Dir(exe)
		candidates = append(candidates,
			filepath.Join(dir, "blockchain_engine.dll"),
			filepath.Join(dir, "..", "demo-blockchain-with-zig", "zig-out", "bin", "blockchain_engine.dll"),
		)
	}
	for _, c := range candidates {
		abs, err := filepath.Abs(c)
		if err != nil {
			continue
		}
		if _, err := os.Stat(abs); err == nil {
			return abs, nil
		}
	}
	return "", fmt.Errorf("blockchain_engine.dll not found; build with: cd finance/demo-blockchain-with-zig && zig build engine -Doptimize=ReleaseFast (or set BLOCKCHAIN_ENGINE_DLL)")
}

func Create(difficulty uint8, reward uint64, genesisTS int64) error {
	r, _, _ := procCreate.Call(uintptr(difficulty), uintptr(reward), uintptr(genesisTS))
	switch int32(r) {
	case 0:
		return nil
	case -1:
		return fmt.Errorf("engine already initialized")
	default:
		return fmt.Errorf("engine create failed (%d)", int32(r))
	}
}

func Destroy() {
	procDestroy.Call()
}

func WalletRegister(seed [32]byte) ([32]byte, error) {
	var out [32]byte
	r, _, _ := procWalletReg.Call(uintptr(unsafe.Pointer(&seed[0])), uintptr(unsafe.Pointer(&out[0])))
	if int32(r) != 0 {
		return out, fmt.Errorf("wallet register failed (%d)", int32(r))
	}
	return out, nil
}

func Balance(addr [32]byte) uint64 {
	r, _, _ := procBalance.Call(uintptr(unsafe.Pointer(&addr[0])))
	return uint64(r)
}

func PendingCount() uint64 {
	r, _, _ := procPendingCount.Call()
	return uint64(r)
}

func BlockCount() uint64 {
	r, _, _ := procBlockCount.Call()
	return uint64(r)
}

func Validate() (bool, string) {
	var buf [256]byte
	r, _, _ := procValidate.Call(uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	code := int32(r)
	if code == 0 {
		return true, ""
	}
	return false, cstr(buf[:])
}

func SubmitTx(from, to [32]byte, amount uint64) error {
	var buf [256]byte
	r, _, _ := procSubmitTx.Call(
		uintptr(unsafe.Pointer(&from[0])),
		uintptr(unsafe.Pointer(&to[0])),
		uintptr(amount),
		uintptr(unsafe.Pointer(&buf[0])),
		uintptr(len(buf)),
	)
	if int32(r) == 0 {
		return nil
	}
	msg := cstr(buf[:])
	if msg == "" {
		msg = fmt.Sprintf("submit failed (%d)", int32(r))
	}
	return fmt.Errorf("%s", msg)
}

func Mine(miner [32]byte, timestamp int64) error {
	var buf [256]byte
	r, _, _ := procMine.Call(
		uintptr(unsafe.Pointer(&miner[0])),
		uintptr(timestamp),
		uintptr(unsafe.Pointer(&buf[0])),
		uintptr(len(buf)),
	)
	if int32(r) == 0 {
		return nil
	}
	msg := cstr(buf[:])
	if msg == "" {
		msg = fmt.Sprintf("mine failed (%d)", int32(r))
	}
	return fmt.Errorf("%s", msg)
}

func ChainJSON() ([]byte, error) {
	return callJSON(procChainJSON)
}

func PendingJSON() ([]byte, error) {
	return callJSON(procPendingJSON)
}

func callJSON(proc *syscall.LazyProc) ([]byte, error) {
	buf := make([]byte, 1<<20) // 1 MiB
	r, _, _ := proc.Call(uintptr(unsafe.Pointer(&buf[0])), uintptr(len(buf)))
	n := int32(r)
	if n < 0 {
		return nil, fmt.Errorf("json export failed (%d)", n)
	}
	out := make([]byte, n)
	copy(out, buf[:n])
	return out, nil
}

func cstr(b []byte) string {
	for i, c := range b {
		if c == 0 {
			return string(b[:i])
		}
	}
	return string(b)
}