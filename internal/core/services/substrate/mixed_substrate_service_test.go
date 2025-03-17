package substrate

import (
	"errors"
	"testing"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockMixedSubstrateRepository is a mock of the MixedSubstrateRepository interface
type MockMixedSubstrateRepository struct {
	mock.Mock
}

func (m *MockMixedSubstrateRepository) Create(mixedSub substrate.MixedSubstrate) error {
	args := m.Called(mixedSub)
	return args.Error(0)
}

func (m *MockMixedSubstrateRepository) GetByID(id string) (*substrate.MixedSubstrate, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.MixedSubstrate), args.Error(1)
}

func (m *MockMixedSubstrateRepository) Update(mixedSub substrate.MixedSubstrate) error {
	args := m.Called(mixedSub)
	return args.Error(0)
}

func (m *MockMixedSubstrateRepository) Delete(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockMixedSubstrateRepository) List(params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	args := m.Called(params)
	return args.Get(0).([]substrate.MixedSubstrate), args.Int(1), args.Error(2)
}

func (m *MockMixedSubstrateRepository) Exists(id string) (bool, error) {
	args := m.Called(id)
	return args.Bool(0), args.Error(1)
}

func (m *MockMixedSubstrateRepository) FindBySubstrateID(substrateID string, params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	args := m.Called(substrateID, params)
	return args.Get(0).([]substrate.MixedSubstrate), args.Int(1), args.Error(2)
}

// MockSubstrateService is a mock of the SubstrateService interface
type MockSubstrateService struct {
	mock.Mock
}

func (m *MockSubstrateService) CreateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	args := m.Called(id, name, color)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.Substrate), args.Error(1)
}

func (m *MockSubstrateService) GetSubstrate(id string) (*substrate.Substrate, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.Substrate), args.Error(1)
}

func (m *MockSubstrateService) UpdateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	args := m.Called(id, name, color)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.Substrate), args.Error(1)
}

func (m *MockSubstrateService) DeleteSubstrate(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

func (m *MockSubstrateService) List(page, pageSize int) ([]substrate.Substrate, *common.PaginatedResult, error) {
	args := m.Called(page, pageSize)
	if args.Get(0) == nil {
		return nil, nil, args.Error(2)
	}
	return args.Get(0).([]substrate.Substrate), args.Get(1).(*common.PaginatedResult), args.Error(2)
}

func TestMixedSubstrateService_List(t *testing.T) {
	// Setup
	mockRepo := new(MockMixedSubstrateRepository)
	mockSubstrateService := new(MockSubstrateService)
	service := NewMixedSubstrateService(mockRepo, mockSubstrateService)

	// Test case 1: Successful retrieval
	t.Run("Successful retrieval", func(t *testing.T) {
		// Define test data
		page := 1
		pageSize := 10
		paginationParams := common.PaginationParams{
			Page:     page,
			PageSize: pageSize,
		}
		
		mixedSubstrates := []substrate.MixedSubstrate{
			{
				ID:    "1",
				Name:  "Mixed Substrate 1",
				Color: "Brown",
				Substrates: []substrate.SubstratePercentage{
					{
						Substrate: substrate.Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "Brown",
						},
						Percentage: 60.0,
					},
				},
			},
			{
				ID:    "2",
				Name:  "Mixed Substrate 2",
				Color: "Red",
				Substrates: []substrate.SubstratePercentage{
					{
						Substrate: substrate.Substrate{
							ID:    "sub2",
							Name:  "Substrate 2",
							Color: "Red",
						},
						Percentage: 40.0,
					},
				},
			},
		}
		totalCount := 2

		// Setup mock expectations
		mockRepo.On("List", paginationParams).Return(mixedSubstrates, totalCount, nil)

		// Call the service
		result, paginatedResult, err := service.List(page, pageSize)

		// Assertions
		assert.NoError(t, err)
		assert.Equal(t, mixedSubstrates, result)
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 1, paginatedResult.TotalPages)
		assert.Equal(t, page, paginatedResult.Page)
		assert.Equal(t, pageSize, paginatedResult.PageSize)
		mockRepo.AssertExpectations(t)
	})

	// Test case 2: Error from repository
	t.Run("Repository error", func(t *testing.T) {
		// Define test data
		page := 1
		pageSize := 10
		paginationParams := common.PaginationParams{
			Page:     page,
			PageSize: pageSize,
		}
		expectedError := errors.New("repository error")

		// Setup mock expectations - clear previous expectations
		mockRepo = new(MockMixedSubstrateRepository)
		service = NewMixedSubstrateService(mockRepo, mockSubstrateService)
		
		// Setup the error case
		mockRepo.On("List", paginationParams).Return([]substrate.MixedSubstrate{}, 0, expectedError)

		// Call the service
		result, paginatedResult, err := service.List(page, pageSize)

		// Assertions
		assert.Error(t, err)
		assert.Equal(t, expectedError, err)
		assert.Nil(t, paginatedResult)
		assert.Empty(t, result)
		mockRepo.AssertExpectations(t)
	})
}

func TestMixedSubstrateService_FindBySubstrateID(t *testing.T) {
	// Setup
	mockRepo := new(MockMixedSubstrateRepository)
	mockSubstrateService := new(MockSubstrateService)
	service := NewMixedSubstrateService(mockRepo, mockSubstrateService)

	// Test case 1: Successful retrieval
	t.Run("Successful retrieval", func(t *testing.T) {
		// Define test data
		substrateID := "sub1"
		page := 1
		pageSize := 10
		paginationParams := common.PaginationParams{
			Page:     page,
			PageSize: pageSize,
		}
		
		mixedSubstrates := []substrate.MixedSubstrate{
			{
				ID:    "1",
				Name:  "Mixed Substrate 1",
				Color: "Brown",
				Substrates: []substrate.SubstratePercentage{
					{
						Substrate: substrate.Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "Brown",
						},
						Percentage: 60.0,
					},
				},
			},
			{
				ID:    "2",
				Name:  "Mixed Substrate 2",
				Color: "Dark Brown",
				Substrates: []substrate.SubstratePercentage{
					{
						Substrate: substrate.Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "Brown",
						},
						Percentage: 40.0,
					},
				},
			},
		}
		totalCount := 2

		// Setup mock expectations
		mockRepo.On("FindBySubstrateID", substrateID, paginationParams).Return(mixedSubstrates, totalCount, nil)

		// Call the service
		result, paginatedResult, err := service.FindBySubstrateID(substrateID, page, pageSize)

		// Assertions
		assert.NoError(t, err)
		assert.Equal(t, mixedSubstrates, result)
		assert.Equal(t, totalCount, paginatedResult.TotalCount)
		assert.Equal(t, 1, paginatedResult.TotalPages)
		assert.Equal(t, page, paginatedResult.Page)
		assert.Equal(t, pageSize, paginatedResult.PageSize)
		mockRepo.AssertExpectations(t)
	})

	// Test case 2: Error from repository
	t.Run("Repository error", func(t *testing.T) {
		// Define test data
		substrateID := "sub1"
		page := 1
		pageSize := 10
		paginationParams := common.PaginationParams{
			Page:     page,
			PageSize: pageSize,
		}
		expectedError := errors.New("repository error")

		// Setup mock expectations - clear previous expectations
		mockRepo = new(MockMixedSubstrateRepository)
		service = NewMixedSubstrateService(mockRepo, mockSubstrateService)
		
		// Setup the error case
		mockRepo.On("FindBySubstrateID", substrateID, paginationParams).Return([]substrate.MixedSubstrate{}, 0, expectedError)

		// Call the service
		result, paginatedResult, err := service.FindBySubstrateID(substrateID, page, pageSize)

		// Assertions
		assert.Error(t, err)
		assert.Equal(t, expectedError, err)
		assert.Nil(t, paginatedResult)
		assert.Empty(t, result)
		mockRepo.AssertExpectations(t)
	})
}
