# Zipchecker

An example go service to match and correct german zipcodes and placenames.

# Get Started

Make sure you got go version >= 1.11.

clone repo:

    git clone git@github.com:sebogh/zipchecker.git
    
build and start a local server in one shell:
    
    make run_local

and in a second shell query the server by running:

    make test_local

# Data

The data set is retrieved from 
[github.com/zauberware/postal-codes-json-xml-csv](https://github.com/zauberware/postal-codes-json-xml-csv)
