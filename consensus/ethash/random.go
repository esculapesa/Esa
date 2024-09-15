package ethash

import (
    "encoding/json"
    "io/ioutil"
    "net/http"
)

type Pulse struct {
    OutputValue string `json:"outputValue"`
}

type BeaconResponse struct {
    Pulse Pulse `json:"pulse"`
}

func fetchRandomNumber() (string, error) {
    resp, err := http.Get("https://beacon.nist.gov/beacon/2.0/pulse/last")
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        return "", err
    }

    var beaconResponse BeaconResponse
    if err := json.Unmarshal(body, &beaconResponse); err != nil {
        return "", err
    }

    return beaconResponse.Pulse.OutputValue, nil
}
