package substrate

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/benjaminpina/galatea/internal/adapters/handlers/fiber/substrate/mocks"
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// setupTestApp configura una aplicación Fiber para pruebas
func setupTestApp(mockSvc *mocks.MockMixedSubstrateService) *fiber.App {
	app := fiber.New()
	handler := NewMixedSubstrateHandler(mockSvc)
	handler.RegisterRoutes(app)
	return app
}

// createTestMixedSubstrate crea un MixedSubstrate de prueba
func createTestMixedSubstrate() *substrate.MixedSubstrate {
	subID := uuid.New().String()
	return &substrate.MixedSubstrate{
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
				Percentage: 60.0,
			},
		},
	}
}

// TestMixedSubstrateHandler_CreateMixedSubstrate prueba la creación de un sustrato mixto
func TestMixedSubstrateHandler_CreateMixedSubstrate(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Creación exitosa
	t.Run("Successful creation", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSub := createTestMixedSubstrate()
		mockSvc.On("CreateMixedSubstrate", mock.Anything, "Test Mixed Substrate", "#FF0000").
			Return(mixedSub, nil).Once()

		// Crear request
		reqBody := MixedSubstrateRequest{
			Name:  "Test Mixed Substrate",
			Color: "#FF0000",
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusCreated, resp.StatusCode, "Expected status 201 Created")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Equal(t, mixedSub.Name, respBody.Name, "Names do not match")
		assert.Equal(t, mixedSub.Color, respBody.Color, "Colors do not match")
		assert.Len(t, respBody.Substrates, 1, "Expected 1 substrate in the mix")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Error al crear
	t.Run("Creation error", func(t *testing.T) {
		// Configurar expectativas del mock
		mockSvc.On("CreateMixedSubstrate", mock.Anything, "Error Substrate", "#FF0000").
			Return(nil, errors.New("creation error")).Once()

		// Crear request
		reqBody := MixedSubstrateRequest{
			Name:  "Error Substrate",
			Color: "#FF0000",
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode, "Expected status 500 Internal Server Error")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "creation error", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 3: Cuerpo de solicitud inválido
	t.Run("Invalid request body", func(t *testing.T) {
		// Crear request con JSON inválido
		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates", bytes.NewReader([]byte("invalid json")))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "Invalid request body", respBody.Error, "Error message does not match")
	})
}

// TestMixedSubstrateHandler_GetMixedSubstrate prueba la obtención de un sustrato mixto
func TestMixedSubstrateHandler_GetMixedSubstrate(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Obtención exitosa
	t.Run("Successful retrieval", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSub := createTestMixedSubstrate()
		mockSvc.On("GetMixedSubstrate", mixedSub.ID).
			Return(mixedSub, nil).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodGet, "/api/v1/mixed-substrates/"+mixedSub.ID, nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Equal(t, mixedSub.Name, respBody.Name, "Names do not match")
		assert.Equal(t, mixedSub.Color, respBody.Color, "Colors do not match")
		assert.Len(t, respBody.Substrates, 1, "Expected 1 substrate in the mix")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mockSvc.On("GetMixedSubstrate", "non-existing-id").
			Return(nil, errors.New("mixed substrate not found")).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodGet, "/api/v1/mixed-substrates/non-existing-id", nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})
}

// TestMixedSubstrateHandler_UpdateMixedSubstrate prueba la actualización de un sustrato mixto
func TestMixedSubstrateHandler_UpdateMixedSubstrate(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Actualización exitosa
	t.Run("Successful update", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		mixedSub := createTestMixedSubstrate()
		mixedSub.ID = mixedSubID
		mixedSub.Name = "Updated Mixed Substrate"
		mixedSub.Color = "#00FF00"
		
		mockSvc.On("UpdateMixedSubstrate", mixedSubID, "Updated Mixed Substrate", "#00FF00").
			Return(mixedSub, nil).Once()

		// Crear request
		reqBody := MixedSubstrateRequest{
			Name:  "Updated Mixed Substrate",
			Color: "#00FF00",
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Equal(t, "Updated Mixed Substrate", respBody.Name, "Names do not match")
		assert.Equal(t, "#00FF00", respBody.Color, "Colors do not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mockSvc.On("UpdateMixedSubstrate", "non-existing-id", "Updated Mixed Substrate", "#00FF00").
			Return(nil, errors.New("mixed substrate not found")).Once()

		// Crear request
		reqBody := MixedSubstrateRequest{
			Name:  "Updated Mixed Substrate",
			Color: "#00FF00",
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/non-existing-id", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 3: Cuerpo de solicitud inválido
	t.Run("Invalid request body", func(t *testing.T) {
		// Crear request con JSON inválido
		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+uuid.New().String(), bytes.NewReader([]byte("invalid json")))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "Invalid request body", respBody.Error, "Error message does not match")
	})
}

// TestMixedSubstrateHandler_DeleteMixedSubstrate prueba la eliminación de un sustrato mixto
func TestMixedSubstrateHandler_DeleteMixedSubstrate(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Eliminación exitosa
	t.Run("Successful deletion", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		mockSvc.On("DeleteMixedSubstrate", mixedSubID).
			Return(nil).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/mixed-substrates/"+mixedSubID, nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNoContent, resp.StatusCode, "Expected status 204 No Content")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mockSvc.On("DeleteMixedSubstrate", "non-existing-id").
			Return(errors.New("mixed substrate not found")).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/mixed-substrates/non-existing-id", nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})
}

// TestMixedSubstrateHandler_ListMixedSubstrates prueba el listado de sustratos mixtos
func TestMixedSubstrateHandler_ListMixedSubstrates(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Listado exitoso
	t.Run("Successful listing", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSub1 := createTestMixedSubstrate()
		mixedSub2 := createTestMixedSubstrate()
		mixedSub2.ID = uuid.New().String()
		mixedSub2.Name = "Another Mixed Substrate"

		// Crear objeto de paginación
		pagination := &common.PaginatedResult{
			Page:       1,
			PageSize:   10,
			TotalCount: 2,
			TotalPages: 1,
		}

		mockSvc.On("List", 1, 10).
			Return([]substrate.MixedSubstrate{*mixedSub1, *mixedSub2}, pagination, nil).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodGet, "/api/v1/mixed-substrates", nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstratePaginatedResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Len(t, respBody.Data, 2, "Expected 2 mixed substrates in the response")
		assert.Equal(t, mixedSub1.ID, respBody.Data[0].ID, "First mixed substrate ID does not match")
		assert.Equal(t, mixedSub2.ID, respBody.Data[1].ID, "Second mixed substrate ID does not match")
		assert.Equal(t, 1, respBody.Pagination.Page, "Page number does not match")
		assert.Equal(t, 10, respBody.Pagination.PageSize, "Page size does not match")
		assert.Equal(t, 2, respBody.Pagination.TotalCount, "Total count does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Error al listar
	t.Run("Listing error", func(t *testing.T) {
		// Configurar expectativas del mock
		mockSvc.On("List", 1, 10).
			Return(nil, nil, errors.New("listing error")).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodGet, "/api/v1/mixed-substrates", nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusInternalServerError, resp.StatusCode, "Expected status 500 Internal Server Error")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "listing error", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})
}

// TestMixedSubstrateHandler_AddSubstrateToMix prueba la adición de un sustrato a un sustrato mixto
func TestMixedSubstrateHandler_AddSubstrateToMix(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Adición exitosa
	t.Run("Successful addition", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		// Mock para la operación de adición
		mockSvc.On("AddSubstrateToMix", mixedSubID, substrateID, 60.0).
			Return(nil).Once()
		
		// Mock para obtener el sustrato mixto actualizado
		mixedSub := createTestMixedSubstrate()
		mixedSub.ID = mixedSubID
		// Asegurarse de que el sustrato en el mix tenga el ID correcto
		mixedSub.Substrates[0].Substrate.ID = substrateID
		
		mockSvc.On("GetMixedSubstrate", mixedSubID).
			Return(mixedSub, nil).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  60.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Len(t, respBody.Substrates, 1, "Expected 1 substrate in the mix")
		assert.Equal(t, substrateID, respBody.Substrates[0].SubstrateID, "Substrate IDs do not match")
		assert.Equal(t, 60.0, respBody.Substrates[0].Percentage, "Percentages do not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := "non-existing-id"
		substrateID := uuid.New().String()
		
		mockSvc.On("AddSubstrateToMix", mixedSubID, substrateID, 60.0).
			Return(errors.New("mixed substrate not found")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  60.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 3: Sustrato no encontrado
	t.Run("Substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := "non-existing-substrate"
		
		mockSvc.On("AddSubstrateToMix", mixedSubID, substrateID, 60.0).
			Return(errors.New("substrate not found")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  60.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 4: Sustrato ya existe en el mix
	t.Run("Substrate already exists in mix", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		mockSvc.On("AddSubstrateToMix", mixedSubID, substrateID, 60.0).
			Return(errors.New("substrate already exists in the mix")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  60.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "substrate already exists in the mix", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 5: Porcentaje total excede 100%
	t.Run("Total percentage exceeds 100%", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		mockSvc.On("AddSubstrateToMix", mixedSubID, substrateID, 60.0).
			Return(errors.New("total percentage exceeds 100%")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  60.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates", bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "total percentage exceeds 100%", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 6: Cuerpo de solicitud inválido
	t.Run("Invalid request body", func(t *testing.T) {
		// Crear request con JSON inválido
		req := httptest.NewRequest(http.MethodPost, "/api/v1/mixed-substrates/"+uuid.New().String()+"/substrates", bytes.NewReader([]byte("invalid json")))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "Invalid request body", respBody.Error, "Error message does not match")
	})
}

// TestMixedSubstrateHandler_RemoveSubstrateFromMix prueba la eliminación de un sustrato de un sustrato mixto
func TestMixedSubstrateHandler_RemoveSubstrateFromMix(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Eliminación exitosa
	t.Run("Successful removal", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		// Mock para la operación de eliminación
		mockSvc.On("RemoveSubstrateFromMix", mixedSubID, substrateID).
			Return(nil).Once()
		
		// Mock para obtener el sustrato mixto actualizado
		mixedSub := createTestMixedSubstrate()
		mixedSub.ID = mixedSubID
		// Simulamos que ya no hay sustratos en el mix después de eliminar
		mixedSub.Substrates = []substrate.SubstratePercentage{}
		
		mockSvc.On("GetMixedSubstrate", mixedSubID).
			Return(mixedSub, nil).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Empty(t, respBody.Substrates, "Expected no substrates in the mix after removal")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := "non-existing-id"
		substrateID := uuid.New().String()
		
		mockSvc.On("RemoveSubstrateFromMix", mixedSubID, substrateID).
			Return(errors.New("mixed substrate not found")).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 3: Sustrato no encontrado en el mix
	t.Run("Substrate not found in mix", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		mockSvc.On("RemoveSubstrateFromMix", mixedSubID, substrateID).
			Return(errors.New("substrate not found in the mix")).Once()

		// Crear request
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, nil)

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "substrate not found in the mix", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})
}

// TestMixedSubstrateHandler_UpdateSubstratePercentage prueba la actualización del porcentaje de un sustrato en un sustrato mixto
func TestMixedSubstrateHandler_UpdateSubstratePercentage(t *testing.T) {
	// Crear mock del servicio
	mockSvc := new(mocks.MockMixedSubstrateService)

	// Configurar app para pruebas
	app := setupTestApp(mockSvc)

	// Caso 1: Actualización exitosa
	t.Run("Successful update", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		// Mock para la operación de actualización
		mockSvc.On("UpdateSubstratePercentage", mixedSubID, substrateID, 80.0).
			Return(nil).Once()
		
		// Mock para obtener el sustrato mixto actualizado
		mixedSub := createTestMixedSubstrate()
		mixedSub.ID = mixedSubID
		// Actualizar el sustrato en el mix con el nuevo porcentaje
		mixedSub.Substrates[0].Substrate.ID = substrateID
		mixedSub.Substrates[0].Percentage = 80.0
		
		mockSvc.On("GetMixedSubstrate", mixedSubID).
			Return(mixedSub, nil).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  80.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status 200 OK")

		// Verificar cuerpo de la respuesta
		var respBody MixedSubstrateResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, mixedSub.ID, respBody.ID, "IDs do not match")
		assert.Len(t, respBody.Substrates, 1, "Expected 1 substrate in the mix")
		assert.Equal(t, substrateID, respBody.Substrates[0].SubstrateID, "Substrate IDs do not match")
		assert.Equal(t, 80.0, respBody.Substrates[0].Percentage, "Percentages do not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 2: Sustrato mixto no encontrado
	t.Run("Mixed substrate not found", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := "non-existing-id"
		substrateID := uuid.New().String()
		
		mockSvc.On("UpdateSubstratePercentage", mixedSubID, substrateID, 80.0).
			Return(errors.New("mixed substrate not found")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  80.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "mixed substrate not found", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 3: Sustrato no encontrado en el mix
	t.Run("Substrate not found in mix", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		mockSvc.On("UpdateSubstratePercentage", mixedSubID, substrateID, 80.0).
			Return(errors.New("substrate not found in the mix")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  80.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusNotFound, resp.StatusCode, "Expected status 404 Not Found")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "substrate not found in the mix", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 4: Porcentaje total excede 100%
	t.Run("Total percentage exceeds 100%", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		
		mockSvc.On("UpdateSubstratePercentage", mixedSubID, substrateID, 80.0).
			Return(errors.New("total percentage exceeds 100%")).Once()

		// Crear request
		reqBody := SubstratePercentageRequest{
			SubstrateID: substrateID,
			Percentage:  80.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "total percentage exceeds 100%", respBody.Error, "Error message does not match")

		// Verificar que se llamó al servicio como se esperaba
		mockSvc.AssertExpectations(t)
	})

	// Caso 5: ID de sustrato en la ruta no coincide con el ID en el cuerpo
	t.Run("Substrate ID mismatch", func(t *testing.T) {
		// Configurar expectativas del mock
		mixedSubID := uuid.New().String()
		substrateID := uuid.New().String()
		differentSubstrateID := uuid.New().String()
		
		// Crear request con ID de sustrato diferente en el cuerpo
		reqBody := SubstratePercentageRequest{
			SubstrateID: differentSubstrateID, // Diferente al de la ruta
			Percentage:  80.0,
		}
		reqJSON, err := json.Marshal(reqBody)
		require.NoError(t, err, "Failed to marshal request body")

		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+mixedSubID+"/substrates/"+substrateID, bytes.NewReader(reqJSON))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "Substrate ID in path must match substrate ID in request body", respBody.Error, "Error message does not match")
	})

	// Caso 6: Cuerpo de solicitud inválido
	t.Run("Invalid request body", func(t *testing.T) {
		// Crear request con JSON inválido
		req := httptest.NewRequest(http.MethodPut, "/api/v1/mixed-substrates/"+uuid.New().String()+"/substrates/"+uuid.New().String(), bytes.NewReader([]byte("invalid json")))
		req.Header.Set("Content-Type", "application/json")

		// Ejecutar request
		resp, err := app.Test(req)
		require.NoError(t, err, "Failed to test request")

		// Verificar respuesta
		assert.Equal(t, http.StatusBadRequest, resp.StatusCode, "Expected status 400 Bad Request")

		// Verificar cuerpo de la respuesta
		var respBody ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&respBody)
		require.NoError(t, err, "Failed to decode response body")

		assert.Equal(t, "Invalid request body", respBody.Error, "Error message does not match")
	})
}
