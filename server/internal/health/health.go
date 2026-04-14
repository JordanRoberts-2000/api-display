package health

import (
	"encoding/json"
	"net/http"
	"time"
)

type Response struct {
	Status     string `json:"status"`
	DatabaseOK bool   `json:"databaseOk"`
	Timestamp  string `json:"timestamp"`
	Uptime     string `json:"uptime"`
}

func Handler(startTime time.Time) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		res := Response{
			Status:     "ok",
			DatabaseOK: false,
			Timestamp:  time.Now().UTC().Format(time.RFC3339),
			Uptime:     time.Since(startTime).String(),
		}

		if err := json.NewEncoder(w).Encode(res); err != nil {
			http.Error(w, "failed to encode response", http.StatusInternalServerError)
		}
	}
}
