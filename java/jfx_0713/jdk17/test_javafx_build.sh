#!/bin/bash

# Test script for JavaFX JDK17 build
# This script tests if the JavaFX build was successful

set -e

echo "=== JavaFX JDK17 Build Test Script ==="
echo

# Find the most recent build directory
BUILD_DIR=$(find $HOME -name "javafx_jdk17_build_*" -type d | sort | tail -1)

if [ -z "$BUILD_DIR" ]; then
    echo "ERROR: No JavaFX build directory found"
    echo "Please run the build script first"
    exit 1
fi

echo "Testing build in: $BUILD_DIR"

# Check if SDK directory exists
SDK_DIR="$BUILD_DIR/jfx/build/sdk"
if [ ! -d "$SDK_DIR" ]; then
    echo "ERROR: SDK directory not found at $SDK_DIR"
    echo "Build may have failed or is still in progress"
    exit 1
fi

echo "✓ SDK directory found: $SDK_DIR"

# Check for essential JAR files
echo
echo "=== Checking JAR Files ==="
ESSENTIAL_JARS=("javafx.base.jar" "javafx.controls.jar" "javafx.fxml.jar" "javafx.graphics.jar")

for jar in "${ESSENTIAL_JARS[@]}"; do
    if [ -f "$SDK_DIR/lib/$jar" ]; then
        echo "✓ $jar found ($(du -h "$SDK_DIR/lib/$jar" | cut -f1))"
    else
        echo "✗ $jar missing"
    fi
done

# Check for native libraries
echo
echo "=== Checking Native Libraries ==="
NATIVE_LIBS=("libjavafx_font.so" "libjavafx_iio.so" "libprism_es2.so")

for lib in "${NATIVE_LIBS[@]}"; do
    if [ -f "$SDK_DIR/lib/$lib" ]; then
        echo "✓ $lib found ($(file "$SDK_DIR/lib/$lib" | grep -o 'ARM aarch64' || echo 'Native library'))"
    else
        echo "✗ $lib missing"
    fi
done

# Create a simple JavaFX test application
echo
echo "=== Creating Test Application ==="
TEST_DIR="$BUILD_DIR/test"
mkdir -p "$TEST_DIR"

cat > "$TEST_DIR/JavaFXTest.java" << 'EOF'
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class JavaFXTest extends Application {
    
    @Override
    public void start(Stage primaryStage) {
        Label label = new Label("JavaFX JDK17 ARM64 Build Test - SUCCESS!");
        label.setStyle("-fx-font-size: 16px; -fx-text-fill: green;");
        
        StackPane root = new StackPane();
        root.getChildren().add(label);
        
        Scene scene = new Scene(root, 400, 200);
        
        primaryStage.setTitle("JavaFX JDK17 Test");
        primaryStage.setScene(scene);
        primaryStage.show();
        
        // Auto-close after 3 seconds for headless testing
        new Thread(() -> {
            try {
                Thread.sleep(3000);
                javafx.application.Platform.exit();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();
    }
    
    public static void main(String[] args) {
        System.out.println("Starting JavaFX JDK17 ARM64 test...");
        launch(args);
        System.out.println("JavaFX test completed successfully!");
    }
}
EOF

# Compile the test application
echo "Compiling test application..."
cd "$TEST_DIR"

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH=$JAVA_HOME/bin:$PATH

javac --module-path "$SDK_DIR/lib" \
      --add-modules javafx.controls,javafx.fxml \
      JavaFXTest.java

if [ $? -eq 0 ]; then
    echo "✓ Test application compiled successfully"
else
    echo "✗ Test application compilation failed"
    exit 1
fi

# Test headless mode (without GUI)
echo
echo "=== Testing Headless Mode ==="
export DISPLAY=:99.0
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!

sleep 2

# Run the test application
echo "Running JavaFX test application..."
timeout 10 java --module-path "$SDK_DIR/lib" \
                --add-modules javafx.controls,javafx.fxml \
                -Djava.awt.headless=false \
                -Dtestfx.robot=glass \
                -Dtestfx.headless=true \
                -Dprism.order=sw \
                JavaFXTest

TEST_EXIT_CODE=$?

# Clean up
kill $XVFB_PID 2>/dev/null || true

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ JavaFX test application ran successfully"
else
    echo "✗ JavaFX test application failed (exit code: $TEST_EXIT_CODE)"
    echo "Note: This may be expected in headless environments"
fi

echo
echo "=== Test Summary ==="
echo "Build directory: $BUILD_DIR"
echo "SDK directory: $SDK_DIR"
echo "Test directory: $TEST_DIR"
echo
echo "=== Usage Example ==="
echo "To use this JavaFX build in your applications:"
echo "export JAVAFX_HOME=$SDK_DIR"
echo "export JAVAFX_LIB=\$JAVAFX_HOME/lib"
echo
echo "javac --module-path \$JAVAFX_LIB --add-modules javafx.controls,javafx.fxml YourApp.java"
echo "java --module-path \$JAVAFX_LIB --add-modules javafx.controls,javafx.fxml YourApp"

echo
echo "=== Test Completed ==="
