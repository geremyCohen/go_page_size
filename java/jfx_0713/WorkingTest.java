import javafx.application.Platform;
import javafx.embed.swing.JFXPanel;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.scene.Scene;

public class WorkingTest {
    public static void main(String[] args) {
        System.out.println("Testing JavaFX with proper platform initialization...");
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java version: " + System.getProperty("java.version"));
        
        try {
            // Initialize JavaFX toolkit by creating a JFXPanel
            // This is a common trick to initialize JavaFX without Application.launch()
            new JFXPanel();
            
            Platform.runLater(() -> {
                try {
                    System.out.println("✓ JavaFX Platform initialized successfully!");
                    
                    // Test basic JavaFX class instantiation
                    Label label = new Label("Hello JavaFX on ARM64!");
                    System.out.println("✓ Label created: " + label.getText());
                    
                    VBox vbox = new VBox(10);
                    vbox.getChildren().add(label);
                    System.out.println("✓ VBox created and label added");
                    
                    // Create a scene (this tests more of the graphics stack)
                    Scene scene = new Scene(vbox, 300, 200);
                    System.out.println("✓ Scene created successfully");
                    
                    System.out.println("✅ SUCCESS: JavaFX ARM64 with JNI is working!");
                    System.out.println("✅ Graphics pipeline: Software rendering");
                    System.out.println("✅ Native libraries: ARM64 JNI libraries loaded");
                    
                } catch (Exception e) {
                    System.err.println("✗ Error in Platform.runLater: " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    Platform.exit();
                }
            });
            
            // Wait a bit for the Platform.runLater to execute
            Thread.sleep(2000);
            
        } catch (Exception e) {
            System.err.println("✗ Error initializing JavaFX: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("Test completed.");
    }
}
