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

// FileService implements the SubstrateFileService interface
type FileService struct {
	substrateService portsSubstrate.SubstrateService
}

// NewFileService creates a new SubstrateFileService
func NewFileService(substrateService portsSubstrate.SubstrateService) *FileService {
	return &FileService{
		substrateService: substrateService,
	}
}

// ExportSubstrate exports a substrate to a JSON file
func (s *FileService) ExportSubstrate(substrate *domainSubstrate.Substrate, filePath string) error {
	// Ensure the directory exists
	dir := filepath.Dir(filePath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	// Marshal the substrate to JSON
	data, err := json.MarshalIndent(substrate, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal substrate: %w", err)
	}

	// Write the JSON to the file
	if err := os.WriteFile(filePath, data, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

// ImportSubstrate imports a substrate from a JSON file
func (s *FileService) ImportSubstrate(filePath string) (*domainSubstrate.Substrate, error) {
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
	var sub domainSubstrate.Substrate
	if err := json.Unmarshal(data, &sub); err != nil {
		return nil, fmt.Errorf("failed to unmarshal substrate: %w", err)
	}

	// Validate the substrate
	if sub.ID == "" || sub.Name == "" {
		return nil, errors.New("invalid substrate: missing required fields")
	}

	return &sub, nil
}

// Ensure FileService implements SubstrateFileService
var _ portsSubstrate.SubstrateFileService = (*FileService)(nil)
