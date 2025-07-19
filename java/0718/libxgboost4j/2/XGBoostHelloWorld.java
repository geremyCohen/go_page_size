import ml.dmlc.xgboost4j.java.DMatrix;
import ml.dmlc.xgboost4j.java.XGBoostError;
import java.io.File;

/**
 * A simple Hello World application that demonstrates loading the XGBoost library via JNI
 * and creating a DMatrix to verify the JNI binding is working.
 */
public class XGBoostHelloWorld {
    
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libxgboost.so";
    
    public static void main(String[] args) {
        try {
            System.out.println("XGBoost Hello World - JNI Test");
            System.out.println("------------------------------");
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            File nativeLib = new File(NATIVE_LIB_PATH);
            if (!nativeLib.exists()) {
                throw new RuntimeException("Native library not found at: " + NATIVE_LIB_PATH);
            }
            System.load(nativeLib.getAbsolutePath());
            System.out.println("Native library loaded successfully!");
            
            // Create a simple DMatrix
            System.out.println("\nCreating a simple DMatrix...");
            float[] data = new float[] {
                1.0f, 2.0f, 3.0f,
                4.0f, 5.0f, 6.0f
            };
            float[] labels = new float[] {0.0f, 1.0f};
            
            DMatrix dmatrix = new DMatrix(data, 2, 3);
            dmatrix.setLabel(labels);
            
            System.out.println("DMatrix created successfully!");
            System.out.println("Number of rows: " + dmatrix.rowNum());
            
            // Clean up
            dmatrix.dispose();
            System.out.println("DMatrix disposed successfully!");
            
            System.out.println("\nJNI test completed successfully!");
            
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (XGBoostError e) {
            System.err.println("XGBoost error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during XGBoost JNI test: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
