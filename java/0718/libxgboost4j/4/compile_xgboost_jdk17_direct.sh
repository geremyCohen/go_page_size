#!/bin/bash

# Script to compile XGBoost with JNI support for JDK 17 using direct Maven commands
# For ARM64 architecture

set -e  # Exit on error

echo "Compiling XGBoost with JNI support for JDK 17..."

# Check if we're running as root
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, no need for sudo
    APT_CMD="apt-get"
else
    # Not running as root, use sudo
    APT_CMD="sudo apt-get"
fi

# Install Python if not already installed
if ! command -v python &> /dev/null; then
    echo "Python not found. Installing Python..."
    $APT_CMD update
    $APT_CMD install -y python3 python-is-python3
fi

# Create directories
WORK_DIR=$(pwd)
BUILD_DIR="$WORK_DIR/build"
ARTIFACTS_DIR="$WORK_DIR/artifacts"

mkdir -p "$BUILD_DIR"
mkdir -p "$ARTIFACTS_DIR"

# Clone XGBoost repository if it doesn't exist
if [ ! -d "$BUILD_DIR/xgboost" ]; then
    echo "Cloning XGBoost repository..."
    cd "$BUILD_DIR"
    git clone --recursive https://github.com/dmlc/xgboost.git
fi

# Build the C++ library
echo "Building XGBoost C++ library..."
cd "$BUILD_DIR/xgboost"
mkdir -p build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DUSE_CUDA=OFF -DBUILD_WITH_SHARED_NCCL=OFF
make -j4

# Set JAVA_HOME to JDK 17
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "Using JAVA_HOME: $JAVA_HOME"

# Build the Java package with JDK 17
echo "Building XGBoost Java package with JDK 17..."
cd "$BUILD_DIR/xgboost/jvm-packages"

# Modify the pom.xml to use Java 17 instead of Java 8
echo "Updating pom.xml to use Java 17..."
sed -i 's/<maven.compiler.source>1.8<\/maven.compiler.source>/<maven.compiler.source>17<\/maven.compiler.source>/g' pom.xml
sed -i 's/<maven.compiler.target>1.8<\/maven.compiler.target>/<maven.compiler.target>17<\/maven.compiler.target>/g' pom.xml

# Create a custom settings.xml file for Maven
echo "Creating custom Maven settings for JDK 17 compatibility..."
cat > settings.xml << 'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <profiles>
    <profile>
      <id>jdk17-compatibility</id>
      <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <scala.maven.plugin.jvmArgs>
          --add-opens=java.base/java.lang=ALL-UNNAMED
          --add-opens=java.base/java.lang.invoke=ALL-UNNAMED
          --add-opens=java.base/java.lang.reflect=ALL-UNNAMED
          --add-opens=java.base/java.io=ALL-UNNAMED
          --add-opens=java.base/java.net=ALL-UNNAMED
          --add-opens=java.base/java.nio=ALL-UNNAMED
          --add-opens=java.base/java.util=ALL-UNNAMED
          --add-opens=java.base/java.util.concurrent=ALL-UNNAMED
          --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED
          --add-opens=java.base/sun.nio.ch=ALL-UNNAMED
          --add-opens=java.base/sun.nio.cs=ALL-UNNAMED
          --add-opens=java.base/sun.security.action=ALL-UNNAMED
          --add-opens=java.base/sun.util.calendar=ALL-UNNAMED
        </scala.maven.plugin.jvmArgs>
      </properties>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>jdk17-compatibility</activeProfile>
  </activeProfiles>
</settings>
EOF

# Create a wrapper script to run Maven with the right JVM arguments
echo "Creating Maven wrapper script..."
cat > mvn_wrapper.sh << 'EOF'
#!/bin/bash
export MAVEN_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
mvn -s settings.xml "$@"
EOF
chmod +x mvn_wrapper.sh

# Try a different approach: use the scala-maven-plugin directly with JVM args
echo "Building the Java package with JDK 17 using direct Maven command..."
./mvn_wrapper.sh clean package -DskipTests

# If the above fails, try an alternative approach with direct JVM args
if [ $? -ne 0 ]; then
    echo "First attempt failed. Trying alternative approach..."
    
    # Create a direct JVM args file
    echo "Creating direct JVM args file..."
    cat > .jvmopts << 'EOF'
--add-opens=java.base/java.lang=ALL-UNNAMED
--add-opens=java.base/java.lang.invoke=ALL-UNNAMED
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED
--add-opens=java.base/java.io=ALL-UNNAMED
--add-opens=java.base/java.net=ALL-UNNAMED
--add-opens=java.base/java.nio=ALL-UNNAMED
--add-opens=java.base/java.util=ALL-UNNAMED
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED
--add-opens=java.base/sun.nio.cs=ALL-UNNAMED
--add-opens=java.base/sun.security.action=ALL-UNNAMED
--add-opens=java.base/sun.util.calendar=ALL-UNNAMED
EOF

    # Try with direct JVM args
    export MAVEN_OPTS="@.jvmopts"
    mvn clean package -DskipTests
    
    # If that still fails, try with a different Scala version
    if [ $? -ne 0 ]; then
        echo "Second attempt failed. Trying with a different Scala version..."
        
        # Modify the Scala version to a more compatible one
        sed -i 's/<scala.version>2.12.18<\/scala.version>/<scala.version>2.12.15<\/scala.version>/g' pom.xml
        sed -i 's/<scala.binary.version>2.12<\/scala.binary.version>/<scala.binary.version>2.12<\/scala.binary.version>/g' pom.xml
        
        # Try again with the modified Scala version
        mvn clean package -DskipTests
    fi
fi

# Copy the artifacts
echo "Copying artifacts..."
cp "$BUILD_DIR/xgboost/lib/libxgboost.so" "$ARTIFACTS_DIR/"
cp "$BUILD_DIR/xgboost/build/dmlc-core/libdmlc.so.0.6" "$ARTIFACTS_DIR/"
ln -sf "$ARTIFACTS_DIR/libdmlc.so.0.6" "$ARTIFACTS_DIR/libdmlc.so.0"

# Check if the JAR file was built
if [ -f "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ]; then
    cp "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "$ARTIFACTS_DIR/"
else
    echo "Warning: xgboost4j_2.12-3.1.0-SNAPSHOT.jar was not built."
    echo "Checking for alternative JAR files..."
    
    # Look for any JAR files in the target directory
    JAR_FILES=$(find "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target" -name "*.jar" | grep -v "sources\|javadoc")
    
    if [ -n "$JAR_FILES" ]; then
        echo "Found alternative JAR files:"
        echo "$JAR_FILES"
        
        # Copy the first JAR file found
        FIRST_JAR=$(echo "$JAR_FILES" | head -n 1)
        cp "$FIRST_JAR" "$ARTIFACTS_DIR/xgboost4j.jar"
        echo "Copied $FIRST_JAR to $ARTIFACTS_DIR/xgboost4j.jar"
    else
        echo "No JAR files found. Trying to build a minimal JAR..."
        
        # Try to build a minimal JAR with just the native library
        cd "$BUILD_DIR/xgboost/jvm-packages/xgboost4j"
        mkdir -p target/classes/lib
        cp "$BUILD_DIR/xgboost/lib/libxgboost.so" target/classes/lib/
        
        # Create a minimal JAR file
        cd target/classes
        jar cf "$ARTIFACTS_DIR/xgboost4j-minimal.jar" .
        echo "Created a minimal JAR file: $ARTIFACTS_DIR/xgboost4j-minimal.jar"
    fi
fi

echo "Compilation complete! Artifacts are available in $ARTIFACTS_DIR"
echo "- libxgboost.so: Native XGBoost library"
echo "- libdmlc.so.0.6: Dependency of libxgboost.so"
echo "- libdmlc.so.0: Symlink to libdmlc.so.0.6"
if [ -f "$ARTIFACTS_DIR/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" ]; then
    echo "- xgboost4j_2.12-3.1.0-SNAPSHOT.jar: Java XGBoost library"
elif [ -f "$ARTIFACTS_DIR/xgboost4j.jar" ]; then
    echo "- xgboost4j.jar: Java XGBoost library (alternative)"
elif [ -f "$ARTIFACTS_DIR/xgboost4j-minimal.jar" ]; then
    echo "- xgboost4j-minimal.jar: Minimal Java XGBoost library"
fi
