#!/usr/bin/env bash
# Avoid network lookup failures for proxy.golang.org
export GOPROXY=direct
set -euo pipefail

# This script installs necessary tools, generates gRPC code, and runs the example.

function ensure_protoc() {
    if ! command -v protoc >/dev/null; then
        echo "protoc not found."
        if [[ "$(uname)" == "Darwin" ]]; then
            if command -v brew >/dev/null; then
                echo "Installing protoc with Homebrew..."
                brew install protobuf
            else
                echo "Homebrew not found. Please install protoc manually (e.g., brew install protobuf)."
                exit 1
            fi
        else
            echo "On Linux, install protoc with your package can manager, e.g.:"
            echo "  sudo apt-get update && sudo apt-get install -y protobuf-compiler"
            exit 1
        fi
    else
        echo "Found protoc: $(protoc --version)"
    fi
}

function ensure_go_plugins() {
    echo "==> Checking for Go protobuf plugins in PATH"
    if ! command -v protoc-gen-go >/dev/null; then
        echo "ERROR: protoc-gen-go not found."
        echo "Install it with:"
        echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1"
        exit 1
    fi
    if ! command -v protoc-gen-go-grpc >/dev/null; then
        echo "ERROR: protoc-gen-go-grpc not found."
        echo "Install it with:"
        echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
        exit 1
    fi
    export PATH="$(go env GOPATH)/bin:$PATH"
}

function generate_code() {
    echo "Generating Go code from proto definitions..."
    bash scripts/gen.sh
}

function build_and_run() {
    echo "Tidying Go modules (updating go.sum)..."
    go mod tidy
    echo "Building and running the gRPC example..."
    go run main.go
}

echo "==> Ensuring prerequisites..."
ensure_protoc
ensure_go_plugins
generate_code
build_and_run