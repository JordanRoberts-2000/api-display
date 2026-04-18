package config

import (
	"log/slog"
	"net/url"
	"time"
)

type AppEnv string

const (
	EnvDevelopment AppEnv = "development"
	EnvProduction  AppEnv = "production"
)

type Config struct {
	AppEnv            AppEnv
	Port              int
	LogLevel          slog.Level
	DatabaseURL       *url.URL
	ReadHeaderTimeout time.Duration
	ReadTimeout       time.Duration
	WriteTimeout      time.Duration
	IdleTimeout       time.Duration
	MaxHeaderBytes    int
}

func Load() (Config, error) {
	env, err := loadEnv()
	if err != nil {
		return Config{}, err
	}

	return Config{
		AppEnv:            env.appEnv,
		Port:              env.port,
		LogLevel:          env.logLevel,
		DatabaseURL:       env.databaseURL,
		ReadHeaderTimeout: 2 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
		MaxHeaderBytes:    256 * 1024,
	}, nil
}

func (c Config) IsDev() bool {
	return c.AppEnv == EnvDevelopment
}
