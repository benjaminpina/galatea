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

// SetFileService implements the SubstrateSetFileService interface
type SetFileService struct {
	substrateSetService portsSubstrate.SubstrateSetService
}

// NewSetFileService creates a new SubstrateSetFileService
func NewSetFileService(substrateSetService portsSubstrate.SubstrateSetService) *SetFileService {
	return &SetFileService{
		substrateSetService: substrateSetService,
	}
}

// ExportSubstrateSet exports a substrate set to a JSON file
func (s *SetFileService) ExportSubstrateSet(substrateSet *domainSubstrate.SubstrateSet, filePath string) error {
	// Ensure the directory exists
	dir := filepath.Dir(filePath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	// Marshal the substrate set to JSON
	data, err := json.MarshalIndent(substrateSet, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal substrate set: %w", err)
	}

	// Write the JSON to the file
	if err := os.WriteFile(filePath, data, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

// ImportSubstrateSet imports a substrate set from a JSON file
func (s *SetFileService) ImportSubstrateSet(filePath string) (*domainSubstrate.SubstrateSet, error) {
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
	var set domainSubstrate.SubstrateSet
	if err := json.Unmarshal(data, &set); err != nil {
		return nil, fmt.Errorf("failed to unmarshal substrate set: %w", err)
	}

	// Validate the substrate set
	if set.ID == "" || set.Name == "" {
		return nil, errors.New("invalid substrate set: missing required fields")
	}

	// Validate mixed substrates in the set
	for _, ms := range set.MixedSubstrates {
		if err := ms.Validate(); err != nil {
			return nil, fmt.Errorf("invalid mixed substrate in set: %w", err)
		}
	}

	return &set, nil
}

// Ensure SetFileService implements SubstrateSetFileService
var _ portsSubstrate.SubstrateSetFileService = (*SetFileService)(nil)
