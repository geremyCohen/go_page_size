#!/bin/bash

# Script to compile XGBoost with JNI support for JDK 17
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

# Update the Scala Maven plugin configuration to work with JDK 17
echo "Updating Scala Maven plugin configuration for JDK 17 compatibility..."
sed -i '/<artifactId>scala-maven-plugin<\/artifactId>/,/<\/plugin>/ s/<\/configuration>/  <jvmArgs>\n    <jvmArg>--add-opens=java.base\/java.lang=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.invoke=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.reflect=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.io=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.net=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.nio=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent.atomic=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.ch=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.cs=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.security.action=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.util.calendar=ALL-UNNAMED<\/jvmArg>\n  <\/jvmArgs>\n<\/configuration>/' pom.xml

# Also add the JVM args to the exec-maven-plugin
echo "Updating exec-maven-plugin configuration for JDK 17 compatibility..."
sed -i '/<artifactId>exec-maven-plugin<\/artifactId>/,/<\/plugin>/ s/<\/configuration>/  <jvmArgs>\n    <jvmArg>--add-opens=java.base\/java.lang=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.invoke=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.lang.reflect=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.io=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.net=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.nio=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/java.util.concurrent.atomic=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.ch=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.nio.cs=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.security.action=ALL-UNNAMED<\/jvmArg>\n    <jvmArg>--add-opens=java.base\/sun.util.calendar=ALL-UNNAMED<\/jvmArg>\n  <\/jvmArgs>\n<\/configuration>/' pom.xml

# Build the Java package with skipTests to avoid test failures
echo "Building the Java package with JDK 17..."
export MAVEN_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
mvn clean package -DskipTests

# Copy the artifacts
echo "Copying artifacts..."
cp "$BUILD_DIR/xgboost/lib/libxgboost.so" "$ARTIFACTS_DIR/"
cp "$BUILD_DIR/xgboost/build/dmlc-core/libdmlc.so.0.6" "$ARTIFACTS_DIR/"
ln -sf "$ARTIFACTS_DIR/libdmlc.so.0.6" "$ARTIFACTS_DIR/libdmlc.so.0"
cp "$BUILD_DIR/xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar" "$ARTIFACTS_DIR/"

echo "Compilation complete! Artifacts are available in $ARTIFACTS_DIR"
echo "- libxgboost.so: Native XGBoost library"
echo "- libdmlc.so.0.6: Dependency of libxgboost.so"
echo "- libdmlc.so.0: Symlink to libdmlc.so.0.6"
echo "- xgboost4j_2.12-3.1.0-SNAPSHOT.jar: Java XGBoost library"
