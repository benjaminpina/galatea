package sqlite

import (
	"testing"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// setupSubstrateSetRepository configura un repositorio de conjuntos de sustratos para pruebas
func setupSubstrateSetRepository(t *testing.T) *SubstrateSetRepository {
	db := setupTestDB(t)
	repo := NewSubstrateSetRepository(db)
	
	// Asegurarse de que la tabla se inicializa correctamente
	err := repo.Initialize()
	require.NoError(t, err, "Failed to initialize substrate_sets table")
	
	return repo
}

func TestSubstrateSetRepository_Create(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear un conjunto de sustratos para prueba
	id := uuid.New().String()
	name := "Test Substrate Set"
	set := substrate.NewSubstrateSet(id, name)

	// Crear en el repositorio
	err := repo.Create(*set)
	assert.NoError(t, err)

	// Verificar que se haya creado correctamente
	exists, err := repo.Exists(id)
	assert.NoError(t, err)
	assert.True(t, exists)
}

func TestSubstrateSetRepository_GetByID(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear un conjunto de sustratos para prueba
	id := uuid.New().String()
	name := "Test Substrate Set"
	set := substrate.NewSubstrateSet(id, name)

	// Crear en el repositorio
	err := repo.Create(*set)
	assert.NoError(t, err)

	// Obtener por ID
	retrieved, err := repo.GetByID(id)
	assert.NoError(t, err)
	assert.NotNil(t, retrieved)
	assert.Equal(t, id, retrieved.ID)
	assert.Equal(t, name, retrieved.Name)

	// Intentar obtener un conjunto que no existe
	nonExistentID := uuid.New().String()
	_, err = repo.GetByID(nonExistentID)
	assert.Error(t, err)
}

func TestSubstrateSetRepository_Update(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear un conjunto de sustratos para prueba
	id := uuid.New().String()
	name := "Test Substrate Set"
	set := substrate.NewSubstrateSet(id, name)

	// Crear en el repositorio
	err := repo.Create(*set)
	assert.NoError(t, err)

	// Actualizar el nombre
	newName := "Updated Substrate Set"
	set.Name = newName

	// Actualizar en el repositorio
	err = repo.Update(*set)
	assert.NoError(t, err)

	// Verificar que se haya actualizado correctamente
	retrieved, err := repo.GetByID(id)
	assert.NoError(t, err)
	assert.Equal(t, newName, retrieved.Name)

	// Intentar actualizar un conjunto que no existe
	nonExistentSet := substrate.NewSubstrateSet(uuid.New().String(), "Non-existent")
	err = repo.Update(*nonExistentSet)
	assert.Error(t, err)
}

func TestSubstrateSetRepository_Delete(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear un conjunto de sustratos para prueba
	id := uuid.New().String()
	name := "Test Substrate Set"
	set := substrate.NewSubstrateSet(id, name)

	// Crear en el repositorio
	err := repo.Create(*set)
	assert.NoError(t, err)

	// Eliminar del repositorio
	err = repo.Delete(id)
	assert.NoError(t, err)

	// Verificar que se haya eliminado correctamente
	exists, err := repo.Exists(id)
	assert.NoError(t, err)
	assert.False(t, exists)

	// Intentar eliminar un conjunto que no existe
	err = repo.Delete(uuid.New().String())
	assert.Error(t, err)
}

func TestSubstrateSetRepository_List(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear varios conjuntos de sustratos para prueba
	sets := []substrate.SubstrateSet{
		*substrate.NewSubstrateSet(uuid.New().String(), "Set 1"),
		*substrate.NewSubstrateSet(uuid.New().String(), "Set 2"),
		*substrate.NewSubstrateSet(uuid.New().String(), "Set 3"),
	}

	// Crear en el repositorio
	for _, set := range sets {
		err := repo.Create(set)
		assert.NoError(t, err)
	}

	// Listar todos los conjuntos
	retrieved, err := repo.List()
	assert.NoError(t, err)
	assert.GreaterOrEqual(t, len(retrieved), len(sets))

	// Verificar que los conjuntos creados estén en la lista
	setMap := make(map[string]bool)
	for _, set := range retrieved {
		setMap[set.ID] = true
	}

	for _, set := range sets {
		assert.True(t, setMap[set.ID])
	}
}

func TestSubstrateSetRepository_Exists(t *testing.T) {
	repo := setupSubstrateSetRepository(t)

	// Crear un conjunto de sustratos para prueba
	id := uuid.New().String()
	name := "Test Substrate Set"
	set := substrate.NewSubstrateSet(id, name)

	// Verificar que no exista inicialmente
	exists, err := repo.Exists(id)
	assert.NoError(t, err)
	assert.False(t, exists)

	// Crear en el repositorio
	err = repo.Create(*set)
	assert.NoError(t, err)

	// Verificar que exista después de crearlo
	exists, err = repo.Exists(id)
	assert.NoError(t, err)
	assert.True(t, exists)
}
