# Zipchecker

A service to match and correct zipcodes and placenames. 

# Get Started Locally

clone repo, build and start a local server in one shell:

    cd /tmp
    git clone git@github.com:sebogh/zipchecker.git
    make -C /tmp/zipchecker run_local

and in a second shell query the server by running:

    make -C /tmp/zipchecker test_local

# Google Cloud Function

prepare (Google) Cloud SDK in a Docker container: 
    
    make -C /tmp/zipchecker setup_gcloud

deploy to Google Cloud: 

    make -C /tmp/zipchecker deploy_gcloud
    
test against Google Cloud:

    make -C /tmp/zipchecker test_gcloud


see: <https://console.cloud.google.com/functions/details/europe-west2/zipchecker?project=skilled-curve-238017>


# Data

The data set is retrieved from 
[github.com/zauberware/postal-codes-json-xml-csv](https://github.com/zauberware/postal-codes-json-xml-csv)


* Sebastian Bogan <sebastian.bogan@thinkproject.com>
