// Package jsonexchange provides JSON import/export for simulation components.
// It enables sharing of substrates, loci, and prototypes between projects.
package jsonexchange

import (
	"encoding/json"
	"fmt"
	"os"

	"galatea/engine/internal/adapters/storage"
)

// SubstrateSetExport represents an exported set of substrates.
type SubstrateSetExport struct {
	SchemaVersion int                      `json:"schema_version"`
	Type          string                   `json:"type"`
	Substrates    []SubstrateExport        `json:"substrates"`
	Compositions  []MixedCompositionExport `json:"compositions"`
}

// SubstrateExport represents a single substrate in export format.
type SubstrateExport struct {
	Name      string `json:"name"`
	Color     int    `json:"color"`
	IsMixed   bool   `json:"is_mixed"`
	SortOrder int    `json:"sort_order"`
}

// MixedCompositionExport represents a composition entry.
type MixedCompositionExport struct {
	MixedName  string `json:"mixed_name"`
	SimpleName string `json:"simple_name"`
	Percentage int    `json:"percentage"`
}

// LociSetExport represents an exported set of genetic loci.
type LociSetExport struct {
	SchemaVersion int           `json:"schema_version"`
	Type          string        `json:"type"`
	Loci          []LocusExport `json:"loci"`
}

// LocusExport represents a single locus in export format.
type LocusExport struct {
	Name              string  `json:"name"`
	IsContinuous      bool    `json:"is_continuous"`
	DominantValue     float64 `json:"dominant_value"`
	RecessiveValue    float64 `json:"recessive_value"`
	MutationRateDom   float64 `json:"mutation_rate_dom"`
	MutationRateRec   float64 `json:"mutation_rate_rec"`
	MutationRangeDom  float64 `json:"mutation_range_dom"`
	MutationRangeRec  float64 `json:"mutation_range_rec"`
	DefaultExpression string  `json:"default_expression"`
	SortOrder         int     `json:"sort_order"`
}

// PrototypeSetExport represents an exported set of prototypes.
type PrototypeSetExport struct {
	SchemaVersion int               `json:"schema_version"`
	Type          string            `json:"type"`
	Prototypes    []PrototypeExport `json:"prototypes"`
}

// PrototypeExport represents a single prototype in export format.
type PrototypeExport struct {
	Name                       string `json:"name"`
	Sex                        string `json:"sex"`
	Color                      int    `json:"color"`
	LongevityFormula           string `json:"longevity_formula"`
	RefractoryCombatFormula    string `json:"refractory_combat_formula"`
	RefractoryCourtshipFormula string `json:"refractory_courtship_formula"`
	SexRatioMalesFormula       string `json:"sex_ratio_males_formula"`
	SexRatioFemalesFormula     string `json:"sex_ratio_females_formula"`
	SortOrder                  int    `json:"sort_order"`
}

// ImportResult holds the outcome of an import operation.
type ImportResult struct {
	Imported int
	Skipped  int
	Errors   []string
}

// ImportSubstrates reads a substrate JSON file and inserts into the database.
func ImportSubstrates(db *storage.DB, filePath string) (*ImportResult, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("read file: %w", err)
	}

	var export SubstrateSetExport
	if err := json.Unmarshal(data, &export); err != nil {
		return nil, fmt.Errorf("parse json: %w", err)
	}
	if export.Type != "substrate_set" {
		return nil, fmt.Errorf("invalid type: expected substrate_set, got %s", export.Type)
	}

	repo := storage.NewSubstrateRepo(db)
	existing, _ := repo.List()
	existingNames := make(map[string]bool)
	for _, s := range existing {
		existingNames[s.Name] = true
	}

	result := &ImportResult{}
	for _, sub := range export.Substrates {
		if existingNames[sub.Name] {
			result.Skipped++
			continue
		}
		_, err := repo.Create(sub.Name, sub.Color, sub.IsMixed, sub.SortOrder)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("substrate %s: %v", sub.Name, err))
			continue
		}
		result.Imported++
	}

	// Import compositions.
	if len(export.Compositions) > 0 {
		allSubs, _ := repo.List()
		nameToID := make(map[string]int64)
		for _, s := range allSubs {
			nameToID[s.Name] = s.ID
		}
		for _, comp := range export.Compositions {
			mixedID := nameToID[comp.MixedName]
			simpleID := nameToID[comp.SimpleName]
			if mixedID > 0 && simpleID > 0 {
				repo.AddComposition(mixedID, simpleID, comp.Percentage)
			}
		}
	}

	return result, nil
}

// ImportLoci reads a loci JSON file and inserts into the database.
func ImportLoci(db *storage.DB, filePath string) (*ImportResult, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("read file: %w", err)
	}

	var export LociSetExport
	if err := json.Unmarshal(data, &export); err != nil {
		return nil, fmt.Errorf("parse json: %w", err)
	}
	if export.Type != "loci_set" {
		return nil, fmt.Errorf("invalid type: expected loci_set, got %s", export.Type)
	}

	repo := storage.NewLocusRepo(db)
	existing, _ := repo.List()
	existingNames := make(map[string]bool)
	for _, l := range existing {
		existingNames[l.Name] = true
	}

	result := &ImportResult{}
	for _, locus := range export.Loci {
		if existingNames[locus.Name] {
			result.Skipped++
			continue
		}
		_, err := repo.Create(&storage.Locus{
			Name:              locus.Name,
			IsContinuous:      locus.IsContinuous,
			DominantValue:     locus.DominantValue,
			RecessiveValue:    locus.RecessiveValue,
			MutationRateDom:   locus.MutationRateDom,
			MutationRateRec:   locus.MutationRateRec,
			MutationRangeDom:  locus.MutationRangeDom,
			MutationRangeRec:  locus.MutationRangeRec,
			DefaultExpression: locus.DefaultExpression,
			SortOrder:         locus.SortOrder,
		})
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("locus %s: %v", locus.Name, err))
			continue
		}
		result.Imported++
	}

	return result, nil
}

// ImportPrototypes reads a prototype JSON file and inserts into the database.
func ImportPrototypes(db *storage.DB, filePath string) (*ImportResult, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("read file: %w", err)
	}

	var export PrototypeSetExport
	if err := json.Unmarshal(data, &export); err != nil {
		return nil, fmt.Errorf("parse json: %w", err)
	}
	if export.Type != "prototype_set" {
		return nil, fmt.Errorf("invalid type: expected prototype_set, got %s", export.Type)
	}

	repo := storage.NewPrototypeRepo(db)
	existing, _ := repo.List("")
	existingNames := make(map[string]bool)
	for _, p := range existing {
		existingNames[p.Name] = true
	}

	result := &ImportResult{}
	for _, proto := range export.Prototypes {
		if existingNames[proto.Name] {
			result.Skipped++
			continue
		}
		_, err := repo.Create(&storage.Prototype{
			Name:                       proto.Name,
			Sex:                        proto.Sex,
			Color:                      proto.Color,
			LongevityFormula:           proto.LongevityFormula,
			RefractoryCombatFormula:    proto.RefractoryCombatFormula,
			RefractoryCourtshipFormula: proto.RefractoryCourtshipFormula,
			SexRatioMalesFormula:       proto.SexRatioMalesFormula,
			SexRatioFemalesFormula:     proto.SexRatioFemalesFormula,
			SortOrder:                  proto.SortOrder,
		})
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("prototype %s: %v", proto.Name, err))
			continue
		}
		result.Imported++
	}

	return result, nil
}
