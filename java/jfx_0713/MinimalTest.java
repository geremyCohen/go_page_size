import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.stage.Stage;

public class MinimalTest extends Application {
    
    public static void main(String[] args) {
        System.out.println("Starting minimal JavaFX test...");
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java version: " + System.getProperty("java.version"));
        
        try {
            launch(args);
        } catch (Exception e) {
            System.err.println("Error launching JavaFX: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    public void start(Stage primaryStage) {
        System.out.println("JavaFX Application.start() called successfully!");
        
        Label label = new Label("Hello JavaFX on ARM64!");
        Scene scene = new Scene(label, 300, 200);
        
        primaryStage.setTitle("Minimal JavaFX Test");
        primaryStage.setScene(scene);
        primaryStage.show();
        
        System.out.println("JavaFX window should be visible now.");
    }
}
