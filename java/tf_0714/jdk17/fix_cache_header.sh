#!/bin/bash

# Fix cache.h header properly
CACHE_FILE="tensorflow_jdk17_minimal/tensorflow/tsl/lib/io/cache.h"

echo "Fixing cache.h header..."

# Create the correct header section
cat > temp_header.txt << 'EOF'
#ifndef TENSORFLOW_TSL_LIB_IO_CACHE_H_
#define TENSORFLOW_TSL_LIB_IO_CACHE_H_

#include <cstdint>
#include <cstddef>
#include "tensorflow/tsl/platform/stringpiece.h"
EOF

# Get the rest of the file after the includes
tail -n +6 "$CACHE_FILE" > temp_body.txt

# Combine them
cat temp_header.txt temp_body.txt > "$CACHE_FILE"

# Clean up
rm temp_header.txt temp_body.txt

echo "cache.h fixed!"
