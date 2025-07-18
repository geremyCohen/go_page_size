import org.apache.tomcat.jni.Library;

public class HelloWorldJNI {
    // Path to the native library
    private static final String NATIVE_LIB_PATH = "/home/ubuntu/go_page_size/java/0718/libtcnative/ai_build/install/lib/libtcnative-1.so";

    public static void main(String[] args) {
        try {
            System.out.println("Hello World JNI Application");
            System.out.println("---------------------------");
            
            // Explicitly load the native library
            System.out.println("Loading native library from: " + NATIVE_LIB_PATH);
            System.load(NATIVE_LIB_PATH);
            System.out.println("Native library loaded successfully!");
            
            // Call the getVersion method
            System.out.println("\nCalling Library.getVersion()...");
            String version = Library.getVersion();
            System.out.println("Library version: " + version);
            
            // Call the initialize method
            System.out.println("\nCalling Library.initialize()...");
            int result = Library.initialize();
            System.out.println("Library initialization result: " + result + " (0 means success)");
            
            System.out.println("\nJNI calls completed successfully!");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error during JNI operation: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
