#!/bin/bash

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

sudo update-alternatives --config java && java -version

# 2. Clone OpenCV
cd
git clone https://github.com/opencv/opencv.git ~/opencv
cd ~/opencv

# 3. Patch OpenCV imgproc to add custom printf
# Find the imgproc module's main source file and add our custom print
IMGPROC_SRC=~/opencv/modules/imgproc/src/imgproc.cpp
if [ -f "$IMGPROC_SRC" ]; then
    # Add include for printf at the top
    sed -i '1i#include <cstdio>' "$IMGPROC_SRC"
    
    # Find a function to patch - let's use cvtColor which is commonly used
    # Add our custom print at the beginning of cvtColor function
    sed -i '/^void cv::cvtColor/a\    printf("hello from custom imgproc\\n"); fflush(stdout);' "$IMGPROC_SRC"
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
mvn install:install-file \
  -Dfile=opencv-*.jar \
  -DgroupId=org.opencv \
  -DartifactId=opencv-java-local \
  -Dversion=4.x.x-SNAPSHOT \
  -Dpackaging=jar

# 7. Set JNI library visibility permanently
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && source ~/.bashrc

# 8. Navigate to project directory and compile
cd /Users/gercoh01/kustomer/go_page_size/examples/java/opencv_imgproc

# 9. Compile and prepare Java app
mvn clean compile dependency:copy-dependencies

# 10. Run the application
java -cp "target/classes:target/dependency/*" com.example.OpenCVDemo