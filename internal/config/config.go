package config

import (
	"os"

	"github.com/joho/godotenv"
)

// Config holds all configuration for the application
type Config struct {
	DatabaseType string
	PostgresURL  string
	SQLiteFile   string
	ServerPort   string
}

// LoadConfig loads the configuration from environment variables
func LoadConfig() (*Config, error) {
	// Load .env file if it exists
	godotenv.Load()

	// Set default values
	config := &Config{
		DatabaseType: getEnv("DATABASE_TYPE", "sqlite"),
		PostgresURL:  getEnv("POSTGRES_URL", "postgres://postgres:postgres@localhost:5432/products?sslmode=disable"),
		SQLiteFile:   getEnv("SQLITE_FILE", "galatea.db"),
		ServerPort:   getEnv("SERVER_PORT", "8080"),
	}

	return config, nil
}

// Helper function to get environment variable with a default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
