package server

import (
	"embed"
	"net/http"
	"server/internal/health"
	"time"
)

func NewRouter(staticFiles embed.FS, startTime time.Time) http.Handler {
	router := http.NewServeMux()

	router.HandleFunc("GET /health", health.Handler(startTime))

	router.Handle("/", staticFileServer(staticFiles))

	return router
}
