#!/bin/bash

# Master Demo Runner - Lists and runs all JavaFX ARM64 demos
# Choose which demo to run or run them all

set -e

echo "=== JavaFX ARM64 Demo Suite ==="
echo "Available demo applications with individual run scripts:"
echo

echo "1. FINALDEMO_RUN.sh"
echo "   - Comprehensive demo with display detection"
echo "   - Interactive UI with buttons and system info"
echo "   - Handles both headless and display modes"
echo

echo "2. MAIN_HELLOWORLD_RUN.sh"
echo "   - Your original requested structure"
echo "   - Main extends Application with HelloWorld scene"
echo "   - Interactive buttons, click counter, styled UI"
echo

echo "3. MINIMALTEST_RUN.sh"
echo "   - Simple JavaFX class instantiation test"
echo "   - Tests basic functionality without Application class"
echo "   - Good for debugging JavaFX setup"
echo

echo "4. WORKINGTEST_RUN.sh"
echo "   - Platform initialization test using JFXPanel"
echo "   - Proper JavaFX toolkit setup demonstration"
echo "   - Shows Scene creation and platform handling"
echo

echo "=== Usage Instructions ==="
echo "Run individual demos:"
echo "  ./FINALDEMO_RUN.sh"
echo "  ./MAIN_HELLOWORLD_RUN.sh"
echo "  ./MINIMALTEST_RUN.sh"
echo "  ./WORKINGTEST_RUN.sh"
echo

echo "For headless testing (no display required):"
echo "  xvfb-run -a ./FINALDEMO_RUN.sh"
echo "  xvfb-run -a ./MAIN_HELLOWORLD_RUN.sh"
echo

echo "For SSH with X11 forwarding:"
echo "  ssh -X user@host"
echo "  ./FINALDEMO_RUN.sh"
echo

echo "=== Quick Test ==="
read -p "Run FinalDemo now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running FinalDemo..."
    ./FINALDEMO_RUN.sh
else
    echo "Demo scripts are ready to use individually."
fi

echo
echo "=== All Demo Scripts Created Successfully ==="
