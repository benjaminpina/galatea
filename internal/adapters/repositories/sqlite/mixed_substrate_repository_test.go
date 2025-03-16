package sqlite

import (
	"database/sql"
	"testing"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// setupTestDB configura una base de datos en memoria para pruebas
func setupTestDB(t *testing.T) *Database {
	db, err := sql.Open("sqlite", ":memory:")
	require.NoError(t, err, "Failed to open in-memory database")

	database := &Database{db: db}
	return database
}

// setupMixedSubstrateRepository configura un repositorio de sustratos mixtos para pruebas
func setupMixedSubstrateRepository(t *testing.T) *MixedSubstrateRepository {
	db := setupTestDB(t)
	repo := NewMixedSubstrateRepository(db)
	
	// Asegurarse de que la tabla se inicializa correctamente
	err := repo.Initialize()
	require.NoError(t, err, "Failed to initialize mixed_substrates table")
	
	return repo
}

// createTestMixedSubstrate crea un sustrato mixto para pruebas
func createTestMixedSubstrate() substrate.MixedSubstrate {
	subID := uuid.New().String()
	return substrate.MixedSubstrate{
		ID:    uuid.New().String(),
		Name:  "Test Mixed Substrate",
		Color: "#FF0000",
		Substrates: []substrate.SubstratePercentage{
			{
				Substrate: substrate.Substrate{
					ID:    subID,
					Name:  "Test Substrate",
					Color: "#00FF00",
				},
				Percentage: 100.0,
			},
		},
	}
}

// TestMixedSubstrateRepository_Create prueba la creación de un sustrato mixto
func TestMixedSubstrateRepository_Create(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear un sustrato mixto
	mixedSub := createTestMixedSubstrate()
	
	// Guardar el sustrato mixto
	err := repo.Create(mixedSub)
	require.NoError(t, err, "Failed to create mixed substrate")
	
	// Verificar que se guardó correctamente
	savedMixedSub, err := repo.GetByID(mixedSub.ID)
	require.NoError(t, err, "Failed to retrieve mixed substrate")
	require.NotNil(t, savedMixedSub, "Retrieved mixed substrate is nil")
	
	assert.Equal(t, mixedSub.ID, savedMixedSub.ID, "IDs do not match")
	assert.Equal(t, mixedSub.Name, savedMixedSub.Name, "Names do not match")
	assert.Equal(t, mixedSub.Color, savedMixedSub.Color, "Colors do not match")
	assert.Len(t, savedMixedSub.Substrates, 1, "Expected 1 substrate in the mix")
	assert.Equal(t, mixedSub.Substrates[0].Substrate.ID, savedMixedSub.Substrates[0].Substrate.ID, "Substrate IDs do not match")
	assert.Equal(t, mixedSub.Substrates[0].Percentage, savedMixedSub.Substrates[0].Percentage, "Percentages do not match")
}

// TestMixedSubstrateRepository_GetByID prueba la obtención de un sustrato mixto por ID
func TestMixedSubstrateRepository_GetByID(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear un sustrato mixto
	mixedSub := createTestMixedSubstrate()
	
	// Caso 1: Sustrato mixto no existe
	_, err := repo.GetByID(mixedSub.ID)
	assert.Error(t, err, "Expected error when getting non-existent mixed substrate")
	assert.Contains(t, err.Error(), "mixed substrate not found", "Error message should indicate mixed substrate not found")
	
	// Guardar el sustrato mixto
	err = repo.Create(mixedSub)
	require.NoError(t, err, "Failed to create mixed substrate")
	
	// Caso 2: Sustrato mixto existe
	savedMixedSub, err := repo.GetByID(mixedSub.ID)
	require.NoError(t, err, "Failed to retrieve mixed substrate")
	require.NotNil(t, savedMixedSub, "Retrieved mixed substrate is nil")
	
	assert.Equal(t, mixedSub.ID, savedMixedSub.ID, "IDs do not match")
	assert.Equal(t, mixedSub.Name, savedMixedSub.Name, "Names do not match")
	assert.Equal(t, mixedSub.Color, savedMixedSub.Color, "Colors do not match")
	assert.Len(t, savedMixedSub.Substrates, 1, "Expected 1 substrate in the mix")
}

// TestMixedSubstrateRepository_Update prueba la actualización de un sustrato mixto
func TestMixedSubstrateRepository_Update(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear un sustrato mixto
	mixedSub := createTestMixedSubstrate()
	
	// Caso 1: Sustrato mixto no existe
	err := repo.Update(mixedSub)
	assert.Error(t, err, "Expected error when updating non-existent mixed substrate")
	assert.Contains(t, err.Error(), "mixed substrate not found", "Error message should indicate mixed substrate not found")
	
	// Guardar el sustrato mixto
	err = repo.Create(mixedSub)
	require.NoError(t, err, "Failed to create mixed substrate")
	
	// Modificar el sustrato mixto
	mixedSub.Name = "Updated Mixed Substrate"
	mixedSub.Color = "#00FF00"
	
	// Caso 2: Sustrato mixto existe
	err = repo.Update(mixedSub)
	require.NoError(t, err, "Failed to update mixed substrate")
	
	// Verificar que se actualizó correctamente
	updatedMixedSub, err := repo.GetByID(mixedSub.ID)
	require.NoError(t, err, "Failed to retrieve updated mixed substrate")
	require.NotNil(t, updatedMixedSub, "Retrieved mixed substrate is nil")
	
	assert.Equal(t, "Updated Mixed Substrate", updatedMixedSub.Name, "Name was not updated")
	assert.Equal(t, "#00FF00", updatedMixedSub.Color, "Color was not updated")
}

// TestMixedSubstrateRepository_Delete prueba la eliminación de un sustrato mixto
func TestMixedSubstrateRepository_Delete(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear un sustrato mixto
	mixedSub := createTestMixedSubstrate()
	
	// Caso 1: Sustrato mixto no existe
	err := repo.Delete(mixedSub.ID)
	assert.Error(t, err, "Expected error when deleting non-existent mixed substrate")
	assert.Contains(t, err.Error(), "mixed substrate not found", "Error message should indicate mixed substrate not found")
	
	// Guardar el sustrato mixto
	err = repo.Create(mixedSub)
	require.NoError(t, err, "Failed to create mixed substrate")
	
	// Caso 2: Sustrato mixto existe
	err = repo.Delete(mixedSub.ID)
	require.NoError(t, err, "Failed to delete mixed substrate")
	
	// Verificar que se eliminó correctamente
	_, err = repo.GetByID(mixedSub.ID)
	assert.Error(t, err, "Expected error when getting deleted mixed substrate")
	assert.Contains(t, err.Error(), "mixed substrate not found", "Error message should indicate mixed substrate not found")
}

// TestMixedSubstrateRepository_List prueba la obtención de todos los sustratos mixtos
func TestMixedSubstrateRepository_List(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Caso 1: No hay sustratos mixtos
	mixedSubs, err := repo.List()
	require.NoError(t, err, "Failed to list mixed substrates")
	assert.Empty(t, mixedSubs, "Expected empty list of mixed substrates")
	
	// Crear varios sustratos mixtos
	mixedSub1 := createTestMixedSubstrate()
	mixedSub2 := createTestMixedSubstrate()
	mixedSub3 := createTestMixedSubstrate()
	
	err = repo.Create(mixedSub1)
	require.NoError(t, err, "Failed to create mixed substrate 1")
	
	err = repo.Create(mixedSub2)
	require.NoError(t, err, "Failed to create mixed substrate 2")
	
	err = repo.Create(mixedSub3)
	require.NoError(t, err, "Failed to create mixed substrate 3")
	
	// Caso 2: Hay sustratos mixtos
	mixedSubs, err = repo.List()
	require.NoError(t, err, "Failed to list mixed substrates")
	assert.Len(t, mixedSubs, 3, "Expected 3 mixed substrates")
	
	// Verificar que los IDs de los sustratos mixtos están en la lista
	ids := make([]string, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		ids[i] = mixedSub.ID
	}
	
	assert.Contains(t, ids, mixedSub1.ID, "Mixed substrate 1 not found in list")
	assert.Contains(t, ids, mixedSub2.ID, "Mixed substrate 2 not found in list")
	assert.Contains(t, ids, mixedSub3.ID, "Mixed substrate 3 not found in list")
}

// TestMixedSubstrateRepository_Exists prueba la verificación de existencia de un sustrato mixto
func TestMixedSubstrateRepository_Exists(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear un sustrato mixto
	mixedSub := createTestMixedSubstrate()
	
	// Caso 1: Sustrato mixto no existe
	exists, err := repo.Exists(mixedSub.ID)
	require.NoError(t, err, "Failed to check if mixed substrate exists")
	assert.False(t, exists, "Mixed substrate should not exist")
	
	// Guardar el sustrato mixto
	err = repo.Create(mixedSub)
	require.NoError(t, err, "Failed to create mixed substrate")
	
	// Caso 2: Sustrato mixto existe
	exists, err = repo.Exists(mixedSub.ID)
	require.NoError(t, err, "Failed to check if mixed substrate exists")
	assert.True(t, exists, "Mixed substrate should exist")
}

// TestMixedSubstrateRepository_FindBySubstrateID prueba la búsqueda de sustratos mixtos por ID de sustrato
func TestMixedSubstrateRepository_FindBySubstrateID(t *testing.T) {
	repo := setupMixedSubstrateRepository(t)
	
	// Crear varios sustratos mixtos con diferentes sustratos
	substrateID1 := uuid.New().String()
	substrateID2 := uuid.New().String()
	
	// Sustrato mixto 1: contiene sustrato 1
	mixedSub1 := substrate.MixedSubstrate{
		ID:    uuid.New().String(),
		Name:  "Mixed Substrate 1",
		Color: "#FF0000",
		Substrates: []substrate.SubstratePercentage{
			{
				Substrate: substrate.Substrate{
					ID:    substrateID1,
					Name:  "Substrate 1",
					Color: "#00FF00",
				},
				Percentage: 100.0,
			},
		},
	}
	
	// Sustrato mixto 2: contiene sustrato 2
	mixedSub2 := substrate.MixedSubstrate{
		ID:    uuid.New().String(),
		Name:  "Mixed Substrate 2",
		Color: "#0000FF",
		Substrates: []substrate.SubstratePercentage{
			{
				Substrate: substrate.Substrate{
					ID:    substrateID2,
					Name:  "Substrate 2",
					Color: "#FFFF00",
				},
				Percentage: 100.0,
			},
		},
	}
	
	// Sustrato mixto 3: contiene sustrato 1 y 2
	mixedSub3 := substrate.MixedSubstrate{
		ID:    uuid.New().String(),
		Name:  "Mixed Substrate 3",
		Color: "#FF00FF",
		Substrates: []substrate.SubstratePercentage{
			{
				Substrate: substrate.Substrate{
					ID:    substrateID1,
					Name:  "Substrate 1",
					Color: "#00FF00",
				},
				Percentage: 50.0,
			},
			{
				Substrate: substrate.Substrate{
					ID:    substrateID2,
					Name:  "Substrate 2",
					Color: "#FFFF00",
				},
				Percentage: 50.0,
			},
		},
	}
	
	// Guardar los sustratos mixtos
	err := repo.Create(mixedSub1)
	require.NoError(t, err, "Failed to create mixed substrate 1")
	
	err = repo.Create(mixedSub2)
	require.NoError(t, err, "Failed to create mixed substrate 2")
	
	err = repo.Create(mixedSub3)
	require.NoError(t, err, "Failed to create mixed substrate 3")
	
	// Caso 1: Buscar sustratos mixtos que contienen el sustrato 1
	mixedSubs, err := repo.FindBySubstrateID(substrateID1)
	require.NoError(t, err, "Failed to find mixed substrates by substrate ID")
	assert.Len(t, mixedSubs, 2, "Expected 2 mixed substrates containing substrate 1")
	
	// Verificar que los IDs de los sustratos mixtos están en la lista
	ids := make([]string, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		ids[i] = mixedSub.ID
	}
	
	assert.Contains(t, ids, mixedSub1.ID, "Mixed substrate 1 not found in list")
	assert.Contains(t, ids, mixedSub3.ID, "Mixed substrate 3 not found in list")
	
	// Caso 2: Buscar sustratos mixtos que contienen el sustrato 2
	mixedSubs, err = repo.FindBySubstrateID(substrateID2)
	require.NoError(t, err, "Failed to find mixed substrates by substrate ID")
	assert.Len(t, mixedSubs, 2, "Expected 2 mixed substrates containing substrate 2")
	
	// Verificar que los IDs de los sustratos mixtos están en la lista
	ids = make([]string, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		ids[i] = mixedSub.ID
	}
	
	assert.Contains(t, ids, mixedSub2.ID, "Mixed substrate 2 not found in list")
	assert.Contains(t, ids, mixedSub3.ID, "Mixed substrate 3 not found in list")
	
	// Caso 3: Buscar sustratos mixtos que contienen un sustrato que no existe
	mixedSubs, err = repo.FindBySubstrateID(uuid.New().String())
	require.NoError(t, err, "Failed to find mixed substrates by substrate ID")
	assert.Empty(t, mixedSubs, "Expected empty list of mixed substrates")
}
