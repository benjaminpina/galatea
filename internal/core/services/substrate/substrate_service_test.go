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

// MockSubstrateRepository is a mock of the SubstrateRepository interface
type MockSubstrateRepository struct {
	mock.Mock
}

func (m *MockSubstrateRepository) Create(sub substrate.Substrate) error {
	args := m.Called(sub)
	return args.Error(0)
}

func (m *MockSubstrateRepository) GetByID(id string) (*substrate.Substrate, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.Substrate), args.Error(1)
}

func (m *MockSubstrateRepository) Update(sub substrate.Substrate) error {
	args := m.Called(sub)
	return args.Error(0)
}

func (m *MockSubstrateRepository) Delete(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockSubstrateRepository) List(params common.PaginationParams) ([]substrate.Substrate, int, error) {
	args := m.Called(params)
	return args.Get(0).([]substrate.Substrate), args.Int(1), args.Error(2)
}

func (m *MockSubstrateRepository) ListPaginated(params common.PaginationParams) ([]substrate.Substrate, int, error) {
	args := m.Called(params)
	return args.Get(0).([]substrate.Substrate), args.Int(1), args.Error(2)
}

func (m *MockSubstrateRepository) Exists(id string) (bool, error) {
	args := m.Called(id)
	return args.Bool(0), args.Error(1)
}

func TestSubstrateService_CreateSubstrate(t *testing.T) {
	mockRepo := new(MockSubstrateRepository)
	service := NewSubstrateService(mockRepo)

	t.Run("Create with provided ID", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate"
		color := "#FF0000"

		// Mock the Exists method to return false (substrate doesn't exist)
		mockRepo.On("Exists", id).Return(false, nil).Once()
		
		mockRepo.On("Create", mock.MatchedBy(func(sub substrate.Substrate) bool {
			return sub.ID == id && sub.Name == name && sub.Color == color
		})).Return(nil).Once()

		sub, err := service.CreateSubstrate(id, name, color)
		assert.NoError(t, err)
		assert.Equal(t, id, sub.ID)
		assert.Equal(t, name, sub.Name)
		assert.Equal(t, color, sub.Color)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Create with generated ID", func(t *testing.T) {
		name := "Test Substrate"
		color := "#FF0000"

		// Mock the Exists method for any ID (since it's generated)
		mockRepo.On("Exists", mock.AnythingOfType("string")).Return(false, nil).Once()
		
		mockRepo.On("Create", mock.AnythingOfType("substrate.Substrate")).Return(nil).Once()

		sub, err := service.CreateSubstrate("", name, color)
		assert.NoError(t, err)
		assert.NotEmpty(t, sub.ID)
		assert.Equal(t, name, sub.Name)
		assert.Equal(t, color, sub.Color)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Create with repository error", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate"
		color := "#FF0000"
		expectedErr := errors.New("repository error")

		// Mock the Exists method to return false (substrate doesn't exist)
		mockRepo.On("Exists", id).Return(false, nil).Once()
		
		mockRepo.On("Create", mock.MatchedBy(func(sub substrate.Substrate) bool {
			return sub.ID == id && sub.Name == name && sub.Color == color
		})).Return(expectedErr).Once()

		sub, err := service.CreateSubstrate(id, name, color)
		assert.Error(t, err)
		assert.Nil(t, sub)
		assert.Contains(t, err.Error(), expectedErr.Error())

		mockRepo.AssertExpectations(t)
	})
	
	t.Run("Create when substrate already exists", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate"
		color := "#FF0000"

		// Mock the Exists method to return true (substrate already exists)
		mockRepo.On("Exists", id).Return(true, nil).Once()

		sub, err := service.CreateSubstrate(id, name, color)
		assert.Error(t, err)
		assert.Nil(t, sub)
		assert.Equal(t, "substrate already exists", err.Error())

		mockRepo.AssertExpectations(t)
	})
	
	t.Run("Create with error checking existence", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate"
		color := "#FF0000"
		expectedErr := errors.New("database error")

		// Mock the Exists method to return an error
		mockRepo.On("Exists", id).Return(false, expectedErr).Once()

		sub, err := service.CreateSubstrate(id, name, color)
		assert.Error(t, err)
		assert.Nil(t, sub)
		assert.Equal(t, expectedErr, err)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateService_GetSubstrate(t *testing.T) {
	mockRepo := new(MockSubstrateRepository)
	service := NewSubstrateService(mockRepo)

	t.Run("Get existing substrate", func(t *testing.T) {
		id := uuid.New().String()
		name := "Test Substrate"
		color := "#FF0000"
		expectedSub := substrate.NewSubstrate(id, name, color)

		mockRepo.On("GetByID", id).Return(expectedSub, nil).Once()

		sub, err := service.GetSubstrate(id)
		assert.NoError(t, err)
		assert.Equal(t, id, sub.ID)
		assert.Equal(t, name, sub.Name)
		assert.Equal(t, color, sub.Color)

		mockRepo.AssertExpectations(t)
	})

	t.Run("Get non-existent substrate", func(t *testing.T) {
		id := uuid.New().String()
		expectedErr := errors.New("substrate not found")

		mockRepo.On("GetByID", id).Return(nil, expectedErr).Once()

		sub, err := service.GetSubstrate(id)
		assert.Error(t, err)
		assert.Nil(t, sub)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateService_ListSubstrates(t *testing.T) {
	mockRepo := new(MockSubstrateRepository)
	service := NewSubstrateService(mockRepo)

	t.Run("List substrates successfully", func(t *testing.T) {
		expectedSubs := []substrate.Substrate{
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 1", "#FF0000"),
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 2", "#00FF00"),
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 3", "#0000FF"),
		}
		totalCount := len(expectedSubs)

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == 1 && params.PageSize == 1000
		})).Return(expectedSubs, totalCount, nil).Once()

		subs, paginatedResult, err := service.List(1, 1000)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSubs), len(subs))
		for i, sub := range subs {
			assert.Equal(t, expectedSubs[i].ID, sub.ID)
			assert.Equal(t, expectedSubs[i].Name, sub.Name)
			assert.Equal(t, expectedSubs[i].Color, sub.Color)
		}
		assert.Equal(t, 1, paginatedResult.Page)
		assert.Equal(t, 1000, paginatedResult.PageSize)
		assert.Equal(t, totalCount, paginatedResult.TotalCount)

		mockRepo.AssertExpectations(t)
	})

	t.Run("List with repository error", func(t *testing.T) {
		expectedErr := errors.New("repository error")
		var emptySubs []substrate.Substrate

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == 1 && params.PageSize == 1000
		})).Return(emptySubs, 0, expectedErr).Once()

		subs, paginatedResult, err := service.List(1, 1000)
		assert.Error(t, err)
		assert.Empty(t, subs)
		assert.Nil(t, paginatedResult)

		mockRepo.AssertExpectations(t)
	})
}

func TestSubstrateService_List(t *testing.T) {
	mockRepo := new(MockSubstrateRepository)
	service := NewSubstrateService(mockRepo)

	t.Run("List paginated substrates successfully", func(t *testing.T) {
		expectedSubs := []substrate.Substrate{
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 1", "#FF0000"),
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 2", "#00FF00"),
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 3", "#0000FF"),
		}
		totalCount := 10
		page := 1
		pageSize := 3

		mockRepo.On("List", mock.MatchedBy(func(params common.PaginationParams) bool {
			return params.Page == page && params.PageSize == pageSize
		})).Return(expectedSubs, totalCount, nil).Once()

		subs, paginatedResult, err := service.List(page, pageSize)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSubs), len(subs))
		for i, sub := range subs {
			assert.Equal(t, expectedSubs[i].ID, sub.ID)
			assert.Equal(t, expectedSubs[i].Name, sub.Name)
			assert.Equal(t, expectedSubs[i].Color, sub.Color)
		}
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 4, paginatedResult.TotalPages) // Ceiling of 10/3 = 4
		assert.Equal(t, page, paginatedResult.Page)
		assert.Equal(t, pageSize, paginatedResult.PageSize)

		mockRepo.AssertExpectations(t)
	})

	t.Run("List paginated with default parameters", func(t *testing.T) {
		// Crear un nuevo mock para este caso de prueba
		mockRepo = new(MockSubstrateRepository)
		service = NewSubstrateService(mockRepo)
		
		expectedSubs := []substrate.Substrate{
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 1", "#FF0000"),
			*substrate.NewSubstrate(uuid.New().String(), "Substrate 2", "#00FF00"),
		}
		totalCount := 2
		defaultPage := 1
		defaultPageSize := 10
		
		// Configurar el mock para que acepte los parámetros predeterminados
		paginationParams := common.PaginationParams{
			Page:     defaultPage,
			PageSize: defaultPageSize,
		}
		mockRepo.On("List", paginationParams).Return(expectedSubs, totalCount, nil)

		subs, paginatedResult, err := service.List(0, 0)
		assert.NoError(t, err)
		assert.Equal(t, len(expectedSubs), len(subs))
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 1, paginatedResult.TotalPages) // Ceiling of 2/10 = 1
		assert.Equal(t, defaultPage, paginatedResult.Page)
		assert.Equal(t, defaultPageSize, paginatedResult.PageSize)
		
		mockRepo.AssertExpectations(t)
	})

	t.Run("List paginated with repository error", func(t *testing.T) {
		// Crear un nuevo mock para este caso de prueba
		mockRepo = new(MockSubstrateRepository)
		service = NewSubstrateService(mockRepo)
		
		expectedErr := errors.New("repository error")
		var emptySubs []substrate.Substrate
		page := 1
		pageSize := 10

		// Configurar el mock para que devuelva un error
		paginationParams := common.PaginationParams{
			Page:     page,
			PageSize: pageSize,
		}
		mockRepo.On("List", paginationParams).Return(emptySubs, 0, expectedErr)

		subs, paginatedResult, err := service.List(page, pageSize)
		assert.Error(t, err)
		assert.Empty(t, subs)
		assert.Nil(t, paginatedResult)
		assert.Contains(t, err.Error(), expectedErr.Error())

		mockRepo.AssertExpectations(t)
	})
}
