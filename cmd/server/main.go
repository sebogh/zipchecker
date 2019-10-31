package main

import (
	"git.thinkproject.com/zipchecker"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", zipchecker.Query)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
