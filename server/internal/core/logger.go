package core

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"os"
	"server/internal/core/config"
	"strings"
)

func InitLogger(cfg *config.Config) {

	opts := &slog.HandlerOptions{
		Level: cfg.LogLevel,
	}

	var handler slog.Handler
	if cfg.IsDev() {
		handler = NewDevHandler(os.Stdout, cfg.LogLevel)
	} else {
		handler = slog.NewJSONHandler(os.Stdout, opts)
	}

	slog.SetDefault(slog.New(handler))
}

type DevHandler struct {
	out   io.Writer
	level slog.Level
}

func NewDevHandler(out io.Writer, level slog.Level) *DevHandler {
	return &DevHandler{
		out:   out,
		level: level,
	}
}

func (h *DevHandler) Enabled(_ context.Context, level slog.Level) bool {
	return level >= h.level
}

func (h *DevHandler) Handle(_ context.Context, r slog.Record) error {
	// Time: 20:35:12
	timestamp := r.Time.Format("15:04:05")

	// Level: INFO
	level := strings.ToUpper(r.Level.String())

	// Message
	msg := r.Message

	// Collect attributes
	var attrs []string
	r.Attrs(func(a slog.Attr) bool {
		attrs = append(attrs, fmt.Sprintf("%s=%v", a.Key, a.Value.Any()))
		return true
	})

	// Final line
	line := fmt.Sprintf(
		"%s %s  %s",
		timestamp,
		level,
		msg,
	)

	if len(attrs) > 0 {
		line += " " + strings.Join(attrs, " ")
	}

	line += "\n"

	_, err := h.out.Write([]byte(line))
	return err
}

func (h *DevHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return h
}

func (h *DevHandler) WithGroup(name string) slog.Handler {
	return h
}
