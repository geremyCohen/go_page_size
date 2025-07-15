#!/bin/bash

# JDK17 Demo Runner Script
# Runs various JDK17 demonstration applications

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                JDK17 Demo Applications                       ║"
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

# Function to run a demo
run_demo() {
    local demo_name=$1
    local java_file=$2
    local class_name=$3
    local description=$4
    
    echo "=== $demo_name ==="
    echo "$description"
    echo
    
    # Compile if needed
    if [ ! -f "${class_name}.class" ] || [ "$java_file" -nt "${class_name}.class" ]; then
        echo "Compiling $java_file..."
        if [ -f "../libtensorflow.jar" ]; then
            $JAVAC_CMD -cp ../libtensorflow.jar "$java_file"
        else
            $JAVAC_CMD "$java_file"
        fi
        
        if [ $? -ne 0 ]; then
            echo "❌ Compilation failed for $java_file"
            return 1
        fi
    fi
    
    # Run the demo
    echo "Running $class_name..."
    echo "----------------------------------------"
    
    if [ -f "../libtensorflow.jar" ]; then
        $JAVA_CMD -cp .:../libtensorflow.jar "$class_name"
    else
        $JAVA_CMD "$class_name"
    fi
    
    local exit_code=$?
    echo "----------------------------------------"
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ $demo_name completed successfully!"
    else
        echo "⚠️  $demo_name completed with issues (exit code: $exit_code)"
    fi
    
    echo
    
    # Only wait for input if running interactively (stdin is a terminal)
    if [ -t 0 ]; then
        echo "Press Enter to continue to next demo..."
        read -r
        echo
    else
        echo "Continuing to next demo..."
        echo
    fi
}

# Menu function
show_menu() {
    echo "Available JDK17 Demos:"
    echo "1. Pure JDK17 Features Demo (Recommended)"
    echo "2. JDK17 with TensorFlow Integration Demo"
    echo "3. Basic JDK17 Environment Test"
    echo "4. Run All Demos"
    echo "5. Exit"
    echo
    echo -n "Select demo (1-5): "
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    echo
    
    case $choice in
        1)
            run_demo \
                "Pure JDK17 Features Demo" \
                "SimpleJNIHelloWorldJDK17Pure.java" \
                "SimpleJNIHelloWorldJDK17Pure" \
                "Demonstrates all JDK17 features without external dependencies"
            ;;
        2)
            run_demo \
                "JDK17 with TensorFlow Integration" \
                "SimpleJNIHelloWorldJDK17.java" \
                "SimpleJNIHelloWorldJDK17" \
                "Shows JDK17 features with TensorFlow JNI integration (may have limitations)"
            ;;
        3)
            run_demo \
                "Basic JDK17 Environment Test" \
                "TestTensorFlowJdk17.java" \
                "TestTensorFlowJdk17" \
                "Simple test to verify JDK17 environment"
            ;;
        4)
            echo "Running all demos..."
            echo
            
            run_demo \
                "Basic JDK17 Environment Test" \
                "TestTensorFlowJdk17.java" \
                "TestTensorFlowJdk17" \
                "Simple test to verify JDK17 environment"
            
            run_demo \
                "Pure JDK17 Features Demo" \
                "SimpleJNIHelloWorldJDK17Pure.java" \
                "SimpleJNIHelloWorldJDK17Pure" \
                "Demonstrates all JDK17 features without external dependencies"
            
            run_demo \
                "JDK17 with TensorFlow Integration" \
                "SimpleJNIHelloWorldJDK17.java" \
                "SimpleJNIHelloWorldJDK17" \
                "Shows JDK17 features with TensorFlow JNI integration (may have limitations)"
            
            echo "🎉 All demos completed!"
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1-5."
            echo
            ;;
    esac
done
