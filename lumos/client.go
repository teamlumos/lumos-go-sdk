package lumos

import (
	"fmt"
	"log"
	"net/http"
)

type CustomTransport struct {
	Transport http.RoundTripper
	Header    http.Header
}

func (c *CustomTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	for key, values := range c.Header {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}
	return c.Transport.RoundTrip(req)
}

func GetAuthenticatedClientWithResponses(baseUrl string, apiToken string) *ClientWithResponses {
	customTransport := &CustomTransport{
		Transport: http.DefaultTransport,
		Header:    make(http.Header),
	}
	customTransport.Header.Add("Authorization", fmt.Sprintf("Bearer %s", apiToken))

	hc := http.Client{Transport: customTransport}

	c, err := NewClientWithResponses(baseUrl, WithHTTPClient(&hc))
	if err != nil {
		log.Fatal(err)
	}
	return c
}
