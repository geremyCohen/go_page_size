#!/usr/bin/env bash
set -euo pipefail

# scripts/setup_and_run.sh
# Automatically installs Go protobuf plugins (if missing), regenerates stubs, and runs the example.

# Bypass Go module proxy to fetch plugins directly
export GOPROXY=direct
export PATH="$(go env GOPATH)/bin:$PATH"

# 1) Verify protoc is installed
if ! command -v protoc >/dev/null; then
  echo "Error: protoc not found. Install via your package manager:"
  echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y protobuf-compiler"
  echo "  macOS: brew install protobuf"
  exit 1
fi

# 2) Install protoc-gen-go if missing
if ! command -v protoc-gen-go >/dev/null; then
  echo "==> Installing protoc-gen-go plugin..."
  go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
fi

# 3) Install protoc-gen-go-grpc if missing
if ! command -v protoc-gen-go-grpc >/dev/null; then
  echo "==> Installing protoc-gen-go-grpc plugin..."
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

echo "==> Generating Go code from .proto definitions"
bash scripts/gen.sh

echo "==> Tidying Go modules (updating go.sum)"
go mod tidy

echo "==> Downloading Go module dependencies"
go mod download

echo "==> Building and running the gRPC example"
go run main.go