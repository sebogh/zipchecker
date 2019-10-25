package main

import (
	"log"
	"net/http"

	"git.thinkproject.com/zipchecker"
)

func main() {

	http.HandleFunc("/", zipchecker.Query)
	log.Fatal(http.ListenAndServe(":8080", nil))

}
