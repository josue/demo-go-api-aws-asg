package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestRoot(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(middleware(root))
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("root handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	jsonStruct := response{}
	json.Unmarshal([]byte(rr.Body.String()), &jsonStruct)

	shouldContain := "Automation for the People"
	if !strings.Contains(jsonStruct.Message, shouldContain) {
		t.Errorf("root handler missing message, got '%v' but want exact string '%v'", jsonStruct.Message, shouldContain)
	}
	t.Log(rr.Body.String())

	if jsonStruct.Timestamp <= 0 {
		t.Errorf("root handler missing timestamp, got %v but should be greater than zero", jsonStruct.Timestamp)
	}

	now := time.Now()
	secondsAgo := 30
	secondsBefore := now.Add(time.Duration(secondsAgo) * time.Second)
	if jsonStruct.Timestamp > secondsBefore.Unix() {
		t.Errorf("root handler incorrect timestamp, got %v but should be greater than %v", jsonStruct.Timestamp, secondsBefore.Unix())
	}

	t.Log(rr.Body.String())
}

func TestHealth(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(middleware(health))
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("health handler returned wrong status code: got %v but should contain string %v", status, http.StatusOK)
	}

	jsonStruct := response{}
	json.Unmarshal([]byte(rr.Body.String()), &jsonStruct)

	shouldContain := "OK from"
	if !strings.Contains(jsonStruct.Message, shouldContain) {
		t.Errorf("health handler missing message, got '%v' but want '%v'", jsonStruct.Message, shouldContain)
	}
	t.Log(rr.Body.String())

	if jsonStruct.Timestamp <= 0 {
		t.Errorf("health handler missing timestamp, got %v but should be greater than zero", jsonStruct.Timestamp)
	}

	now := time.Now()
	secondsAgo := 30
	secondsBefore := now.Add(time.Duration(secondsAgo) * time.Second)
	if jsonStruct.Timestamp > secondsBefore.Unix() {
		t.Errorf("health handler incorrect timestamp, got %v but should be greater than %v", jsonStruct.Timestamp, secondsBefore.Unix())
	}

	t.Log(rr.Body.String())
}
