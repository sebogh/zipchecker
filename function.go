package zipchecker

import (
	"fmt"
	"net/http"
)

func Query(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello World")
}
