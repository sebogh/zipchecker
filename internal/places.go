package internal

import (
	"fmt"
	_ "git.thinkproject.com/zipchecker/statics"
	"github.com/agnivade/levenshtein"
	"github.com/gocarina/gocsv"
	"github.com/rakyll/statik/fs"
)

type Place struct {
	CountryCode   string `csv:"country_code" json:"countryCode"`
	ZipCode       string `csv:"zipcode" json:"zipCode"`
	Place         string `csv:"place" json:"place"`
	State         string `csv:"state" json:"state"`
	StateCode     string `csv:"state_code" json:"stateCode"`
	Province      string `csv:"province" json:"province"`
	ProvinceCode  string `csv:"province_code" json:"provinceCode"`
	Community     string `csv:"community" json:"community"`
	CommunityCode string `csv:"community_code" json:"communityCode"`
	Latitude      string `csv:"latitude" json:"latitude"`
	Longitude     string `csv:"longitude" json:"longitude"`
}

type Match struct {
	Distance   int    `json:"distance"`
	Percentage int    `json:"percentage"`
	Place      *Place `json:"place"`
}

type Places []*Place

func NewPlaces() *Places {

	// get the static FS
	staticsFS, err := fs.New()
	if err != nil {
		panic(err)
	}

	// open the csv file from the statics filesystem
	file, err := staticsFS.Open("/zipcodes.de.csv")
	if err != nil {
		panic(err)
	}
	defer func() {
		err := file.Close()
		if err != nil {
			panic(err)
		}
	}()

	// unmarshal
	places := Places{}
	if err := gocsv.Unmarshal(file, &places); err != nil {
		panic(err)
	}

	return &places
}

func (place Place) Format() string {
	return fmt.Sprintf("%v", place)
}

func (places *Places) Check(zipCode string, placeName string) *Match {
	var bestMatch *Match
	for _, p := range *places {
		distance := levenshtein.ComputeDistance(zipCode+","+placeName, p.ZipCode+","+p.Place)
		if distance == 0 {
			return &Match{0, 100, p}
		}
		if bestMatch == nil {
			bestMatch = &Match{distance, 0, p}
		} else {
			if distance < bestMatch.Distance {
				bestMatch.Distance = distance
				bestMatch.Place = p
			}
		}
	}

	// we should always have a match
	if bestMatch == nil {
		panic("no match at all")
	}

	// compute correctness in percent
	inputLength := len(zipCode) + len(placeName)
	correctness := inputLength - bestMatch.Distance
	if correctness < 0 {
		correctness = 0
	}
	bestMatch.Percentage = correctness * 100 / inputLength

	return bestMatch
}
