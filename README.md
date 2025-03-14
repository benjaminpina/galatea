# README

## About

Galatea is a substrate management application with both CLI and GUI interfaces. It allows you to manage substrates and mixed substrates with specific validation rules.

## Development

### Prerequisites

- Go 1.19 or higher
- Wails (for GUI development)
- golangci-lint (for code linting)

### Using the Makefile

The project includes a Makefile that simplifies common development tasks. Here are the available commands:

#### Development

- `make run`: Run the GUI application in development mode with hot reload
- `make cli`: Run the CLI application directly without building

#### Building

- `make build-cli`: Build only the CLI binary
- `make build-gui`: Build only the GUI binary
- `make build-wails`: Build the Wails application
- `make all`: Build both CLI and GUI applications

#### Testing and Code Quality

- `make test`: Run all tests
- `make coverage`: Generate test coverage report and open it in a browser
- `make lint`: Run golangci-lint to check for code issues
- `make fmt`: Format Go code using gofmt

#### Cleanup

- `make clean`: Clean build artifacts, including binaries and coverage files

#### Help

- `make help`: Display help information about available commands

### Live Development (GUI)

To run the GUI in live development mode, run `make run` in the project directory. This will run a Vite development
server that will provide very fast hot reload of your frontend changes. If you want to develop in a browser
and have access to your Go methods, there is also a dev server that runs on http://localhost:34115. Connect
to this in your browser, and you can call your Go code from devtools.

## Building

To build a redistributable, production mode package:

1. For CLI only: `make build-cli`
2. For GUI only: `make build-gui`
3. For both: `make all`

The binaries will be placed in the `build/bin` directory.

## Project Structure

- `cmd/`: Application entry points
  - `cli/`: Command-line interface
  - `gui/`: Graphical user interface (Wails)
- `internal/`: Internal packages
  - `core/`: Core domain logic
    - `domain/`: Domain models and business logic
      - `substrate/`: Substrate-related models and logic

## Configuration

You can configure the GUI project by editing `cmd/gui/wails.json`. More information about the project settings can be found
here: https://wails.io/docs/reference/project-config
