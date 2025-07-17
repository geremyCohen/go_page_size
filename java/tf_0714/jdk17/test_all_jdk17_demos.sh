#!/bin/bash

# Automated Test Script for All JDK17 Demo Options
# Tests each demo option individually to verify functionality

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Automated JDK17 Demo Testing                     ║"
echo "║              ARM64 Ubuntu 24.04 Edition                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

# Set JDK17 environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
JAVA_CMD="$JAVA_HOME/bin/java"
JAVAC_CMD="$JAVA_HOME/bin/javac"

echo "Using Java: $($JAVA_CMD -version 2>&1 | head -n1)"
echo "Java Home: $JAVA_HOME"
echo

# Test results tracking
declare -a test_results=()

# Function to test a demo
test_demo() {
    local test_name=$1
    local java_file=$2
    local class_name=$3
    local description=$4
    local use_tensorflow=$5
    
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ Testing: $test_name"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo "$description"
    echo
    
    # Check if Java file exists
    if [ ! -f "$java_file" ]; then
        echo "❌ FAILED: $java_file not found"
        test_results+=("❌ $test_name - File not found")
        return 1
    fi
    
    # Compile the demo
    echo "Compiling $java_file..."
    if [ "$use_tensorflow" = "true" ] && [ -f "../libtensorflow.jar" ]; then
        $JAVAC_CMD -cp ../libtensorflow.jar "$java_file"
    else
        $JAVAC_CMD "$java_file"
    fi
    
    if [ $? -ne 0 ]; then
        echo "❌ FAILED: Compilation failed for $java_file"
        test_results+=("❌ $test_name - Compilation failed")
        return 1
    fi
    
    echo "✅ Compilation successful"
    echo
    
    # Run the demo
    echo "Running $class_name..."
    echo "=========================================="
    
    local start_time=$(date +%s)
    
    if [ "$use_tensorflow" = "true" ] && [ -f "../libtensorflow.jar" ]; then
        timeout 30 $JAVA_CMD -cp .:../libtensorflow.jar "$class_name"
    else
        timeout 30 $JAVA_CMD "$class_name"
    fi
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "=========================================="
    echo "Execution time: ${duration}s"
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ SUCCESS: $test_name completed successfully!"
        test_results+=("✅ $test_name - Success (${duration}s)")
    elif [ $exit_code -eq 124 ]; then
        echo "⚠️  TIMEOUT: $test_name timed out after 30s"
        test_results+=("⚠️  $test_name - Timeout")
    else
        echo "⚠️  PARTIAL: $test_name completed with exit code $exit_code"
        test_results+=("⚠️  $test_name - Exit code $exit_code")
    fi
    
    echo
    echo "Press Enter to continue to next test..."
    echo "----------------------------------------"
    echo
}

# Test 1: Basic JDK17 Environment Test
test_demo \
    "Basic JDK17 Environment Test" \
    "TestTensorFlowJdk17.java" \
    "TestTensorFlowJdk17" \
    "Simple test to verify JDK17 environment" \
    false

# Test 2: Pure JDK17 Features Demo (Main demo)
test_demo \
    "Pure JDK17 Features Demo" \
    "SimpleJNIHelloWorldJDK17Pure.java" \
    "SimpleJNIHelloWorldJDK17Pure" \
    "Demonstrates all JDK17 features without external dependencies" \
    false

# Test 3: JDK17 with TensorFlow Integration
test_demo \
    "JDK17 with TensorFlow Integration" \
    "SimpleJNIHelloWorldJDK17.java" \
    "SimpleJNIHelloWorldJDK17" \
    "Shows JDK17 features with TensorFlow JNI integration" \
    true

# Display final results
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    TEST RESULTS SUMMARY                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo

for result in "${test_results[@]}"; do
    echo "$result"
done

echo
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    FEATURE VERIFICATION                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# Count results
success_count=$(printf '%s\n' "${test_results[@]}" | grep -c "✅")
total_count=${#test_results[@]}

echo "Tests completed: $total_count"
echo "Successful tests: $success_count"
echo "Success rate: $(( success_count * 100 / total_count ))%"

echo
if [ $success_count -eq $total_count ]; then
    echo "🎉 ALL TESTS PASSED! JDK17 demos are fully functional!"
elif [ $success_count -gt 0 ]; then
    echo "🎯 PARTIAL SUCCESS! Some demos working, others may need TensorFlow compilation."
else
    echo "❌ TESTS FAILED! Please check the issues above."
fi

echo
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    RECOMMENDATIONS                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo "✅ For pure JDK17 features: Use SimpleJNIHelloWorldJDK17Pure"
echo "⚠️  For TensorFlow integration: Complete JDK17 TensorFlow compilation first"
echo "🚀 Interactive testing: Use ./run_jdk17_demos.sh"

echo
echo "Testing completed at: $(date)"
