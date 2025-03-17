package common

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
)

// PaginationResponse represents pagination information for the GUI
type PaginationResponse struct {
	Page       int `json:"page"`
	PageSize   int `json:"page_size"`
	TotalCount int `json:"total_count"`
	TotalPages int `json:"total_pages"`
}

// MapPaginationInfo converts a domain PaginatedResult to a GUI PaginationResponse
func MapPaginationInfo(pagination *common.PaginatedResult) PaginationResponse {
	return PaginationResponse{
		Page:       pagination.Page,
		PageSize:   pagination.PageSize,
		TotalCount: pagination.TotalCount,
		TotalPages: pagination.TotalPages,
	}
}
