package main

import (
	"embed"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
)

//go:embed all:dist
var staticFiles embed.FS

func staticFileServer() http.Handler {
	distFS, err := fs.Sub(staticFiles, "dist")
	if err != nil {
		slog.Error("Failed to create sub filesystem", "error", err)
		os.Exit(1)
	}
	return http.FileServer(http.FS(distFS))
}
