package app

import (
	"embed"
	"log/slog"
	"net/http"
	"server/internal/core"
	"server/internal/core/config"
	"server/internal/core/server"
	"time"
)

type App struct {
	Config config.Config
	Server *http.Server
}

func New(staticFiles embed.FS) (*App, error) {
	startTime := time.Now()

	cfg, err := config.Load()
	if err != nil {
		return nil, err
	}

	core.InitLogger(&cfg)

	router := server.NewRouter(staticFiles, startTime)
	server := server.New(cfg, router)

	return &App{
		Config: cfg,
		Server: server,
	}, nil
}

func (a *App) Run() error {
	slog.Info("server running",
		"port", a.Config.Port,
		"env", a.Config.AppEnv,
		"log_level", a.Config.LogLevel,
		"database_url", a.Config.DatabaseURL.Redacted(),
	)

	return a.Server.ListenAndServe()
}
