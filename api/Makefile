.PHONY: all run build linux

run: test
	go run ./cmd/app/main.go

test:
	go test ./...

build: test
	mkdir -p bin
	go get -d -u ...
	go build -o ./bin/app ./cmd/app/main.go
	ls -ahl ./bin/app
	file ./bin/app

linux: test
	mkdir -p bin
	go get -d -u ...
	GOOS=linux go build -o ./bin/app ./cmd/app/main.go
	ls -ahl ./bin/app
	file ./bin/app