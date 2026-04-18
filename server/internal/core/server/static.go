package server

import (
	"embed"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
)

func staticFileServer(static embed.FS) http.Handler {
	distFS, err := fs.Sub(static, "dist")
	if err != nil {
		slog.Error("Failed to create sub filesystem", "error", err)
		os.Exit(1)
	}
	return http.FileServer(http.FS(distFS))
}
