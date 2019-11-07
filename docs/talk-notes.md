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
-   start Goland (V0) (no open files, make clean, enable go modules),
-   start Goland (V1) (no open files, make clean, enable go modules),
-   start Goland (V2) (no open files, make clean, enable go modules),
-   start [Google Cloud Platform] (no functions visible),
-   make sure slack commands and GCFs are removed as necessary

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
            -   `cmd/server/server`-target:
                -   build the project
            -   `run_local`-target:
                -   run our server locally
            -   `test-local`-target
            

4.  Browser: Slack API

    -   open [Slack API][Slack Apps]
    -   got to Slack-Commands
    -   create `hello`-command
    -   paste trigger URL

5.  Slack

    -   `/hello`


6.  Slides

    -   Wrapup
        -   FaaS
        -   setting up the GCF-SDK 
        -   implementation and deployment of a GCF 
        -   connecting GCF to slack
    
# V1

1.  Slides:

    -   v1

2.  GoLand:

    -   Implementierung:
        -   `function.go`:
            -   parse `application/x-www-form-urlencoded` data ([github.com/nlopes/slack])
                - show structure and shared secret
            -   validate [Verification tokens] a shared secret and (vs. [signing secrets])
            -   notify missing Slack Command argument
            -   logging
        -   `go.mod`:
            -   single dependency [github.com/nlopes/slack]
    -   Deployment:
        -   `Makefile`:
            -   `deploy`-target:
                -   deploy the function
                -   set environment variable `SLACK_VERIFICATION_TOKEN`
            -   `test-prod`-target
                -   show parameter in result
            
3.  Slides

    -   Wrapup
        -   very simple "REST"-App
# V2

1.  Slides:

    -   v2

2.  GoLand:

    -   Code Generation:
        -   `Makefile`:
            -   `statics/statik.go`-target:
                -   pull CSV data from repo 
                -   generate embedded statics
    -   Implementierung:
        -   `internal/places.go`:
            -   type `Place`
            -   
        -   `internal/employees.go`:
            -   nicer data structure 
        -   `function.go`:
            -   parse employee data (based on the above)
            -   caching employee data (later more)
            -   fuzzy search ([github.com/sahilm/fuzzy])
            -   formatting
            -   respond with matching names and phone numbers
        -   `/cmd/testwhoisgcf.go`
            -   a poor man’s emulator
            -   go best practice layout 
    -   Test:
        -   `test`-target
            - run tests on `internal`-package
        -   `cmd/testwhoisgcf/testwhoisgcf`-target
            - build simple server
        -   `run_local`-target
            - run simple server locally
        -   `test_local`-target
            - run test against local server
            - see output
            - see logs 
    -   Deployment:
        -   `.gcloudignore`:
            -   include statics although excluded by `.gitignore`
        -   `Makefile`:
            -   `deploy`-target:
                -   deploy the function
            -   `test-prod`-target
            

3.  Browser: Google Cloud Platform:

    -   open [Google Cloud Platform]
    -   switch to functions 
    -   show function source
    -   copy trigger URL

3.  Browser: Google Cloud Platform:

    -   open [Google Cloud Platform]
    -   switch to functions 
    -   show function source has been updated
    -   show caching effect in logs

4.  Browser: Slack API

    -   \[[Slack API][Slack Apps]\]
    -   \[zu den Slack-Commands gehen\]
    -   no need to change anything

5.  Slack

    -   `/hello foo`
        -   no result
    -   `/hello sebo`
        -   two results

6.  Slides

    -   Wrapup
        -   complete command


# GCF in Production

1. Slides

-   Scaling
-   Pricing
-   Price Example

# Wrapup

1. Slides

-   Things to do 
-   The next big thing?
-   Readings

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
