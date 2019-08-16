.PHONY: all go_run go_build_native go_build_linux infras_build_deploy infras_cleanup_all docker_build_deploy_all

export AWS_ACCESS_KEY_ID ?=
export AWS_SECRET_ACCESS_KEY ?=
export AWS_REGION ?= us-east-1

docker_build_deploy_all: prebuild_docker
	@docker run --rm --name api_build_deploy_workspace \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_DEFAULT_REGION=$(AWS_REGION) \
	-e AWS_REGION=$(AWS_REGION) \
	-v `pwd`:/workspace \
	-p 8080:80 \
	api_build_deploy bash -c 'make external_build_deploy_all'

docker_destroy_all: prebuild_docker
	@docker run --rm --name api_build_deploy_workspace \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_DEFAULT_REGION=$(AWS_REGION) \
	-e AWS_REGION=$(AWS_REGION) \
	-v `pwd`:/workspace \
	-p 8080:80 \
	api_build_deploy bash -c 'make external_destroy_all'

prebuild_docker:
	@docker build -t api_build_deploy .
	
external_build_deploy_all:
	@bash ./infras/scripts/build_deploy.sh

external_destroy_all:
	@bash ./infras/scripts/destroy_all.sh

go_run:
	@cd api; \
	go run ./cmd/app/main.go

go_build_native:
	@cd api; \
	mkdir -p bin; \
	go get -d -u ...; \
	go build -o ./bin/app ./cmd/app/main.go; \
	ls -ahl ./bin/app; \
	file ./bin/app

go_build_linux:
	@cd api; \
	mkdir -p bin; \
	go get -d -u ...; \
	GOOS=linux go build -o ./bin/app ./cmd/app/main.go; \
	ls -ahl ./bin/app; \
	file ./bin/app

run_load_test_api:
	@bash ./infras/scripts/load_test.sh

run_load_test_hard_stress_api:
	@bash ./infras/scripts/load_test.sh stress