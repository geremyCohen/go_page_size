import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;

public class HelloWorld {
    private Scene scene;
    private Label messageLabel;
    private int clickCount = 0;
    
    public HelloWorld() {
        createScene();
    }
    
    private void createScene() {
        // Create main container
        VBox root = new VBox(20);
        root.setAlignment(Pos.CENTER);
        root.setPadding(new Insets(30));
        root.setStyle("-fx-background-color: linear-gradient(to bottom, #e3f2fd, #bbdefb);");
        
        // Title label
        Label titleLabel = new Label("JavaFX ARM64 Demo");
        titleLabel.setFont(Font.font("Arial", FontWeight.BOLD, 24));
        titleLabel.setTextFill(Color.DARKBLUE);
        
        // Message label
        messageLabel = new Label("Hello World from JavaFX on ARM64!");
        messageLabel.setFont(Font.font("Arial", FontWeight.NORMAL, 16));
        messageLabel.setTextFill(Color.DARKGREEN);
        
        // Click counter label
        Label counterLabel = new Label("Click count: 0");
        counterLabel.setFont(Font.font("Arial", FontWeight.NORMAL, 14));
        counterLabel.setTextFill(Color.DARKRED);
        
        // Buttons container
        HBox buttonBox = new HBox(15);
        buttonBox.setAlignment(Pos.CENTER);
        
        // Hello button
        Button helloButton = new Button("Say Hello!");
        helloButton.setStyle("-fx-background-color: #4CAF50; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px 20px;");
        helloButton.setOnAction(e -> {
            clickCount++;
            messageLabel.setText("Hello from JavaFX ARM64! (Click #" + clickCount + ")");
            counterLabel.setText("Click count: " + clickCount);
        });
        
        // Reset button
        Button resetButton = new Button("Reset");
        resetButton.setStyle("-fx-background-color: #f44336; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px 20px;");
        resetButton.setOnAction(e -> {
            clickCount = 0;
            messageLabel.setText("Hello World from JavaFX on ARM64!");
            counterLabel.setText("Click count: 0");
        });
        
        // Info button
        Button infoButton = new Button("System Info");
        infoButton.setStyle("-fx-background-color: #2196F3; -fx-text-fill: white; -fx-font-size: 14px; -fx-padding: 10px 20px;");
        infoButton.setOnAction(e -> {
            String arch = System.getProperty("os.arch");
            String os = System.getProperty("os.name");
            String javaVersion = System.getProperty("java.version");
            messageLabel.setText("OS: " + os + " | Arch: " + arch + " | Java: " + javaVersion);
        });
        
        buttonBox.getChildren().addAll(helloButton, resetButton, infoButton);
        
        // System info label
        Label sysInfoLabel = new Label("Architecture: " + System.getProperty("os.arch") + 
                                     " | OS: " + System.getProperty("os.name"));
        sysInfoLabel.setFont(Font.font("Arial", FontWeight.NORMAL, 12));
        sysInfoLabel.setTextFill(Color.GRAY);
        
        // Add all components to root
        root.getChildren().addAll(titleLabel, messageLabel, counterLabel, buttonBox, sysInfoLabel);
        
        // Create scene
        scene = new Scene(root, 500, 350);
    }
    
    public Scene getScene() {
        return scene;
    }
}
