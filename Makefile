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
GO_FILES := $(wildcard cmd/zipchecker/*.go internal/*.go function.go)

# Google Cloud parameter.
GCF_PROJECT := skilled-curve-238017
GCF_REGION := europe-west2

all: cmd/testzipchecker/testzipchecker

vendor-sync:
	go mod vendor

assets/zipcodes.de.csv:
	mkdir -p assets
	wget -O $@ https://raw.githubusercontent.com/zauberware/postal-codes-json-xml-csv/master/data/DE/zipcodes.de.csv

# Convert the content of the assets folder to a go module providing a http.FileSystem.
statics/statik.go: assets/zipcodes.de.csv
	go get github.com/rakyll/statik
	statik -f -src assets -p statics

# Test internal package.
test: statics/statik.go
	go test -v git.thinkproject.com/zipchecker/internal -cover

test-coverage: statics/statik.go
	go test -coverprofile=coverage.out -v git.thinkproject.com/zipchecker/internal && go tool cover -func=coverage.out && go tool cover -html=coverage.out

# Build test server.
cmd/testzipchecker/testzipchecker: statics/statik.go $(GO_FILES) vendor-sync
	go build -mod vendor -o cmd/testzipchecker/testzipchecker git.thinkproject.com/zipchecker/cmd/testzipchecker

# Run test server.
run_local: cmd/testzipchecker/testzipchecker
	cmd/testzipchecker/testzipchecker

# Test against test server.
test_local:
	curl -X POST "http://localhost:8080" \
		-H "accept: application/json" -H "Content-Type: application/json" \
		-d '{"zipCode":"12205", "placeName":"Berlin"}' | jq

# Set up the Google Cloud SDK (in a docker container).
.cloud-sdk-setup:
	docker system prune
	docker pull "google/cloud-sdk:latest"
	docker run -ti --name gcloud-config --dns=8.8.8.8 --dns-search=. google/cloud-sdk gcloud auth login
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
		google/cloud-sdk gcloud config set project $(GCF_PROJECT)
	touch .cloud-sdk-setup


# Deploy Google Cloud Function.
deploy: .cloud-sdk-setup statics/statik.go $(GO_FILES)
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
		google/cloud-sdk gcloud functions deploy zipchecker --trigger-http --region=$(GCF_REGION) \
		--runtime go111 --entry-point Query --source="/code" --memory=128mb
	docker run --rm -ti --volumes-from gcloud-config --dns=8.8.8.8 --dns-search=. --volume=$(CWD):/code \
        google/cloud-sdk /bin/sh -c "cd /code && chown -Rc --reference=Makefile ."


# Test against Google Cloud Function.
test_prod:
	curl -X POST "https://$(GCF_REGION)-$(GCF_PROJECT).cloudfunctions.net/zipchecker" \
		-H "accept: application/json" -H "Content-Type: application/json" \
    	-d '{"zipCode":"12205", "placeName":"Berlin"}' | jq
	curl -X POST "https://$(GCF_REGION)-$(GCF_PROJECT).cloudfunctions.net/zipchecker" \
		-H "accept: application/json" -H "Content-Type: application/json" \
    	-d '{"zipCode":"12205", "placeName":"Barlin"}' | jq



# Remove object files (if any).
clean:
	rm -f [*~
	rm -rf statics
	rm -f cmd/testzipchecker/testzipchecker

# Remove all intermediate files.
tidy: clean
	rm -f .cloud-sdk-setup .gcloudignore
	rm -f go.sum

.PHONY: clean tidy test test-coverage test_local run_local deploy test_prod vendor-sync
