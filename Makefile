SHELL = /bin/bash

# Just to be sure, add the path of the binary-based go installation.
PATH := /usr/local/go/bin:$(PATH)

# Using the (above extended) path, query the GOPATH (i.e. the user's go path).
GOPATH := $(shell env PATH=$(PATH) go env GOPATH)

# Add $GOPATH/bin to path.
PATH := $(GOPATH)/bin:$(PATH)

# We'll need the abs path.
CWD := $(shell pwd)

# Collect .go files.
GO_FILES := $(wildcard cmd/server/*.go internal/*.go function.go)

# The go module we dealing with
MODULE := git.thinkproject.com/zipchecker

# Google Cloud parameter.
GCF_PROJECT := skilled-curve-238017
GCF_REGION := europe-west2

# Git hash (to be included in the test server)
BUILD_GITHASH := $(shell git rev-parse HEAD)

all: cmd/server/server

assets/zipcodes.de.csv:
	mkdir -p assets
	wget -O $@ https://raw.githubusercontent.com/zauberware/postal-codes-json-xml-csv/master/data/DE/zipcodes.de.csv

# Convert the content of the assets folder to a go module providing a http.FileSystem.
statics/statik.go: assets/zipcodes.de.csv
	go get github.com/rakyll/statik
	statik -f -src assets -p statics

# Test internal package.
test: statics/statik.go
	go test -v $(MODULE)/internal -cover

test-coverage: statics/statik.go
	go test -coverprofile=coverage.out -v $(MODULE)/internal && \
	go tool cover -func=coverage.out && \
	go tool cover -html=coverage.out

# Build test server.
cmd/server/server: statics/statik.go $(GO_FILES)
	go build -o $@ -ldflags '-X main.buildGithash=$(BUILD_GITHASH)' $(MODULE)/cmd/server

# Compile the gRPC stubs.
proto/zipchecker.pb.go: proto/zipchecker.proto
	protoc --go_out=plugins=grpc:. --go_opt=paths=source_relative proto/zipchecker.proto

# Build gRPC client.
cmd/grpc-server/grpc-server: statics/statik.go proto/zipchecker.pb.go $(GO_FILES)
	go build -o $@ -ldflags '-X main.buildGithash=$(BUILD_GITHASH)' $(MODULE)/cmd/grpc-server

# Build gRPC client.
cmd/grpc-client/grpc-client: statics/statik.go proto/zipchecker.pb.go $(GO_FILES)
	go build -o $@ -ldflags '-X main.buildGithash=$(BUILD_GITHASH)' $(MODULE)/cmd/grpc-client


# Run test server.
run_local: cmd/server/server
	$<

# Test against test server.
test_local:
	echo -e "githash:" `curl -X GET -s "http://localhost:8080"` "\n"
	curl -X POST -s "http://localhost:8080" \
		-H "accept: application/json" -H "Content-Type: application/json" \
		-d '{"zipCode":"12205", "placeName":"Berlin"}' | jq
	curl -X POST -s "http://localhost:8080" \
	-H "accept: application/json" -H "Content-Type: application/json" \
        -d '{"zipCode":"72205", "placeName":"Barlin"}' | jq

# Set up the Google Cloud SDK (in a docker container).
setup_gcloud: .cloud-sdk-setup

.cloud-sdk-setup:
	docker system prune
	docker pull "google/cloud-sdk:latest"
	docker run -ti --name gcloud-config --dns=8.8.8.8 --dns-search=. google/cloud-sdk gcloud auth login
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
		google/cloud-sdk gcloud config set project $(GCF_PROJECT)
	touch .cloud-sdk-setup

# Deploy Google Cloud Function.
deploy_gcloud: .cloud-sdk-setup statics/statik.go $(GO_FILES)
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
		google/cloud-sdk gcloud functions deploy zipchecker --trigger-http --region=$(GCF_REGION) \
		--runtime go111 --entry-point Query --source="/code" --memory=128mb \
		--set-env-vars BUILD_GITHASH=$(BUILD_GITHASH)
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
        google/cloud-sdk /bin/sh -c "cd /code && chown -Rc --reference=Makefile ."

# Test against Google Cloud Function.
test_gcloud:
	echo -e "githash:" `curl -X GET -s "https://$(GCF_REGION)-$(GCF_PROJECT).cloudfunctions.net/zipchecker"` "\n"
	curl -X POST -s "https://$(GCF_REGION)-$(GCF_PROJECT).cloudfunctions.net/zipchecker" \
		-H "accept: application/json" -H "Content-Type: application/json" \
		-d '{"zipCode":"12205", "placeName":"Berlin"}' | jq
	curl -X POST -s "https://$(GCF_REGION)-$(GCF_PROJECT).cloudfunctions.net/zipchecker" \
		-H "accept: application/json" -H "Content-Type: application/json" \
		-d '{"zipCode":"72205", "placeName":"Barl"}' | jq

# Remove object files (if any).
clean:
	rm -f [*~
	rm -rf statics
	rm -f cmd/server/server
	rm -f coverage.out

# Remove all intermediate files.
tidy: clean
	rm -rf assets
	rm -f .cloud-sdk-setup
	rm -f go.sum
	rm -rf vendor

.PHONY: clean tidy test test-coverage test_local run_local setup_gcloud deploy_gcloud test_gcloud vendor-sync
