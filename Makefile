.DEFAULT_GOAL := help

COMMIT_SHA?=$(shell git rev-parse --short HEAD)
DOCKER?=docker
REGISTRY?=jonascheng
# is Windows_NT on XP, 2000, 7, Vista, 10...
ifeq ($(OS),Windows_NT)
GOOS?=windows
RACE=""
else
GOOS?=$(shell uname -s | awk '{print tolower($0)}')
GORACE="-race"
endif

.PHONY: setup
setup:	## setup go modules
	go mod tidy

.PHONY: clean
clean:	## cleans the binary
	go clean
	rm -rf ./bin

.PHONY: run
run: setup key ## runs server
	go run ${GORACE} cmd/main.go

.PHONY: key
key:	## setup server key
	mkdir -p certs
	## -newkey param      Generate a new key using given parameters
	## -nodes 						Do not encrypt output private key
	if [ ! -f certs/key.pem ]; then openssl req -x509 -newkey rsa:4096 -keyout certs/key.pem -out certs/cert.pem -nodes -days 365 -subj "/C=TW/ST=Taipei/L=Test/O=Test/OU=Test/CN=Test Server/emailAddress=Test@email"; fi;

.PHONY: help
help: ## prints this help message
	@echo "Usage: \n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
