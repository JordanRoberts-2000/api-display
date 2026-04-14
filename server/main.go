package main

import (
	"log/slog"
	"net/http"
	"os"
	"server/internal/health"
	"server/internal/logger"
	"server/internal/middleware"
	"time"

	"github.com/joho/godotenv"
)

func main() {
	var startTime = time.Now()
	_ = godotenv.Load()
	logger.Init()
	router := http.NewServeMux()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		slog.Info("PORT not set, defaulting to " + port)
	}

	router.HandleFunc("GET /health", health.Handler(startTime))
	router.Handle("/", staticFileServer())

	server := http.Server{
		Addr:    ":" + port,
		Handler: middleware.RequestLogger(router),
	}

	slog.Info("Server running", "Port", port)
	err := server.ListenAndServe()
	if err != nil {
		slog.Error("Server failed to run", "Port", port, "error", err)
	}
}
