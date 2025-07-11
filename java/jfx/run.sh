#!/usr/bin/env bash

# Run the JFX Demo without reinstall
# Set JavaFX module path (installed via openjfx)
FX_LIB_PATH="/usr/share/openjfx/lib"
echo "Running JFX Demo with custom library and JavaFX modules from: $FX_LIB_PATH"
java --module-path "$FX_LIB_PATH" --add-modules javafx.graphics \
     -cp target/classes com.example.JfxDemo