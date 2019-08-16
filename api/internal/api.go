package api

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type response struct {
	Message   string `json:"message,omitempty"`
	Timestamp int64  `json:"timestamp,omitempty"`
	Error     string `json:"error,omitempty"`
}

// http middleware
func middleware(h func(http.ResponseWriter, *http.Request) error) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		startTime := time.Now()
		defer log.Printf("[%s] Path: %s", time.Since(startTime), r.RequestURI)

		w.Header().Set("Content-Type", "application/json")

		err := h(w, r)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			catchError(w, err)
			return
		}
		
		w.WriteHeader(http.StatusOK)
	}
}

// catch error if not nil then log and respond with HTTP 500 + error message
func catchError(w http.ResponseWriter, err error) string {
	if err == nil {
		return ""
	}

	log.Printf("API Error: %v\n", err)

	res := &response{Error: "Internal Error"}
	jsonString, _ := json.Marshal(res)

	w.Write([]byte(jsonString))

	return string(jsonString)
}

// NewServer initializes http.ListenAndServe, and returns error if any
func NewServer(serverPort string) error {
	if serverPort == "" {
		serverPort = "80" // default
	}

	log.Println("Listening on port:" + serverPort)

	// http handlers
	http.HandleFunc("/", middleware(root))
	http.HandleFunc("/health", middleware(health))

	// init server
	return http.ListenAndServe(":"+serverPort, nil)
}
