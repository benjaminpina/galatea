# Galatea Makefile
# Variables for configuration
BINARY_NAME = galatea
CLI_BINARY = galateac
GUI_BINARY = galatea
API_BINARY = galatea-api
BUILD_DIR = build/bin
FRONTEND_DIR = cmd/gui/frontend
DIST_DIR = $(FRONTEND_DIR)/dist
WAILS_FLAGS = --tags webkit2_41
GO_FILES = $(shell find . -name "*.go" -type f -not -path "./vendor/*")
COVERAGE_FILE = coverage.out

.PHONY: run build-wails cli api build-cli build-gui build-api all test coverage clean lint fmt help

# Default target
.DEFAULT_GOAL := help

# Development
run: ## Run the application in development mode
	cd cmd/gui && wails dev $(WAILS_FLAGS)

# Build targets
build-wails: ## Build the Wails application
	cd cmd/gui && wails build $(WAILS_FLAGS)

cli: ## Run the CLI application
	go run cmd/cli/main.go

api: ## Run the API server
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(API_BINARY) cmd/api/main.go
	$(BUILD_DIR)/$(API_BINARY)

build-cli: ## Build the CLI binary
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(CLI_BINARY) cmd/cli/main.go

build-gui: ## Build the GUI binary
	@mkdir -p $(BUILD_DIR)
	cd cmd/gui && wails build $(WAILS_FLAGS) -o ../../$(BUILD_DIR)/$(GUI_BINARY)

build-api: ## Build the API binary
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(API_BINARY) cmd/api/main.go

all: build-cli build-gui build-api ## Build CLI, GUI, and API applications

# Testing and code quality
test: ## Run tests
	go test -v ./...

coverage: ## Generate test coverage report
	go test -coverprofile=$(COVERAGE_FILE) ./internal/... ./cmd/cli/... ./cmd/api/...
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