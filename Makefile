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
GO_FILES := $(wildcard function.go)

# The go module we dealing with
MODULE := git.thinkproject.com/zipchecker

all: cmd/server/server

# Build test server.
cmd/server/server: $(GO_FILES)
	go build -o $@ $(MODULE)/cmd/server

# Run test server.
run_local: cmd/server/server
	$<

# Test against test server.
test_local:
	curl -X GET -s "http://localhost:8080"

# Remove object files (if any).
clean:
	rm -f *~
	rm -f cmd/server/server

# Remove all intermediate files.
tidy: clean

.PHONY: clean tidy test_local run_local vendor-sync
