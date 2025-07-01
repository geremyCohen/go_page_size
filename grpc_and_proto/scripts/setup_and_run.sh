#!/usr/bin/env bash
set -euo pipefail

# grpc_and_proto/scripts/setup_and_run.sh
# One-shot helper: install codegen plugins, regenerate stubs, update modules, and run the example.

# 1) Ensure protoc (Protocol Buffer compiler) is installed
if ! command -v protoc >/dev/null; then
  echo "Error: protoc not found. Install via your package manager:"
  echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y protobuf-compiler"
  echo "  macOS: brew install protobuf"
  exit 1
fi

# Ensure Go binaries (protoc-gen-*) in PATH
export PATH="$(go env GOPATH)/bin:$PATH"

# 2) Install protoc-gen-go plugin@v1.28.1
echo "==> Installing protoc-gen-go@v1.28.1"
GOPROXY=direct go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1

# 3) Install protoc-gen-go-grpc plugin@v1.3.0
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