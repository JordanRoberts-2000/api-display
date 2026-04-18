package main

import (
	"embed"
	"fmt"
	"net/http"
	"os"
	"server/internal/core/app"
)

//go:embed all:dist
var staticFiles embed.FS

func main() {
	application, err := app.New(staticFiles)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to initialize app: %v\n", err)
		os.Exit(1)
	}

	if err := application.Run(); err != nil && err != http.ErrServerClosed {
		fmt.Fprintf(os.Stderr, "server failed to run: %v\n", err)
		os.Exit(1)
	}
}
