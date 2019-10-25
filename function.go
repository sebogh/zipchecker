package zipchecker

import (
	"encoding/json"
	"fmt"
	"git.thinkproject.com/zipchecker/internal"
	"log"
	"net/http"
	"os"
)

type QueryData struct {
	ZipCode   string `json:"zipCode"`
	PlaceName string `json:"placeName"`
}

var places *internal.Places

func Query(w http.ResponseWriter, r *http.Request) {

	switch r.Method {

	case "POST":

		// load known places, iff needed
		if places == nil {
			places = internal.NewPlaces()
			log.Printf("initialized list of %d places.", len(*places))
		}

		// pull query data from request
		var queryData QueryData
		if r.Body == nil {
			http.Error(w, "Please send a request body", 400)
			return
		}
		errDecode := json.NewDecoder(r.Body).Decode(&queryData)
		if errDecode != nil {
			http.Error(w, errDecode.Error(), 400)
			return
		}
		log.Printf("POST request, query for zip '%s' place '%s'", queryData.ZipCode, queryData.PlaceName)

		// compare query data with known places
		match := places.Check(queryData.ZipCode, queryData.PlaceName)

		js, errEncode := json.Marshal(match)
		if errEncode != nil {
			http.Error(w, errEncode.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.Write(js)

	default:

		log.Printf("%s request", r.Method)

		// return the git hash
		fmt.Fprint(w, os.Getenv("BUILD_GITHASH"))
	}

}
