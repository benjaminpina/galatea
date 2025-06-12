package substrate

import "github.com/benjaminpina/galatea/internal/core/domain/substrate"

// SubstrateFileService defines the interface for substrate file operations
type SubstrateFileService interface {
	// Substrate file operations
	ExportSubstrate(substrate *substrate.Substrate, filePath string) error
	ImportSubstrate(filePath string) (*substrate.Substrate, error)
}
