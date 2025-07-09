#!/usr/bin/env bash
set -euo pipefail

# Generate Go code from .proto definitions under grpc_and_proto
PROTO_DIR="proto"
OUT_DIR="${PROTO_DIR}"

# Clean up any old Go stubs in the proto directory
rm -f "${OUT_DIR}"/*.pb.go "${OUT_DIR}"/*_grpc.pb.go || true

protoc \
  --proto_path="${PROTO_DIR}" \
  --go_out="${OUT_DIR}" \
  --go_opt=paths=source_relative \
  --go-grpc_out="${OUT_DIR}" \
  --go-grpc_opt=paths=source_relative \
  "${PROTO_DIR}/helloworld.proto"