import javafx.application.Application;
import javafx.stage.Stage;

public class Main extends Application {
    private final HelloWorld helloWorld = new HelloWorld();
    
    public static void main(String[] args) {
        launch(args);
    }
    
    @Override
    public void start(Stage primaryStage) throws Exception {
        primaryStage.setTitle("Hello World - JavaFX ARM64 Demo");
        primaryStage.setScene(helloWorld.getScene());
        primaryStage.show();
    }
}
