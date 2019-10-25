package internal

import (
	"os"
	"reflect"
	"testing"
)

var places *Places
var defaultPlace *Place

// run once for all tests (i.e. setup)
func TestMain(m *testing.M) {
	places = NewPlaces()
	defaultPlace = &Place{
		CountryCode:   "DE",
		ZipCode:       "01945",
		Place:         "Grünewald",
		State:         "Brandenburg",
		StateCode:     "BB",
		Province:      "",
		ProvinceCode:  "00",
		Community:     "Landkreis Oberspreewald-Lausitz",
		CommunityCode: "12066",
		Latitude:      "51.4",
		Longitude:     "14",
	}
	os.Exit(m.Run())
}

func TestPlaceFormat(t *testing.T) {
	expected := "{DE 01945 Grünewald Brandenburg BB  00 Landkreis Oberspreewald-Lausitz 12066 51.4 14}"
	received := defaultPlace.Format()
	if received != expected {
		t.Errorf("Unexpected formatting, got: %s, want: %s.", received, expected)
	}
}

func TestPlacesLoaded(t *testing.T) {
	count := len(*places)
	expected := 16481
	if count != expected {
		t.Errorf("Unexpected number of places, got: %d, want: %d.", count, expected)
	}
}

func TestHappyPath(t *testing.T) {
	match := places.Check("01945", "Grünewald")
	if match == nil {
		t.Error("no result")
	}
	receivedPlace := match.Place
	receivedDistance := match.Distance
	receivedPercentage := match.Percentage
	expectedPlace := defaultPlace
	expectedDistance := 0
	expectedPercentage := 100
	if receivedDistance != expectedDistance {
		t.Errorf("invalid distance, got: %+v, want: %+v", receivedDistance, expectedDistance)
	}
	if receivedPercentage != expectedPercentage {
		t.Errorf("invalid percentage, got: %+v, want: %+v", receivedPercentage, expectedPercentage)
	}
	if !reflect.DeepEqual(receivedPlace, expectedPlace) {
		t.Errorf("invalid place, got: %+v, want: %+v", receivedPlace, expectedPlace)
	}
}

func TestDistance2(t *testing.T) {
	match := places.Check("01945", "Gruenewald")
	receivedPlace := match.Place
	receivedDistance := match.Distance
	receivedPercentage := match.Percentage
	expectedPlace := defaultPlace
	expectedDistance := 2
	expectedPercentage := 86
	if receivedDistance != expectedDistance {
		t.Errorf("invalid receivedDistance, got: %+v, want: %+v", nil, expectedDistance)
	}
	if receivedPercentage != expectedPercentage {
		t.Errorf("invalid percentage, got: %+v, want: %+v", receivedPercentage, expectedPercentage)
	}
	if !reflect.DeepEqual(receivedPlace, expectedPlace) {
		t.Errorf("invalid receivedPlace, got: %+v, want: %+v", receivedPlace, expectedPlace)
	}
}

func TestMissingZip(t *testing.T) {
	match := places.Check("", "Gruenewald")
	receivedPlace := match.Place
	receivedDistance := match.Distance
	expectedPlaceName := "Grunewald"
	expectedZipCode := "17268"
	expectedDistance := 6
	if receivedDistance != expectedDistance {
		t.Errorf("invalid distance, got: %+v, want: %+v", nil, 6)
	}
	if receivedPlace.Place != expectedPlaceName {
		t.Errorf("invalid place name, got: %+v, want: %+v", receivedPlace.Place, expectedPlaceName)
	}
	if receivedPlace.ZipCode != expectedZipCode {
		t.Errorf("invalid place zipcode, got: %+v, want: %+v", receivedPlace.ZipCode, expectedZipCode)
	}
}
