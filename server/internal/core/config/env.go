package config

import (
	"fmt"
	"log/slog"
	"net/url"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type env struct {
	appEnv      AppEnv
	logLevel    slog.Level
	port        int
	databaseURL *url.URL
}

func loadEnv() (env, error) {
	_ = godotenv.Load()

	appEnv := AppEnv(optionalEnv("APP_ENV", string(EnvDevelopment)))

	logLevel, err := parseLogLevel(optionalEnv("LOG_LEVEL", "info"))
	if err != nil {
		return env{}, err
	}

	port, err := parsePort(optionalEnv("PORT", "8080"))
	if err != nil {
		return env{}, err
	}

	databaseURLString, err := requiredEnv("DATABASE_URL")
	if err != nil {
		return env{}, err
	}

	databaseURL, err := url.Parse(databaseURLString)
	if err != nil {
		return env{}, fmt.Errorf("invalid DATABASE_URL: %w", err)
	}

	return env{
		appEnv:      appEnv,
		logLevel:    logLevel,
		port:        port,
		databaseURL: databaseURL,
	}, nil
}

func optionalEnv(key, fallback string) string {
	v := os.Getenv(key)
	if v == "" {
		fmt.Println("env var not set, using default", "key", key, "default", fallback)
		return fallback
	}
	return v
}

func requiredEnv(key string) (string, error) {
	v := os.Getenv(key)
	if v == "" {
		return "", fmt.Errorf("required environment variable %q is not set", key)
	}
	return v, nil
}

func parsePort(raw string) (int, error) {
	port, err := strconv.Atoi(raw)
	if err != nil {
		return 0, fmt.Errorf("invalid PORT %q: must be an integer", raw)
	}
	if port < 1 || port > 65535 {
		return 0, fmt.Errorf("invalid PORT %d: must be between 1 and 65535", port)
	}
	return port, nil
}

func parseLogLevel(raw string) (slog.Level, error) {
	switch strings.ToLower(raw) {
	case "debug":
		return slog.LevelDebug, nil
	case "info":
		return slog.LevelInfo, nil
	case "warn", "warning":
		return slog.LevelWarn, nil
	case "error":
		return slog.LevelError, nil
	default:
		return 0, fmt.Errorf("invalid LOG_LEVEL %q: must be debug, info, warn, or error", raw)
	}
}
