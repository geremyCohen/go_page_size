import com.ucrypto.UCrypto;
import java.io.File;
import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;

public class HelloJNI {
    public static void main(String[] args) {
        try {
            System.out.println("Hello World JNI Application");
            System.out.println("---------------------------");
            
            // Get the absolute path to the native library
            String libPath = new File("../../ai_build/lib").getAbsolutePath();
            System.out.println("Setting java.library.path to: " + libPath);
            
            // Set the java.library.path property
            System.setProperty("java.library.path", libPath);
            
            // This is a hack to force the ClassLoader to reload the library paths
            try {
                Field fieldSysPath = ClassLoader.class.getDeclaredField("sys_paths");
                fieldSysPath.setAccessible(true);
                fieldSysPath.set(null, null);
            } catch (Exception e) {
                System.err.println("Warning: Could not reset java.library.path: " + e.getMessage());
            }
            
            // Create an instance of the UCrypto class
            // This will trigger the static initializer that loads the native library
            System.out.println("Creating UCrypto instance...");
            UCrypto crypto = new UCrypto();
            System.out.println("UCrypto instance created successfully!");
            
            // Call the generateKey method
            System.out.println("\nCalling generateKey(16)...");
            byte[] key = crypto.generateKey(16);
            System.out.println("Key generated: " + bytesToHex(key));
            
            // Call the encrypt method with a simple message
            String message = "Hello from JNI!";
            System.out.println("\nCalling encrypt() with message: " + message);
            byte[] data = message.getBytes(StandardCharsets.UTF_8);
            byte[] encrypted = crypto.encrypt(data, key);
            System.out.println("Encrypted: " + bytesToHex(encrypted));
            
            // Call the decrypt method
            System.out.println("\nCalling decrypt()...");
            byte[] decrypted = crypto.decrypt(encrypted, key);
            String decryptedMessage = new String(decrypted, StandardCharsets.UTF_8);
            System.out.println("Decrypted: " + decryptedMessage);
            
            // Verify
            System.out.println("\nVerifying results...");
            if (message.equals(decryptedMessage)) {
                System.out.println("SUCCESS: Original and decrypted messages match!");
            } else {
                System.out.println("FAILURE: Original and decrypted messages do not match!");
            }
            
            System.out.println("\nJNI Hello World completed successfully!");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // Helper method to convert byte array to hex string
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
