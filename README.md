# README

## About

Galatea is a substrate management application with CLI, GUI, and REST API interfaces. It allows you to manage substrates and mixed substrates with specific validation rules.

## Development

### Prerequisites

- Go 1.19 or higher
- Wails (for GUI development)
- golangci-lint (for code linting)
- Fiber (for REST API)

### Using the Makefile

The project includes a Makefile that simplifies common development tasks. Here are the available commands:

#### Development

- `make run`: Run the GUI application in development mode with hot reload
- `make cli`: Run the CLI application directly without building
- `make api`: Run the REST API server directly without building

#### Building

- `make build-cli`: Build only the CLI binary
- `make build-gui`: Build only the GUI binary
- `make build-api`: Build only the API binary
- `make build-wails`: Build the Wails application
- `make all`: Build CLI, GUI, and API applications

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

### REST API

The project includes a REST API built with Fiber that provides endpoints for managing substrates. To run the API server:

```bash
make api
```

The server will start on http://localhost:8080 with the following endpoints:

- `GET /api/v1/substrates` - List all substrates
- `GET /api/v1/substrates/:id` - Get a substrate by ID
- `POST /api/v1/substrates` - Create a new substrate
- `PUT /api/v1/substrates/:id` - Update a substrate
- `DELETE /api/v1/substrates/:id` - Delete a substrate

## Building

To build a redistributable, production mode package:

1. For CLI only: `make build-cli`
2. For GUI only: `make build-gui`
3. For API only: `make build-api`
4. For all components: `make all`

The binaries will be placed in the `build/bin` directory.

## Project Structure

- `cmd/`: Application entry points
  - `cli/`: Command-line interface
  - `gui/`: Graphical user interface (Wails)
  - `api/`: REST API server (Fiber)
- `internal/`: Internal packages
  - `adapters/`: Implementation of ports
    - `handlers/`: HTTP handlers
    - `repositories/`: Data storage implementations
  - `core/`: Core domain logic
    - `domain/`: Domain models and business logic
    - `ports/`: Interfaces defining the contracts
    - `services/`: Business logic implementations

## Configuration

You can configure the GUI project by editing `cmd/gui/wails.json`. More information about the project settings can be found
here: https://wails.io/docs/reference/project-config
