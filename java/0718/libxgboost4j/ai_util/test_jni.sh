#!/bin/bash

# Test script to verify XGBoost JNI setup

set -e  # Exit on error

echo "Testing XGBoost JNI setup..."

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
cd $TEST_DIR

# Create a simple Java program that uses XGBoost
cat > TestXGBoost.java << 'EOF'
import ml.dmlc.xgboost4j.java.XGBoost;
import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.Booster;
import java.util.HashMap;

public class TestXGBoost {
    public static void main(String[] args) {
        try {
            System.out.println("Testing XGBoost JNI...");
            
            // Create a simple dataset
            float[] data = new float[]{
                1.0f, 2.0f, 3.0f,
                4.0f, 5.0f, 6.0f,
                7.0f, 8.0f, 9.0f,
                2.0f, 3.0f, 4.0f,
                5.0f, 6.0f, 7.0f
            };
            
            float[] labels = new float[]{0.0f, 1.0f, 0.0f, 1.0f, 1.0f};
            
            DMatrix trainMat = new DMatrix(data, 5, 3);
            trainMat.setLabel(labels);
            
            // Set parameters
            HashMap<String, Object> params = new HashMap<String, Object>();
            params.put("eta", 0.1);
            params.put("max_depth", 3);
            params.put("objective", "binary:logistic");
            params.put("silent", 1);
            
            // Train a model
            HashMap<String, DMatrix> watches = new HashMap<String, DMatrix>();
            watches.put("train", trainMat);
            
            int nround = 5;
            Booster booster = XGBoost.train(trainMat, params, nround, watches, null, null);
            
            // Make a prediction
            float[] testData = new float[]{3.0f, 4.0f, 5.0f};
            DMatrix testMat = new DMatrix(testData, 1, 3);
            float[][] preds = booster.predict(testMat);
            
            System.out.println("Prediction: " + preds[0][0]);
            System.out.println("XGBoost JNI test successful!");
            
        } catch (Exception e) {
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
javac TestXGBoost.java
export LD_LIBRARY_PATH=/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build:$LD_LIBRARY_PATH
java TestXGBoost

# Clean up
cd -
rm -rf $TEST_DIR

echo "Test completed successfully!"
