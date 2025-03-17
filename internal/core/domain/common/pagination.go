package common

// PaginationParams defines the parameters for pagination
type PaginationParams struct {
	Page     int
	PageSize int
}

// PaginatedResult represents a paginated result set
type PaginatedResult struct {
	TotalCount int
	TotalPages int
	Page       int
	PageSize   int
}
