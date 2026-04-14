package logger

import (
	"log/slog"
	"os"
)

func Init() {
	env := os.Getenv("APP_ENV")
	isDev := env == "" || env == "development"

	level := slog.LevelInfo
	if isDev {
		level = slog.LevelDebug
	}

	opts := &slog.HandlerOptions{
		Level:     level,
		AddSource: isDev,
	}

	var handler slog.Handler
	if isDev {
		handler = slog.NewTextHandler(os.Stdout, opts)
	} else {
		handler = slog.NewJSONHandler(os.Stdout, opts)
	}

	slog.SetDefault(slog.New(handler))
}
