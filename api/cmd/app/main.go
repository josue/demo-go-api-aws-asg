package main

import (
	"log"
	"os"

	api "api/internal"
)

func main() {
	// configs
	serverPort := os.Getenv("PORT")

	err := api.NewServer(serverPort) // defaults to port 80
	if err != nil {
		log.Fatalf("Server Error: %v", err)
	}
}
