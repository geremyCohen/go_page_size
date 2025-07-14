import javafx.scene.control.Label;
import javafx.scene.layout.VBox;

public class SimpleTest {
    public static void main(String[] args) {
        System.out.println("Testing basic JavaFX classes without Application...");
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java version: " + System.getProperty("java.version"));
        
        try {
            // Test basic JavaFX class instantiation
            Label label = new Label("Hello JavaFX!");
            System.out.println("✓ Label created successfully: " + label.getText());
            
            VBox vbox = new VBox();
            System.out.println("✓ VBox created successfully");
            
            vbox.getChildren().add(label);
            System.out.println("✓ Added label to VBox successfully");
            
            System.out.println("✓ Basic JavaFX classes are working!");
            System.out.println("The issue is likely with Application.launch() or the graphics system.");
            
        } catch (Exception e) {
            System.err.println("✗ Error with basic JavaFX classes: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
