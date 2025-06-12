package substrate

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"

	domainSubstrate "github.com/benjaminpina/galatea/internal/core/domain/substrate"
	portsSubstrate "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedFileService implements the MixedSubstrateFileService interface
type MixedFileService struct {
	mixedSubstrateService portsSubstrate.MixedSubstrateService
}

// NewMixedFileService creates a new MixedSubstrateFileService
func NewMixedFileService(mixedSubstrateService portsSubstrate.MixedSubstrateService) *MixedFileService {
	return &MixedFileService{
		mixedSubstrateService: mixedSubstrateService,
	}
}

// ExportMixedSubstrate exports a mixed substrate to a JSON file
func (s *MixedFileService) ExportMixedSubstrate(mixedSubstrate *domainSubstrate.MixedSubstrate, filePath string) error {
	// Ensure the directory exists
	dir := filepath.Dir(filePath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	// Marshal the mixed substrate to JSON
	data, err := json.MarshalIndent(mixedSubstrate, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal mixed substrate: %w", err)
	}

	// Write the JSON to the file
	if err := os.WriteFile(filePath, data, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

// ImportMixedSubstrate imports a mixed substrate from a JSON file
func (s *MixedFileService) ImportMixedSubstrate(filePath string) (*domainSubstrate.MixedSubstrate, error) {
	// Check if the file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return nil, errors.New("file does not exist")
	}

	// Read the file
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}

	// Unmarshal the JSON
	var mixedSub domainSubstrate.MixedSubstrate
	if err := json.Unmarshal(data, &mixedSub); err != nil {
		return nil, fmt.Errorf("failed to unmarshal mixed substrate: %w", err)
	}

	// Validate the mixed substrate
	if mixedSub.ID == "" || mixedSub.Name == "" {
		return nil, errors.New("invalid mixed substrate: missing required fields")
	}

	// Validate the percentages
	if err := mixedSub.Validate(); err != nil {
		return nil, fmt.Errorf("invalid mixed substrate: %w", err)
	}

	return &mixedSub, nil
}

// Ensure MixedFileService implements MixedSubstrateFileService
var _ portsSubstrate.MixedSubstrateFileService = (*MixedFileService)(nil)
