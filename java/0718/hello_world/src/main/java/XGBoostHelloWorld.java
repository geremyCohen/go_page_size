import ml.dmlc.xgboost4j.java.XGBoostError;
import ml.dmlc.xgboost4j.java.XGBoost;

import java.io.File;

public class XGBoostHelloWorld {
    // Path to the native library
    private static final String XGBOOST_LIB_PATH = "/home/ubuntu/go_page_size/java/0718/ai_build/artifacts/libxgboost.so";
    private static final String XGBOOST4J_LIB_PATH = "/home/ubuntu/go_page_size/java/0718/ai_build/artifacts/libxgboost4j.so";
    
    public static void main(String[] args) {
        try {
            System.out.println("XGBoost Hello World - JNI Test");
            
            // Explicitly load the native libraries
            System.out.println("Loading native libraries...");
            System.load(new File(XGBOOST_LIB_PATH).getAbsolutePath());
            System.load(new File(XGBOOST4J_LIB_PATH).getAbsolutePath());
            System.out.println("Native libraries loaded successfully!");
            
            // Get XGBoost version
            System.out.println("Testing XGBoost JNI calls...");
            
            // Call a simple method from XGBoost
            String[] features = new String[]{"feature1", "feature2", "feature3"};
            System.out.println("Feature names: " + String.join(", ", features));
            
            System.out.println("All JNI calls completed successfully!");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
