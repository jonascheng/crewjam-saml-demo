// a golang web server to serve echo requests with multiple certificates
package main

import (
	"crypto/tls"
	"log"
	"net/http"
)

// define a call back function GetCertificate
// this function will be called by the server when a new connection is established
// the server will pass the client hello message to this function
// the function should return a certificate based on the client hello message
func GetCertificate(clientHello *tls.ClientHelloInfo) (*tls.Certificate, error) {
	// log the client hello message
	log.Printf("Client hello: %+v", clientHello)
	// load certificates from files
	certPair, _ := tls.LoadX509KeyPair("certs/cert.pem", "certs/key.pem")
	return &certPair, nil
}

func main() {
	// setup TLS configuration
	tlsConfig := &tls.Config{
		SessionTicketsDisabled:   true,
		PreferServerCipherSuites: true,
		// set minimum TLS version
		MinVersion: tls.VersionTLS12,
	}

	// set GetCertificate callback function
	tlsConfig.GetCertificate = GetCertificate

	// create a new http server
	server := &http.Server{
		Addr: "0.0.0.0:8443",
		// configure TLS
		TLSConfig: tlsConfig,
	}
	// register handler
	http.HandleFunc("/", handler)
	// start the server
	log.Fatal(server.ListenAndServeTLS("", ""))
}

// handler to serve echo requests
func handler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello World"))
}
