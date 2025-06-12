package substrate

import "github.com/benjaminpina/galatea/internal/core/domain/substrate"

// MixedSubstrateFileService defines the interface for mixed substrate file operations
type MixedSubstrateFileService interface {
	// Substrate file operations
	ExportMixedSubstrate(mixedSubstrate *substrate.MixedSubstrate, filePath string) error
	ImportMixedSubstrate(filePath string) (*substrate.MixedSubstrate, error)
}
