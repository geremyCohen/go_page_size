# go_page_size
This repository holds multiple Go applications, each in its own subdirectory.
Each app provides a `scripts/setup_and_run.sh` helper that:
  1. Installs necessary tools and codegen plugins.
  2. Regenerates any Protobuf/gRPC stubs.
  3. Updates `go.mod`/`go.sum`.
  4. Builds and runs the example.

## Available applications

- **grpc_and_proto/**  
  A Go gRPC ping–pong service and client example, driven by Protobuf.

## Usage

To run the `grpc_and_proto` example:

  cd grpc_and_proto

  # 1) Clean up old generated files and go.sum
  bash scripts/setup_and_run.sh clean

  # 2) Generate stubs, install plugins, update deps, and run
  bash scripts/setup_and_run.sh

You should see:

  > Response from server: PONG

Repeat these steps in any app subdirectory to get a fresh build from scratch.