#!/bin/bash

# Simple test script to verify XGBoost JNI setup

set -e  # Exit on error

echo "Testing XGBoost JNI setup..."

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
cd $TEST_DIR

# Create a simple Java program that uses XGBoost
cat > SimpleXGBoostTest.java << 'EOF'
import ml.dmlc.xgboost4j.java.XGBoost;
import ml.dmlc.xgboost4j.java.XGBoostError;

public class SimpleXGBoostTest {
    public static void main(String[] args) {
        try {
            System.out.println("Testing XGBoost JNI...");
            
            // Get XGBoost version - this will verify JNI is working
            String version = XGBoost.getVersion();
            System.out.println("XGBoost version: " + version);
            
            System.out.println("XGBoost JNI test successful!");
            
        } catch (XGBoostError e) {
            System.err.println("Error testing XGBoost JNI: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
EOF

# Compile and run the test
echo "Compiling and running test..."
export CLASSPATH=$CLASSPATH:/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar
javac SimpleXGBoostTest.java
export LD_LIBRARY_PATH=/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build:$LD_LIBRARY_PATH
java SimpleXGBoostTest

# Clean up
cd -
rm -rf $TEST_DIR

echo "Test completed successfully!"
