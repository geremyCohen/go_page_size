#!/usr/bin/env bash
set -euo pipefail
# "clean" mode: remove generated stubs and go.sum so setup can start fresh
if [[ ${1-} == "clean" ]]; then
  echo "Cleaning generated stubs and go.sum..."
  rm -f proto/*.pb.go proto/*_grpc.pb.go
  rm -f go.sum
  exit 0
fi

# scripts/setup_and_run.sh
# Automatically installs Go protobuf plugins (if missing), regenerates stubs, and runs the example.

# Bypass Go module proxy to fetch plugins directly
export GOPROXY=direct
export PATH="$(go env GOPATH)/bin:$PATH"

# 1) Verify protoc (Protocol Buffer compiler) is installed
if ! command -v protoc >/dev/null; then
  echo "Error: protoc not found. Install via your package manager:"
  echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y protobuf-compiler"
  echo "  macOS: brew install protobuf"
  exit 1
fi

# 2) Always install protoc-gen-go plugin (v1.28.1)
echo "==> Installing protoc-gen-go@v1.28.1"
GOPROXY=direct go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1

# 3) Always install protoc-gen-go-grpc plugin (v1.3.0)
echo "==> Installing protoc-gen-go-grpc@v1.3.0"
GOPROXY=direct go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

echo "==> Generating Go code from .proto definitions"
bash scripts/gen.sh

echo "==> Tidying Go modules (updating go.sum)"
go mod tidy

echo "==> Downloading Go module dependencies"
go mod download

echo "==> Building and running the gRPC example"
go run main.go