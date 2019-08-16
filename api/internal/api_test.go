package api

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestMiddlewareStatusOK(t *testing.T) {
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

	t.Log(rr.Body.String())
}

func TestMiddlewareStatusInternalServerError(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	routeError := func(w http.ResponseWriter, r *http.Request) error {
		return errors.New("Unable to encode to JSON from root")
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(middleware(routeError))
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusInternalServerError {
		t.Errorf("root handler returned wrong status code: got %v want %v", status, http.StatusInternalServerError)
	}

	t.Log(rr.Body.String())
}

func TestCatchErrorEmpty(t *testing.T) {
	res := httptest.NewRecorder()
	jsonResponse := catchError(res, nil)

	if jsonResponse != "" {
		t.Errorf("catchError got '%v' but should be empty", jsonResponse)
	}
	t.Log(jsonResponse)
}

func TestCatchErrorWithError(t *testing.T) {
	res := httptest.NewRecorder()
	jsonResponse := catchError(res, errors.New("sorry"))

	jsonStruct := response{}
	json.Unmarshal([]byte(jsonResponse), &jsonStruct)

	shouldContain := "Internal Error"
	if !strings.Contains(jsonStruct.Error, shouldContain) {
		t.Errorf("catchError incorrect error, got '%v' but want exact string '%v'", jsonStruct.Error, shouldContain)
	}
	t.Log(jsonResponse)
}

func TestNewServer(t *testing.T) {
	var err error
	go func() {
		err = NewServer("")
	}()

	time.Sleep(time.Millisecond * 100)

	if err != nil {
		t.Errorf("NewServer should not have error: %v", err.Error())
	}
}
