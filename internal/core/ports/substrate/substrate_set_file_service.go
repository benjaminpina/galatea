package substrate

import "github.com/benjaminpina/galatea/internal/core/domain/substrate"

// SubstrateSetFileService defines the interface for substrate set file operations
type SubstrateSetFileService interface {
	// Substrate set file operations
	ExportSubstrateSet(substrateSet *substrate.SubstrateSet, filePath string) error
	ImportSubstrateSet(filePath string) (*substrate.SubstrateSet, error)
}
