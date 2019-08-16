package main

import (
	"log"
	"os"
	"testing"
)

func TestMain(m *testing.M) {
	code := m.Run()
	if code > 0 {
		log.Fatalf("code = %v \n", code)
	}
	os.Exit(code)
}
