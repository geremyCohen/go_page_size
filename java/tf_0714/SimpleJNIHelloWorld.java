import org.tensorflow.TensorFlow;

public class SimpleJNIHelloWorld {
    
    static {
        System.out.println("=== JNI Library Loading Demo ===");
        
        // Get absolute paths to our compiled libraries
        String frameworkPath = "/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_framework.so";
        String jniPath = "/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_jni.so";
        
        System.out.println("Framework Library: " + frameworkPath);
        System.out.println("JNI Library: " + jniPath);
        System.out.println();
        
        // Load framework library first (dependency)
        System.out.print("Loading framework library... ");
        try {
            System.load(frameworkPath);
            System.out.println("✅ SUCCESS");
        } catch (UnsatisfiedLinkError e) {
            System.out.println("❌ FAILED: " + e.getMessage());
            System.exit(1);
        }
        
        // Load JNI library
        System.out.print("Loading JNI library... ");
        try {
            System.load(jniPath);
            System.out.println("✅ SUCCESS");
        } catch (UnsatisfiedLinkError e) {
            System.out.println("❌ FAILED: " + e.getMessage());
            System.exit(1);
        }
        
        System.out.println("✅ All native libraries loaded successfully!");
        System.out.println();
    }
    
    public static void main(String[] args) {
        System.out.println("=== Hello World with TensorFlow JNI ===");
        System.out.println("System Information:");
        System.out.println("  OS: " + System.getProperty("os.name"));
        System.out.println("  Architecture: " + System.getProperty("os.arch"));
        System.out.println("  Java Version: " + System.getProperty("java.version"));
        System.out.println();
        
        // Call simple TensorFlow functions via JNI
        System.out.println("Testing JNI function calls:");
        
        try {
            // Simple version call - no arguments, returns string
            System.out.print("  TensorFlow.version(): ");
            String version = TensorFlow.version();
            System.out.println("'" + version + "' ✅");
            
            // Get operation list size - no arguments, returns byte array
            System.out.print("  TensorFlow.registeredOpList().length: ");
            byte[] opList = TensorFlow.registeredOpList();
            System.out.println(opList.length + " bytes ✅");
            
            System.out.println();
            System.out.println("🎉 Hello World JNI Demo Complete!");
            System.out.println("🎉 Successfully called TensorFlow native functions on ARM64!");
            
        } catch (Exception e) {
            System.err.println("❌ Error calling JNI functions: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
