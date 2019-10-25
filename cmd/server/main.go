package main

import (
	"log"
	"net/http"
	"os"

	"git.thinkproject.com/zipchecker"
)

var buildGithash = "to be set by linker"

func main() {

	os.Setenv("BUILD_GITHASH", buildGithash)
	http.HandleFunc("/", zipchecker.Query)
	log.Fatal(http.ListenAndServe(":8080", nil))

}
