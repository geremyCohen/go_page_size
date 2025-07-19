# libxgboost4j with JNI Support

This project contains the XGBoost library compiled with JNI support for ARM64 architecture on Ubuntu 24.

## Build Artifacts

The following artifacts have been generated:

1. **Native Library (.so)**: 
   - Location: `/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libxgboost.so`
   - This is the native C++ library that provides the core XGBoost functionality.

2. **Java Library (.jar)**:
   - Location: `/home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar`
   - This is the Java wrapper library that uses JNI to interface with the native XGBoost library.

## Using the Libraries

To use these libraries in a Java application:

1. Add the JAR file to your Java classpath:
   ```bash
   export CLASSPATH=$CLASSPATH:/path/to/xgboost4j_2.12-3.1.0-SNAPSHOT.jar
   ```

2. Make sure the native library is in the Java library path:
   ```bash
   export LD_LIBRARY_PATH=/path/to/directory/containing/libxgboost.so:$LD_LIBRARY_PATH
   ```

3. In your Java code, you can now use the XGBoost API:
   ```java
   import ml.dmlc.xgboost4j.java.XGBoost;
   import ml.dmlc.xgboost4j.java.DMatrix;
   import ml.dmlc.xgboost4j.java.Booster;
   ```

## Setting Up JNI Development Environment

To set up a JNI development environment on another machine, run the provided installation script:

```bash
./default_jre_jni_install.sh
```

This script will:
1. Install OpenJDK 21
2. Install necessary build tools (gcc, cmake, etc.)
3. Set up environment variables
4. Create a simple JNI test to verify the setup

## Testing the JNI Setup

To verify that the JNI setup is working correctly, run the basic test script:

```bash
./ai_util/basic_test_jni.sh
```

This script creates a simple Java program that loads the XGBoost class to verify that the JNI bindings are working correctly.

## Building from Source

If you need to rebuild the library, follow these steps:

1. Clone the XGBoost repository:
   ```bash
   git clone --recursive https://github.com/dmlc/xgboost.git
   ```

2. Build the C++ library:
   ```bash
   cd xgboost
   mkdir build
   cd build
   cmake .. -DBUILD_SHARED_LIBS=ON -DUSE_CUDA=OFF -DBUILD_WITH_SHARED_NCCL=OFF
   make -j4
   ```

3. Build the Java package:
   ```bash
   cd ../jvm-packages
   mvn clean package -DskipTests
   ```

4. The built artifacts will be in:
   - Native library: `xgboost/lib/libxgboost.so`
   - Java library: `xgboost/jvm-packages/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar`
