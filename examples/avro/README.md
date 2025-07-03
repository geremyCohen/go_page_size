# Clone the goavro repository and navigate to example 165
git clone https://github.com/linkedin/goavro.git
cd goavro/examples/165

# Initialize Go module and download dependencies
go mod init example.com/goavro165
go mod tidy

# Run the example
go run main.go

# Check generated Avro file
ls event.avro