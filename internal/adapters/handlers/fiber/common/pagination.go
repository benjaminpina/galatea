package common

import (
	"strconv"
	
	"github.com/gofiber/fiber/v2"
	
	"github.com/benjaminpina/galatea/internal/core/domain/common"
)

// PaginationResponse represents a pagination response
// @Description Pagination information for list endpoints
type PaginationResponse struct {
	Page       int `json:"page" example:"1" description:"Current page number"`
	PageSize   int `json:"page_size" example:"10" description:"Number of items per page"`
	TotalCount int `json:"total_count" example:"100" description:"Total number of items"`
	TotalPages int `json:"total_pages" example:"10" description:"Total number of pages"`
}

// SwaggerPaginationInfo represents pagination information for Swagger documentation
type SwaggerPaginationInfo struct {
	Page       int `json:"page" example:"1" description:"Current page number"`
	PageSize   int `json:"page_size" example:"10" description:"Number of items per page"`
	TotalCount int `json:"total_count" example:"100" description:"Total number of items"`
	TotalPages int `json:"total_pages" example:"10" description:"Total number of pages"`
}

// GetPaginationParams extracts pagination parameters from a request
func GetPaginationParams(c *fiber.Ctx) (int, int) {
	page := 1
	pageSize := 10
	
	if c.Query("page") != "" {
		page, _ = strconv.Atoi(c.Query("page"))
	}
	
	if c.Query("page_size") != "" {
		pageSize, _ = strconv.Atoi(c.Query("page_size"))
	}
	
	return page, pageSize
}

// MapPaginationToResponse maps a domain pagination to a response object
func MapPaginationToResponse(pagination *common.PaginatedResult) PaginationResponse {
	return PaginationResponse{
		Page:       pagination.Page,
		PageSize:   pagination.PageSize,
		TotalCount: pagination.TotalCount,
		TotalPages: pagination.TotalPages,
	}
}
