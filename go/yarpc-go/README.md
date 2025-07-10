# yarpc-go Example Applications
This folder contains YARPC example applications demonstrating usage over HTTP+JSON and TChannel transports.

## HTTP + JSON Example

1. In one terminal start the server:

    cd internal/examples/http/json/server
    go mod tidy
    go run main.go --inbound http

2. In another terminal start the client:

    cd internal/examples/http/json/client
    go mod tidy
    go run main.go --outbound http



3. Use the interactive prompt on the client (`>`):

    > set foo bar
    Set foo=bar
    > get foo
    Got foo=bar
    > del foo
    > exit

4. Compiling
go build -o server main.go 
go build -o client main.go
