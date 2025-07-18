import com.ucrypto.UCrypto;
import java.nio.charset.StandardCharsets;

public class UCryptoTest {
    public static void main(String[] args) {
        try {
            System.out.println("Testing UCrypto JNI library...");
            
            // Load the native library
            System.setProperty("java.library.path", "../ai_build/lib");
            
            UCrypto crypto = new UCrypto();
            
            // Test data
            String message = "Hello, JNI Crypto!";
            byte[] data = message.getBytes(StandardCharsets.UTF_8);
            
            // Generate a key
            System.out.println("Generating key...");
            byte[] key = crypto.generateKey(16);
            System.out.println("Key generated: " + bytesToHex(key));
            
            // Encrypt the data
            System.out.println("Encrypting: " + message);
            byte[] encrypted = crypto.encrypt(data, key);
            System.out.println("Encrypted: " + bytesToHex(encrypted));
            
            // Decrypt the data
            System.out.println("Decrypting...");
            byte[] decrypted = crypto.decrypt(encrypted, key);
            String decryptedMessage = new String(decrypted, StandardCharsets.UTF_8);
            System.out.println("Decrypted: " + decryptedMessage);
            
            // Verify
            if (message.equals(decryptedMessage)) {
                System.out.println("Test PASSED!");
            } else {
                System.out.println("Test FAILED!");
            }
            
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
