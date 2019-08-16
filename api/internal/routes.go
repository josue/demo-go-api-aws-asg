package api

import (
	"encoding/json"
	"errors"
	"net/http"
	"os"
	"time"
)

// home with timestamp
func root(w http.ResponseWriter, r *http.Request) error {
	res := &response{
		Message:   "Automation for the People",
		Timestamp: time.Now().Unix(),
	}

	jsonString, err := json.Marshal(res)
	if err != nil {
		return errors.New("Unable to encode to JSON from root")
	}

	w.Write([]byte(jsonString))
	return nil
}

// health returns OK
func health(w http.ResponseWriter, r *http.Request) error {
	hostname, _ := os.Hostname()
	res := &response{
		Message:   "OK from " + hostname,
		Timestamp: time.Now().Unix(),
	}

	jsonString, err := json.Marshal(res)
	if err != nil {
		return errors.New("Unable to encode to JSON from health")
	}

	w.Write([]byte(jsonString))
	return nil
}
