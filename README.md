# Zipchecker

A service to match and correct zipcodes and placenames. 

# Get Started Locally

clone repo:

    git clone git@github.com:sebogh/zipchecker.git
    
build and start a local server in one shell:
    
    make run_local

and in a second shell query the server by running:

    make test_local

# Google Cloud Function

prepare (Google) Cloud SDK in a Docker container: 
    
    make setup_gcloud

deploy to Google Cloud: 

    make deploy_gcloud
    
test against Google Cloud:

    make test_gcloud


see: <https://console.cloud.google.com/functions/details/europe-west2/zipchecker?project=skilled-curve-238017>


# Data

The data set is retrieved from 
[github.com/zauberware/postal-codes-json-xml-csv](https://github.com/zauberware/postal-codes-json-xml-csv)


* Sebastian Bogan <sebastian.bogan@thinkproject.com>
