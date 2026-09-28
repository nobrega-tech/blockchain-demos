//go:build !windows

package engine

import "fmt"

func Create(difficulty uint8, reward uint64, genesisTS int64) error {
	return fmt.Errorf("Zig engine DLL loader is implemented for Windows only in this demo; use Windows or add cgo/purego for other OS")
}
func Destroy() {}
func WalletRegister(seed [32]byte) ([32]byte, error) {
	return [32]byte{}, fmt.Errorf("unsupported OS")
}
func Balance(addr [32]byte) uint64             { return 0 }
func PendingCount() uint64                     { return 0 }
func BlockCount() uint64                       { return 0 }
func Validate() (bool, string)                 { return false, "unsupported OS" }
func SubmitTx(from, to [32]byte, amount uint64) error {
	return fmt.Errorf("unsupported OS")
}
func Mine(miner [32]byte, timestamp int64) error { return fmt.Errorf("unsupported OS") }
func ChainJSON() ([]byte, error)                 { return nil, fmt.Errorf("unsupported OS") }
func PendingJSON() ([]byte, error)               { return nil, fmt.Errorf("unsupported OS") }