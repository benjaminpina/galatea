# Galatea Makefile
# Variables for configuration
BINARY_NAME = galatea
CLI_BINARY = cli
BUILD_DIR = build/bin
FRONTEND_DIR = frontend
DIST_DIR = $(FRONTEND_DIR)/dist
WAILS_FLAGS = --tags webkit2_41
GO_FILES = $(shell find . -name "*.go" -type f -not -path "./vendor/*")
COVERAGE_FILE = coverage.out

.PHONY: run build-wails cli build-cli all test coverage clean lint fmt help

# Default target
.DEFAULT_GOAL := help

# Development
run: ## Run the application in development mode
	wails dev $(WAILS_FLAGS)

# Build targets
build-wails: ## Build the Wails application
	wails build $(WAILS_FLAGS)

cli: ## Run the CLI application
	go run cmd/cli/main.go

build-cli: ## Build the CLI binary
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(CLI_BINARY) cmd/cli/main.go

all: build-wails build-cli ## Build both Wails and CLI applications

# Testing and code quality
test: ## Run tests
	go test -v ./...

coverage: ## Generate test coverage report
	go test -coverprofile=$(COVERAGE_FILE) ./...
	go tool cover -html=$(COVERAGE_FILE)

lint: ## Run linters
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not installed. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; exit 1; }
	golangci-lint run

fmt: ## Format Go code
	gofmt -s -w $(GO_FILES)

# Cleanup
clean: ## Clean build artifacts
	go clean
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -f $(COVERAGE_FILE)

# Help
help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'