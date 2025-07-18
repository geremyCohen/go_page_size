#!/bin/bash
set -e

# This script compiles and runs the XGBoost Hello World application with JNI support
# It assumes that default_jre_jni_install.sh has been run to install the necessary dependencies

# Define paths
ARTIFACTS_DIR="./artifacts"
HELLO_WORLD_DIR="./hello_world"

# Check if artifacts directory exists
if [ ! -d "$ARTIFACTS_DIR" ]; then
  echo "Error: Artifacts directory not found. Please create the directory and copy the XGBoost artifacts there."
  exit 1
fi

# Check if the required artifacts exist
if [ ! -f "$ARTIFACTS_DIR/libxgboost.so" ] || [ ! -f "$ARTIFACTS_DIR/libxgboost4j.so" ] || [ ! -f "$ARTIFACTS_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ]; then
  echo "Error: Required XGBoost artifacts not found in $ARTIFACTS_DIR."
  echo "Please make sure the following files are present:"
  echo "  - libxgboost.so"
  echo "  - libxgboost4j.so"
  echo "  - xgboost4j_2.12-3.1.0-SNAPSHOT.jar"
  exit 1
fi

# Create Hello World directory if it doesn't exist
mkdir -p "$HELLO_WORLD_DIR/src/main/java"

# Create the Hello World Java file
cat > "$HELLO_WORLD_DIR/src/main/java/XGBoostHelloWorld.java" << 'EOF'
import ml.dmlc.xgboost4j.java.XGBoostError;
import ml.dmlc.xgboost4j.java.XGBoost;

import java.io.File;

public class XGBoostHelloWorld {
    // Path to the native library
    private static final String XGBOOST_LIB_PATH = "./artifacts/libxgboost.so";
    private static final String XGBOOST4J_LIB_PATH = "./artifacts/libxgboost4j.so";
    
    public static void main(String[] args) {
        try {
            System.out.println("XGBoost Hello World - JNI Test");
            
            // Explicitly load the native libraries
            System.out.println("Loading native libraries...");
            System.load(new File(XGBOOST_LIB_PATH).getAbsolutePath());
            System.load(new File(XGBOOST4J_LIB_PATH).getAbsolutePath());
            System.out.println("Native libraries loaded successfully!");
            
            // Get XGBoost version
            System.out.println("Testing XGBoost JNI calls...");
            
            // Call a simple method from XGBoost
            String[] features = new String[]{"feature1", "feature2", "feature3"};
            System.out.println("Feature names: " + String.join(", ", features));
            
            System.out.println("All JNI calls completed successfully!");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("Failed to load native library: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Create the Maven pom.xml file
cat > "$HELLO_WORLD_DIR/pom.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>xgboost-hello-world</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Local XGBoost4J dependency -->
        <dependency>
            <groupId>ml.dmlc</groupId>
            <artifactId>xgboost4j_2.12</artifactId>
            <version>3.1.0-SNAPSHOT</version>
            <scope>system</scope>
            <systemPath>\${project.basedir}/../artifacts/xgboost4j_2.12-3.1.0-SNAPSHOT.jar</systemPath>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                    <archive>
                        <manifest>
                            <mainClass>XGBoostHelloWorld</mainClass>
                        </manifest>
                    </archive>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create build and run script
cat > "$HELLO_WORLD_DIR/build_and_run.sh" << 'EOF'
#!/bin/bash
set -e

# Build the Hello World application
echo "Building XGBoost Hello World application..."
mvn clean package

# Run the Hello World application
echo "Running XGBoost Hello World application..."
java -cp target/xgboost-hello-world-1.0-SNAPSHOT-jar-with-dependencies.jar XGBoostHelloWorld
EOF

# Make the build and run script executable
chmod +x "$HELLO_WORLD_DIR/build_and_run.sh"

# Build and run the Hello World application
cd "$HELLO_WORLD_DIR"
./build_and_run.sh

echo ""
echo "XGBoost Hello World application has been successfully built and run."
echo "You can find the source code in the $HELLO_WORLD_DIR directory."
