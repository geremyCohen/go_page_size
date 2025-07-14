import org.tensorflow.TensorFlow;

public class TensorFlowJNIHelloWorld {
    
    static {
        // Explicitly load the TensorFlow framework library first
        System.out.println("Loading TensorFlow framework library...");
        try {
            System.load("/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_framework.so");
            System.out.println("✅ Successfully loaded libtensorflow_framework.so");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("❌ Failed to load framework library: " + e.getMessage());
            System.exit(1);
        }
        
        // Then load the JNI library
        System.out.println("Loading TensorFlow JNI library...");
        try {
            System.load("/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_jni.so");
            System.out.println("✅ Successfully loaded libtensorflow_jni.so");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("❌ Failed to load JNI library: " + e.getMessage());
            System.exit(1);
        }
    }
    
    public static void main(String[] args) {
        System.out.println("=== TensorFlow JNI Hello World ===");
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println("OS: " + System.getProperty("os.name"));
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println();
        
        try {
            // Call TensorFlow.version() - a simple function that returns version string
            System.out.println("Calling TensorFlow.version() via JNI...");
            String version = TensorFlow.version();
            System.out.println("✅ TensorFlow Version: " + version);
            System.out.println();
            
            // Call TensorFlow.registeredOpList() - returns list of available operations
            System.out.println("Calling TensorFlow.registeredOpList() via JNI...");
            byte[] opList = TensorFlow.registeredOpList();
            System.out.println("✅ Registered Operations List Size: " + opList.length + " bytes");
            System.out.println("✅ First 100 bytes of op list: " + 
                new String(opList, 0, Math.min(100, opList.length)));
            System.out.println();
            
            // Test a simple tensor creation to verify full functionality
            System.out.println("Testing basic tensor operations...");
            try (org.tensorflow.Tensor<?> tensor = org.tensorflow.Tensor.create(42.0f)) {
                System.out.println("✅ Created tensor with value: " + tensor.floatValue());
                System.out.println("✅ Tensor data type: " + tensor.dataType());
                System.out.println("✅ Tensor shape: " + java.util.Arrays.toString(tensor.shape()));
            }
            
            System.out.println();
            System.out.println("🎉 SUCCESS: TensorFlow JNI library loaded and working correctly!");
            System.out.println("🎉 All native library calls completed successfully on ARM64!");
            
        } catch (Exception e) {
            System.err.println("❌ Error calling TensorFlow functions: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
