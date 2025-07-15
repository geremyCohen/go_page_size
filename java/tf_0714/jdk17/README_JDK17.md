# TensorFlow JNI Compilation for JDK17 on ARM64

This directory contains the JDK17-specific build script and artifacts for compiling TensorFlow with JNI support on ARM64 Ubuntu 24.

## Key Differences from JDK11 Build

### 1. Java Runtime Configuration
- **JDK17 Path**: `/usr/lib/jvm/java-17-openjdk-arm64`
- **Remote JDK**: Uses `remotejdk_17` for Bazel builds
- **C++ Standard**: Enforces C++17 standard compatibility

### 2. Build Flags
The JDK17 build includes additional compiler flags:
```bash
--java_runtime_version=remotejdk_17
--cxxopt=-std=c++17
--host_cxxopt=-std=c++17
--action_env=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
```

### 3. Output Naming Convention
All JDK17 artifacts are suffixed with `-jdk17`:
- `libtensorflow-arm64-jdk17.jar` (complete JAR with native libraries)
- `libtensorflow_jni-jdk17.so` (JNI native library)
- `libtensorflow_framework-jdk17.so` (framework library)

## Usage

### Compilation
```bash
cd jdk17
./compile_tensorflow_jni_jdk17.sh
```

### Running Applications
```bash
# Method 1: Direct java command
java -cp .:libtensorflow-arm64-jdk17.jar YourTensorFlowApp

# Method 2: Using the convenience script
./run_tensorflow_jdk17.sh YourJavaClass
```

## Built-in Test
The script creates a test class `TestTensorFlowJdk17.java` that verifies:
- ✅ TensorFlow version detection
- ✅ JDK17 version information
- ✅ Basic tensor operations
- ✅ Graph execution

## JDK17-Specific Considerations

### 1. Module System Compatibility
JDK17's module system is fully compatible with TensorFlow JNI, no additional module configuration needed.

### 2. Performance Improvements
JDK17 includes several performance improvements over JDK11:
- Better garbage collection
- Improved JIT compilation
- Enhanced vector API support

### 3. Security Enhancements
JDK17 provides additional security features that work seamlessly with TensorFlow JNI.

## Troubleshooting

### Common Issues
1. **Module Path Conflicts**: If using modules, ensure TensorFlow JAR is on the classpath, not module path
2. **JVM Arguments**: JDK17 may require `--add-opens` for some reflection operations (usually not needed for TensorFlow)

### Verification Commands
```bash
# Check Java version
java -version

# Verify JAR contents
jar -tf libtensorflow-arm64-jdk17.jar | grep "linux-aarch64"

# Test library loading
java -cp .:libtensorflow-arm64-jdk17.jar -Dorg.tensorflow.NativeLibrary.DEBUG=1 TestTensorFlowJdk17
```

## Build Time
Expected build time: ~4-5 hours on ARM64 system (similar to JDK11 build)

## Compatibility
- **Minimum Java Version**: JDK17
- **Architecture**: ARM64 (aarch64)
- **OS**: Ubuntu 24.04 or compatible Linux distributions
- **TensorFlow Version**: 2.13.0
