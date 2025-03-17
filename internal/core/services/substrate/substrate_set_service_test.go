package substrate

import (
	"errors"
	"testing"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockSubstrateSetRepository es un mock del repositorio de conjuntos de sustratos
type MockSubstrateSetRepository struct {
	mock.Mock
}

func (m *MockSubstrateSetRepository) Create(set substrate.SubstrateSet) error {
	args := m.Called(set)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) GetByID(id string) (*substrate.SubstrateSet, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.SubstrateSet), args.Error(1)
}

func (m *MockSubstrateSetRepository) Update(set substrate.SubstrateSet) error {
	args := m.Called(set)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) Delete(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) List(params common.PaginationParams) ([]substrate.SubstrateSet, int, error) {
	args := m.Called(params)
	return args.Get(0).([]substrate.SubstrateSet), args.Int(1), args.Error(2)
}

func (m *MockSubstrateSetRepository) ListPaginated(params common.PaginationParams) ([]substrate.SubstrateSet, int, error) {
	args := m.Called(params)
	return args.Get(0).([]substrate.SubstrateSet), args.Int(1), args.Error(2)
}

func (m *MockSubstrateSetRepository) Exists(id string) (bool, error) {
	args := m.Called(id)
	return args.Bool(0), args.Error(1)
}

func (m *MockSubstrateSetRepository) AddSubstrate(setID string, sub substrate.Substrate) error {
	args := m.Called(setID, sub)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) RemoveSubstrate(setID string, substrateID string) error {
	args := m.Called(setID, substrateID)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) AddMixedSubstrate(setID string, mixedSub substrate.MixedSubstrate) error {
	args := m.Called(setID, mixedSub)
	return args.Error(0)
}

func (m *MockSubstrateSetRepository) RemoveMixedSubstrate(setID string, mixedSubstrateID string) error {
	args := m.Called(setID, mixedSubstrateID)
	return args.Error(0)
}

func TestSubstrateSetService_CreateSubstrateSet(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("Create with provided ID", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate Set"

		mockRepo.On("Create", mock.MatchedBy(func(set substrate.SubstrateSet) bool {
			return set.ID == id && set.Name == name
		})).Return(nil).Once()

		set, err := service.CreateSubstrateSet(id, name)
		assert.NoError(t, err)
		assert.Equal(t, id, set.ID)
		assert.Equal(t, name, set.Name)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Create with generated ID", func(t *testing.T) {
		name := "Test Substrate Set"

		mockRepo.On("Create", mock.MatchedBy(func(set substrate.SubstrateSet) bool {
			return set.Name == name && set.ID != ""
		})).Return(nil).Once()

		set, err := service.CreateSubstrateSet("", name)
		assert.NoError(t, err)
		assert.NotEmpty(t, set.ID)
		assert.Equal(t, name, set.Name)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Create with repository error", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate Set"
		expectedErr := errors.New("repository error")

		mockRepo.On("Create", mock.MatchedBy(func(set substrate.SubstrateSet) bool {
			return set.ID == id && set.Name == name
		})).Return(expectedErr).Once()

		set, err := service.CreateSubstrateSet(id, name)
		assert.Error(t, err)
		assert.Nil(t, set)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateSetService_GetSubstrateSet(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("Get existing substrate set", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate Set"
		expectedSet := substrate.NewSubstrateSet(id, name)

		mockRepo.On("GetByID", id).Return(expectedSet, nil).Once()

		set, err := service.GetSubstrateSet(id)
		assert.NoError(t, err)
		assert.Equal(t, id, set.ID)
		assert.Equal(t, name, set.Name)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Get non-existent substrate set", func(t *testing.T) {
		id := uuid.New().String()
		expectedErr := errors.New("substrate set not found")

		mockRepo.On("GetByID", id).Return(nil, expectedErr).Once()

		set, err := service.GetSubstrateSet(id)
		assert.Error(t, err)
		assert.Nil(t, set)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateSetService_UpdateSubstrateSet(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("Update existing substrate set", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate Set"
		newName := "Updated Substrate Set"
		existingSet := substrate.NewSubstrateSet(id, name)

		mockRepo.On("GetByID", id).Return(existingSet, nil).Once()
		mockRepo.On("Update", mock.MatchedBy(func(set substrate.SubstrateSet) bool {
			return set.ID == id && set.Name == newName
		})).Return(nil).Once()

		set, err := service.UpdateSubstrateSet(id, newName)
		assert.NoError(t, err)
		assert.Equal(t, id, set.ID)
		assert.Equal(t, newName, set.Name)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Update non-existent substrate set", func(t *testing.T) {
		id := uuid.New().String()
		newName := "Updated Substrate Set"
		expectedErr := errors.New("substrate set not found")

		mockRepo.On("GetByID", id).Return(nil, expectedErr).Once()

		set, err := service.UpdateSubstrateSet(id, newName)
		assert.Error(t, err)
		assert.Nil(t, set)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Update with repository error", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate Set"
		newName := "Updated Substrate Set"
		existingSet := substrate.NewSubstrateSet(id, name)
		expectedErr := errors.New("repository error")

		mockRepo.On("GetByID", id).Return(existingSet, nil).Once()
		mockRepo.On("Update", mock.MatchedBy(func(set substrate.SubstrateSet) bool {
			return set.ID == id && set.Name == newName
		})).Return(expectedErr).Once()

		set, err := service.UpdateSubstrateSet(id, newName)
		assert.Error(t, err)
		assert.Nil(t, set)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateSetService_DeleteSubstrateSet(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("Delete existing substrate set", func(t *testing.T) {
		id := uuid.New().String()

		mockRepo.On("Exists", id).Return(true, nil).Once()
		mockRepo.On("Delete", id).Return(nil).Once()

		err := service.DeleteSubstrateSet(id)
		assert.NoError(t, err)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Delete non-existent substrate set", func(t *testing.T) {
		id := uuid.New().String()

		mockRepo.On("Exists", id).Return(false, nil).Once()

		err := service.DeleteSubstrateSet(id)
		assert.Error(t, err)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Delete with exists check error", func(t *testing.T) {
		id := uuid.New().String()
		expectedErr := errors.New("repository error")

		mockRepo.On("Exists", id).Return(false, expectedErr).Once()

		err := service.DeleteSubstrateSet(id)
		assert.Error(t, err)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Delete with repository error", func(t *testing.T) {
		id := uuid.New().String()
		expectedErr := errors.New("repository error")

		mockRepo.On("Exists", id).Return(true, nil).Once()
		mockRepo.On("Delete", id).Return(expectedErr).Once()

		err := service.DeleteSubstrateSet(id)
		assert.Error(t, err)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateSetService_ListSubstrateSets(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("List substrate sets successfully", func(t *testing.T) {
		expectedSets := []substrate.SubstrateSet{
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 1"),
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 2"),
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 3"),
		}

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == 1 && params.PageSize == 10
		})).Return(expectedSets, len(expectedSets), nil).Once()

		sets, paginatedResult, err := service.List(1, 10)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSets), len(sets))
		for i, set := range sets {
			assert.Equal(t, expectedSets[i].ID, set.ID)
			assert.Equal(t, expectedSets[i].Name, set.Name)
		}
		assert.Equal(t, 1, paginatedResult.Page)
		assert.Equal(t, 10, paginatedResult.PageSize)
		assert.Equal(t, len(expectedSets), paginatedResult.TotalCount)

		mockRepo.AssertExpectations(t)
	})

	t.Run("List with repository error", func(t *testing.T) {
		expectedErr := errors.New("repository error")
		var emptySets []substrate.SubstrateSet

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == 1 && params.PageSize == 10
		})).Return(emptySets, 0, expectedErr).Once()

		sets, paginatedResult, err := service.List(1, 10)
		assert.Error(t, err)
		assert.Empty(t, sets)
		assert.Nil(t, paginatedResult)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateSetService_List(t *testing.T) {
	mockRepo := new(MockSubstrateSetRepository)
	service := NewSubstrateSetService(mockRepo)

	t.Run("List paginated substrate sets successfully", func(t *testing.T) {
		expectedSets := []substrate.SubstrateSet{
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 1"),
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 2"),
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 3"),
		}
		totalCount := 10
		page := 1
		pageSize := 3

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == page && params.PageSize == pageSize
		})).Return(expectedSets, totalCount, nil).Once()

		sets, paginatedResult, err := service.List(page, pageSize)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSets), len(sets))
		for i, set := range sets {
			assert.Equal(t, expectedSets[i].ID, set.ID)
			assert.Equal(t, expectedSets[i].Name, set.Name)
		}
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 4, paginatedResult.TotalPages) // Ceiling of 10/3 = 4
		assert.Equal(t, page, paginatedResult.Page)
		assert.Equal(t, pageSize, paginatedResult.PageSize)

		mockRepo.AssertExpectations(t)
	})

	t.Run("List paginated with default parameters", func(t *testing.T) {
		expectedSets := []substrate.SubstrateSet{
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 1"),
			*substrate.NewSubstrateSet(uuid.New().String(), "Set 2"),
		}
		totalCount := 2
		defaultPage := 1
		defaultPageSize := 10

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == defaultPage && params.PageSize == defaultPageSize
		})).Return(expectedSets, totalCount, nil).Once()

		sets, paginatedResult, err := service.List(0, 0)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSets), len(sets))
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 1, paginatedResult.TotalPages) // Ceiling of 2/10 = 1
		assert.Equal(t, defaultPage, paginatedResult.Page)
		assert.Equal(t, defaultPageSize, paginatedResult.PageSize)

		mockRepo.AssertExpectations(t)
	})

	t.Run("List paginated with repository error", func(t *testing.T) {
		expectedErr := errors.New("repository error")
		var emptySets []substrate.SubstrateSet
		page := 1
		pageSize := 10

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == page && params.PageSize == pageSize
		})).Return(emptySets, 0, expectedErr).Once()

		sets, paginatedResult, err := service.List(page, pageSize)
		assert.Error(t, err)
		assert.Empty(t, sets)
		assert.Nil(t, paginatedResult)

		mockRepo.AssertExpectations(t)
	})
}
