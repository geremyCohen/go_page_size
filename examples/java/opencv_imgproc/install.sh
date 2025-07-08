#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev  \
     libtbb-dev libjpeg-dev libpng-dev libtiff-dev

sudo update-alternatives --config java && java -version

# 2. Clone OpenCV
cd
git clone https://github.com/opencv/opencv.git ~/opencv
cd ~/opencv

# 3. Patch OpenCV imgproc to add custom printf
COLOR_SRC=~/opencv/modules/imgproc/src/color.cpp
if [ -f "$COLOR_SRC" ]; then
    echo "Patching $COLOR_SRC"
    # Add include for printf at the top
    sed -i '1i#include <cstdio>' "$COLOR_SRC"
    
    # Clean up any previous patches
    sed -i '/printf("hello from custom imgproc/d' "$COLOR_SRC"
    sed -i '/fflush(stdout);/d' "$COLOR_SRC"
    
    # Apply the patch correctly - find the opening brace after the function declaration
    sed -i '/^void cvtColor( InputArray _src, OutputArray _dst, int code, int dcn, AlgorithmHint hint)$/,/^{$/{/^{$/a\    printf("hello from custom imgproc\\n"); fflush(stdout);}' "$COLOR_SRC"
    
    # Verify the patch was applied
    if grep -q "hello from custom imgproc" "$COLOR_SRC"; then
        echo "✓ Patch successfully applied"
    else
        echo "✗ Patch may not have been applied correctly"
    fi
else
    echo "color.cpp not found, trying alternative locations"
    find ~/opencv/modules/imgproc/src/ -name "*.cpp" | head -5
fi

# 4. Build OpenCV with Java bindings
mkdir -p ~/opencv/build && cd ~/opencv/build
cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D BUILD_JAVA=ON \
      -D BUILD_SHARED_LIBS=ON \
      -D OPENCV_GENERATE_PKGCONFIG=ON \
      ..

make -j$(nproc)
sudo make install
sudo ldconfig

# 5. Copy OpenCV Java bindings to system library path
sudo cp ~/opencv/build/lib/libopencv_java*.so /usr/local/lib/
sudo ldconfig

# 6. Install OpenCV Java jar locally into Maven repository
cd ~/opencv/build/bin
OPENCV_JAR=$(ls opencv-*.jar 2>/dev/null | head -1)
if [ -n "$OPENCV_JAR" ]; then
    # Get the actual version from the JAR filename
    OPENCV_VERSION=$(echo "$OPENCV_JAR" | sed 's/opencv-\([0-9]\+\.[0-9]\+\.[0-9]\+\).jar/\1/')
    echo "Installing OpenCV JAR: $OPENCV_JAR with version: $OPENCV_VERSION"
    mvn install:install-file \
      -Dfile="$OPENCV_JAR" \
      -DgroupId=org.opencv \
      -DartifactId=opencv-java-local \
      -Dversion="$OPENCV_VERSION" \
      -Dpackaging=jar
    
    # Also copy JAR to project directory for direct classpath use
    cp "$OPENCV_JAR" ~/go_page_size/examples/java/opencv_imgproc/
else
    echo "OpenCV JAR not found in ~/opencv/build/bin/"
    ls -la ~/opencv/build/bin/
fi

# 7. Set JNI library visibility permanently
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && source ~/.bashrc

# 8. Navigate to project directory and compile
cd ~/go_page_size/examples/java/opencv_imgproc/

# 9. Compile and prepare Java app
mvn clean compile dependency:copy-dependencies

# 10. Find the actual OpenCV Java library name and update Java code
OPENCV_LIB=$(ls /usr/local/lib/libopencv_java*.so 2>/dev/null | head -1)
if [ -n "$OPENCV_LIB" ]; then
    echo "Found OpenCV library: $OPENCV_LIB"
    # Recompile after updating the library path
    mvn clean compile
else
    echo "OpenCV library not found in /usr/local/lib/"
    ls -la /usr/local/lib/libopencv*
fi

# 11. Run the application with OpenCV JAR in classpath
OPENCV_JAR_LOCAL=$(ls opencv-*.jar 2>/dev/null | head -1)
if [ -n "$OPENCV_JAR_LOCAL" ]; then
    java -cp "target/classes:target/dependency/*:$OPENCV_JAR_LOCAL" com.example.OpenCVDemo
else
    echo "OpenCV JAR not found in current directory"
    ls -la *.jar
fi