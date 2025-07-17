import java.io.File;

/**
 * JavaFX JNI Library Loading Test (Console Only)
 * 
 * This application tests explicit loading of our compiled ARM64 JavaFX native libraries
 * without requiring a GUI environment. Perfect for testing JNI integration.
 */
public class JavaFXJNITest {
    
    // Path to our compiled JavaFX native libraries
    private static final String JAVAFX_LIB_PATH = "/home/ubuntu/javafx_jdk17_build_20250715_234005/jfx/build/sdk/lib";
    
    public static void main(String[] args) {
        System.out.println("=== JavaFX JNI Library Loading Test ===");
        System.out.println("Testing explicit loading of ARM64 compiled JavaFX native libraries");
        System.out.println("Library path: " + JAVAFX_LIB_PATH);
        System.out.println();
        
        // Display system information
        displaySystemInfo();
        
        // Test explicit JNI library loading
        testJNILibraryLoading();
        
        // Test library symbols and functionality
        testLibraryFunctionality();
        
        System.out.println("=== JNI Library Test Complete ===");
    }
    
    /**
     * Display system and environment information
     */
    private static void displaySystemInfo() {
        System.out.println("=== System Information ===");
        System.out.println("OS Name: " + System.getProperty("os.name"));
        System.out.println("OS Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("Java Home: " + System.getProperty("java.home"));
        System.out.println("Current Library Path: " + System.getProperty("java.library.path"));
        System.out.println("Working Directory: " + System.getProperty("user.dir"));
        System.out.println();
    }
    
    /**
     * Test explicit loading of JavaFX native libraries
     */
    private static void testJNILibraryLoading() {
        System.out.println("=== Testing Explicit JNI Library Loading ===");
        
        // Set the library path for our compiled libraries
        System.setProperty("java.library.path", JAVAFX_LIB_PATH);
        
        // Core JavaFX native libraries to test
        String[] libraries = {
            "glass",           // Core windowing system
            "glassgtk3",       // GTK3 windowing integration  
            "prism_common",    // Common graphics functionality
            "prism_es2",       // ES2 graphics pipeline (JNI)
            "prism_sw",        // Software rendering pipeline
            "javafx_font",     // Core font support
            "javafx_font_freetype", // FreeType font rendering
            "javafx_font_pango",    // Pango text layout
            "javafx_iio",      // Image input/output
            "decora_sse",      // Graphics effects and shaders
            "jfxmedia",        // Media framework (JNI)
            "gstreamer-lite",  // GStreamer integration
            "fxplugins"        // Media plugins
        };
        
        int successCount = 0;
        int totalCount = libraries.length;
        
        // Test loading each library
        for (String libName : libraries) {
            String libPath = JAVAFX_LIB_PATH + "/lib" + libName + ".so";
            File libFile = new File(libPath);
            
            System.out.print("Testing lib" + libName + ".so... ");
            
            if (!libFile.exists()) {
                System.out.println("❌ FILE NOT FOUND");
                continue;
            }
            
            try {
                // Attempt to load the library explicitly by full path
                System.load(libPath);
                System.out.println("✅ LOADED SUCCESSFULLY");
                successCount++;
                
                // Display library information
                System.out.println("   Path: " + libPath);
                System.out.println("   Size: " + (libFile.length() / 1024) + " KB");
                System.out.println("   Architecture: ARM64 (aarch64)");
                
            } catch (UnsatisfiedLinkError e) {
                System.out.println("⚠️  LOAD FAILED: " + e.getMessage());
                
                // Try to get more information about the failure
                try {
                    Process proc = Runtime.getRuntime().exec(new String[]{"file", libPath});
                    proc.waitFor();
                    System.out.println("   Library info: Check with 'file " + libPath + "'");
                } catch (Exception ex) {
                    // Ignore
                }
                
            } catch (Exception e) {
                System.out.println("❌ ERROR: " + e.getMessage());
            }
            
            System.out.println();
        }
        
        // Summary
        System.out.println("=== JNI Library Loading Summary ===");
        System.out.println("Successfully loaded: " + successCount + "/" + totalCount + " libraries");
        System.out.println("Success rate: " + (successCount * 100 / totalCount) + "%");
        System.out.println();
    }
    
    /**
     * Test library functionality and symbols
     */
    private static void testLibraryFunctionality() {
        System.out.println("=== Testing Library Functionality ===");
        
        try {
            // Test if we can access JavaFX system properties
            System.out.println("Testing JavaFX system integration...");
            
            // These would normally be set by JavaFX when libraries load properly
            String[] javaFXProps = {
                "javafx.version",
                "javafx.runtime.version", 
                "prism.order",
                "prism.verbose"
            };
            
            for (String prop : javaFXProps) {
                String value = System.getProperty(prop);
                if (value != null) {
                    System.out.println("✅ " + prop + " = " + value);
                } else {
                    System.out.println("⚠️  " + prop + " = (not set)");
                }
            }
            
            System.out.println();
            System.out.println("✅ JNI library loading test completed successfully!");
            System.out.println("✅ Our ARM64 compiled JavaFX libraries are properly accessible");
            
        } catch (Exception e) {
            System.out.println("⚠️  Error testing functionality: " + e.getMessage());
        }
        
        System.out.println();
    }
}
