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
	go build -o $@ $(MODULE)/cmd/server

# Run test server.
run_local: cmd/server/server
	$<

# Test against test server.
test_local:
	curl -X POST -s "http://localhost:8080" \
		-H "accept: application/json" -H "Content-Type: application/json" \
		-d '{"zipCode":"12205", "placeName":"Berlin"}' | jq
	curl -X POST -s "http://localhost:8080" \
		-H "accept: application/json" -H "Content-Type: application/json" \
        -d '{"zipCode":"72205", "placeName":"Barlin"}' | jq

# Remove object files (if any).
clean:
	rm -f *~
	rm -rf statics
	rm -f cmd/server/server
	rm -f coverage.out

# Remove all intermediate files.
tidy: clean
	rm -rf assets
	rm -f go.sum

.PHONY: clean tidy test test-coverage test_local run_local setup_gcloud deploy_gcloud test_gcloud vendor-sync
