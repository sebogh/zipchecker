---
author: 'Dr. Sebastian Bogan'
keywords:
- architecture
styles:
  drafthtml: tphtmldrafen
  html: tphtmlen
  pdf: tppdfen
title: talk notes
version: '0.1'
---

# Prep


-   open Slides (individual slides)
-   open Notes (in Browser)
-   start Goland (V0) 
-   start Goland (V1) 
-   start Goland (V2) 
-   start [Google Cloud Platform] (no functions visible),


# V0

1.  Slides:

    -   v0

2.  GoLand:

    -   Implementierung:
        -   IDE von Jetbrains
        -   `function.go`:
            -   httpHandler `func(ResponseWriter, *Request)` from `net/http`
            -   responde "Hello World"
        -   `cmd/server/main.go`:
            -   Router
        -   `go.mod`:
            -   go modules (no vendoring, outside of `~/go/src`)
            -   empty
    -   Build / Run / Test:
        -   `Makefile`:
            -   `cmd/server/server`:
                -   build the project
            -   `run_local`:
                -   run our server 
            -   `test-local`
                -   test our server
3.  Slides

    -   Wrapup
        -   very simple "REST"-App

# V1

1.  Slides:

    -   v1

2.  GoLand:

    -   Code Generation:
        -   `Makefile`:
            -   `assets/zipcodes.de.csv`
                -   the data
    -   Implementierung:
        -   `internal/places.go`:
            -   type `Place`
            -   type `Places`
            -   constructor `NewPlaces()`
                -   opening file + `defer()` (like `finally` / `width`)
                -   error handling `err != nil`
            -   business logic `(places *Places) Check(...)`
                -   methods on types
                -   iterate over zip codes and compute the Levenshtein distance (first lowest)
        -   `internal/places_test.go`:
            -   similar to Python unit tests
            -   no asserts etc.
            -   not shown but nice table based testing
        -   `function.go`:
            -   global variable `places`
            -   pull query data from request 
            -   compare query data against zipcode data (employ the business logic)
            -   marshall the result (recycle the data structure previously used for parsing the CSV file)
            -   return the match
    -   Build / Run / Test:
        -   `Makefile`:
            -   `assets/zipcodes.de.csv`:
                -   pull CSV data from repo 
            -   `statics/statik.go`:
                -   wrap the CSV data into a go file
            -   `test`
                -   run the `_test`s in the `internal`-package
            -   `test-coverage`
                -   visualize show coverage
            -   `run_local`:
                -   run our server 
            -   `test-local`
                1.   all good (distance 0, match 100%)
                2.   4 errors (distance 4, match 55%) still the right match
3.  Slides

    -   Wrapup
        -   fully working

# V2

1.  Slides:

    -   v2

2.  GoLand:

    -   Deploy:
        -   `Makefile`:
            -   `.cloud-sdk-setup`:
                -   pull the GCP SDK as a docker image
                -   run it and store credentials and project settings in the named container
            -   `deploy_gcloud`:
                -   use ("recycle") the prepared container to deploy to GCP
            -   `test_gcloud`:
                -   run the previously seen tests against the FaaS
    -   GCP:
        -    open [GCP](https://console.cloud.google.com/functions/list?project=skilled-curve-238017&authuser=2&folder&hl=de&organizationId)
            -    open `zipchecker-demo`
                -    Allgemein:
                     -    RAM and Region
                -    Trigger:
                     -    URL
                -    Quelle:
                     -    known files
                -    "LOGS ansehen":
                     -    hot/cold start
                

3.  Slides

    -   Wrapup
        -   FaaS

<!--
# Local Variables:
# mode: markdown
# ispell-local-dictionary: "english"
# eval: (flyspell-mode 1)
# coding: utf-8
# End:
-->

  [Google Cloud Platform]: https://console.cloud.google.com/home/dashboard?project=skilled-curve-238017
  [Slack Apps]: https://api.slack.com/apps/AHYPGEEGY
