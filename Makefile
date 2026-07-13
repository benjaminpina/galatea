# ==============================================================================
# MASTER MAKEFILE - GALATEA SIMULATION SUITE
# ==============================================================================

# Directories
GO_DIR=engine_go
FLUTTER_DIR=editor_flutter

# Binary Naming
CLI_BIN=galateac
GUI_BIN=galatea

.PHONY: all cli gui editor clean help

# Default target
all: cli gui editor

# Build the CLI Simulation Engine
cli:
	@echo "Building Simulation CLI ($(CLI_BIN))..."
	mkdir -p $(GO_DIR)/bin
	cd $(GO_DIR) && go build -o bin/$(CLI_BIN) ./cmd/cli/main.go

# Build the GUI Visualizer
gui:
	@echo "Building Simulation GUI ($(GUI_BIN))..."
	mkdir -p $(GO_DIR)/bin
	cd $(GO_DIR) && go build -o bin/$(GUI_BIN) ./cmd/gui/main.go

# Build the Editor (Galatea Studio)
editor:
	@echo "Building Galatea Studio (Flutter)..."
	cd $(FLUTTER_DIR) && flutter build linux --release

# Clean all build artifacts
clean:
	@echo "Cleaning artifacts..."
	rm -rf $(GO_DIR)/bin/*
	cd $(FLUTTER_DIR) && flutter clean

# Help command
help:
	@echo "Usage:"
	@echo "  make cli    : Build the headless simulation engine ($(CLI_BIN))"
	@echo "  make gui    : Build the visual monitoring tool ($(GUI_BIN))"
	@echo "  make editor : Build the Flutter scenario editor (Galatea Studio)"
	@echo "  make all    : Build everything"
	@echo "  make clean  : Remove all build artifacts"