import org.tensorflow.TensorFlow;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

public class DetailedJNIDemo {
    
    private static final String FRAMEWORK_LIB = "/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_framework.so";
    private static final String JNI_LIB = "/home/ubuntu/go_page_size/java/tf_0714/libtensorflow_jni.so";
    
    static {
        System.out.println("=== Detailed JNI Library Loading Demo ===");
        loadLibraryWithDetails(FRAMEWORK_LIB, "TensorFlow Framework");
        loadLibraryWithDetails(JNI_LIB, "TensorFlow JNI");
        System.out.println("✅ All libraries loaded successfully!\n");
    }
    
    private static void loadLibraryWithDetails(String libPath, String libName) {
        System.out.println("--- " + libName + " Library ---");
        
        File libFile = new File(libPath);
        if (!libFile.exists()) {
            System.out.println("❌ Library file not found: " + libPath);
            System.exit(1);
        }
        
        System.out.println("Path: " + libPath);
        System.out.println("Size: " + String.format("%.1f MB", libFile.length() / 1024.0 / 1024.0));
        System.out.println("Readable: " + libFile.canRead());
        System.out.println("Executable: " + libFile.canExecute());
        
        try {
            // Get file type information using the 'file' command
            ProcessBuilder pb = new ProcessBuilder("file", libPath);
            Process process = pb.start();
            byte[] output = process.getInputStream().readAllBytes();
            String fileInfo = new String(output).trim();
            System.out.println("File Type: " + fileInfo.substring(fileInfo.indexOf(": ") + 2));
        } catch (Exception e) {
            System.out.println("File Type: Unable to determine");
        }
        
        System.out.print("Loading... ");
        try {
            System.load(libPath);
            System.out.println("✅ SUCCESS");
        } catch (UnsatisfiedLinkError e) {
            System.out.println("❌ FAILED: " + e.getMessage());
            System.exit(1);
        }
        System.out.println();
    }
    
    public static void main(String[] args) {
        System.out.println("=== System Information ===");
        System.out.println("OS Name: " + System.getProperty("os.name"));
        System.out.println("OS Version: " + System.getProperty("os.version"));
        System.out.println("OS Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("Java Vendor: " + System.getProperty("java.vendor"));
        System.out.println("Java Home: " + System.getProperty("java.home"));
        System.out.println();
        
        System.out.println("=== JNI Function Tests ===");
        
        try {
            // Test 1: Get TensorFlow version (simple string return)
            System.out.print("1. TensorFlow.version(): ");
            String version = TensorFlow.version();
            System.out.println("'" + version + "' ✅");
            
            // Test 2: Get registered operations (byte array return)
            System.out.print("2. TensorFlow.registeredOpList(): ");
            byte[] opList = TensorFlow.registeredOpList();
            System.out.println(opList.length + " bytes ✅");
            
            // Show first few operation names from the protobuf data
            String opListStr = new String(opList);
            System.out.println("   Sample operations found in list:");
            String[] lines = opListStr.split("\\n");
            int count = 0;
            for (String line : lines) {
                if (line.contains("Add") || line.contains("Mul") || line.contains("Sub") || line.contains("Div")) {
                    System.out.println("     - " + line.trim());
                    count++;
                    if (count >= 3) break;
                }
            }
            
            // Test 3: Create a simple tensor (object creation and method calls)
            System.out.print("3. Tensor creation and access: ");
            try (org.tensorflow.Tensor<?> tensor = org.tensorflow.Tensor.create(3.14159f)) {
                System.out.println("value=" + tensor.floatValue() + 
                                 ", type=" + tensor.dataType() + 
                                 ", shape=" + java.util.Arrays.toString(tensor.shape()) + " ✅");
            }
            
            System.out.println();
            System.out.println("🎉 SUCCESS: All JNI function calls completed!");
            System.out.println("🎉 TensorFlow native library is fully functional on ARM64!");
            
        } catch (Exception e) {
            System.err.println("❌ Error during JNI function testing:");
            e.printStackTrace();
        }
    }
}
