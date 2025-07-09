package com.example;

import org.tensorflow.Tensor;
import org.tensorflow.TensorFlow;
import org.tensorflow.ndarray.Shape;
import org.tensorflow.types.TFloat32;

public class TensorFlowDemo {
    // Native method declaration
    public static native void printCustomMessage();
    
    static {
        // Load the custom compiled TensorFlow library from specific location
        System.load("/usr/local/lib/libtensorflow_jni.so");
    }

    public static void main(String[] args) {
        try {
            System.out.println("TensorFlow version: " + TensorFlow.version());
            
            // Call our custom method to print the message
            printCustomMessage();
            
            // Create a simple tensor
            System.out.println("Creating tensor...");
            try (Tensor<TFloat32> tensor = TFloat32.tensorOf(Shape.of(2, 2))) {
                tensor.data().setFloat(1.0f, 0, 0);
                tensor.data().setFloat(2.0f, 0, 1);
                tensor.data().setFloat(3.0f, 1, 0);
                tensor.data().setFloat(4.0f, 1, 1);
                
                System.out.println("Tensor created successfully!");
                System.out.println("Tensor shape: " + tensor.shape());
                System.out.println("Tensor value at [0,0]: " + tensor.data().getFloat(0, 0));
            }
            
            System.out.println("TensorFlow demo completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}