# TensorFlow JNI Hello World Applications

This directory contains three Java Hello World applications that demonstrate loading and using the compiled TensorFlow native libraries via JNI on ARM64.

## 📁 Applications

### 1. `SimpleJNIHelloWorld.java` - Basic JNI Loading Demo
**Purpose**: Demonstrates explicit library loading with `System.load()` and simple function calls.

**Features**:
- Explicit loading of `libtensorflow_framework.so` and `libtensorflow_jni.so`
- System information display
- Simple JNI function calls: `TensorFlow.version()` and `TensorFlow.registeredOpList()`
- Clear success/failure feedback

**Key JNI Calls**:
```java
System.load("/path/to/libtensorflow_framework.so");  // Load framework first
System.load("/path/to/libtensorflow_jni.so");        // Load JNI library
String version = TensorFlow.version();                // Simple string return
byte[] ops = TensorFlow.registeredOpList();          // Byte array return
```

### 2. `DetailedJNIDemo.java` - Comprehensive Library Information
**Purpose**: Provides detailed information about loaded libraries and comprehensive testing.

**Features**:
- Library file analysis (size, permissions, file type)
- System information display
- Multiple JNI function tests
- Tensor creation and manipulation
- Operation list parsing

**Key JNI Calls**:
```java
String version = TensorFlow.version();                    // Version info
byte[] opList = TensorFlow.registeredOpList();           // Available operations
Tensor<?> tensor = Tensor.create(3.14159f);              // Tensor creation
float value = tensor.floatValue();                       // Tensor access
```

### 3. `TensorFlowJNIHelloWorld.java` - Full Functionality Demo
**Purpose**: Demonstrates complete TensorFlow functionality including tensor operations.

**Features**:
- Explicit library loading with error handling
- TensorFlow version and operation list retrieval
- Tensor creation, manipulation, and cleanup
- Full error handling and status reporting

## 🚀 Running the Applications

### Method 1: Individual Compilation and Execution
```bash
# Compile
javac -cp libtensorflow.jar SimpleJNIHelloWorld.java

# Run
java -cp .:libtensorflow.jar SimpleJNIHelloWorld
```

### Method 2: Using the Demo Runner Script
```bash
# Run all demos interactively
./run_jni_demos.sh
```

### Method 3: Using the Convenience Script
```bash
# Run individual applications
./run_tensorflow_java.sh SimpleJNIHelloWorld
./run_tensorflow_java.sh DetailedJNIDemo
./run_tensorflow_java.sh TensorFlowJNIHelloWorld
```

## 📋 Expected Output

### SimpleJNIHelloWorld Output:
```
=== JNI Library Loading Demo ===
Framework Library: /home/ubuntu/go_page_size/java/tf_0714/libtensorflow_framework.so
JNI Library: /home/ubuntu/go_page_size/java/tf_0714/libtensorflow_jni.so

Loading framework library... ✅ SUCCESS
Loading JNI library... ✅ SUCCESS
✅ All native libraries loaded successfully!

=== Hello World with TensorFlow JNI ===
System Information:
  OS: Linux
  Architecture: aarch64
  Java Version: 11.0.27

Testing JNI function calls:
  TensorFlow.version(): '2.13.0' ✅
  TensorFlow.registeredOpList().length: 296238 bytes ✅

🎉 Hello World JNI Demo Complete!
🎉 Successfully called TensorFlow native functions on ARM64!
```

## 🔧 Technical Details

### Library Loading Order
1. **Framework Library First**: `libtensorflow_framework.so` must be loaded before the JNI library
2. **JNI Library Second**: `libtensorflow_jni.so` depends on the framework library

### JNI Functions Demonstrated
| Function | Arguments | Return Type | Purpose |
|----------|-----------|-------------|---------|
| `TensorFlow.version()` | None | String | Get TensorFlow version |
| `TensorFlow.registeredOpList()` | None | byte[] | Get available operations |
| `Tensor.create(value)` | float/int/etc | Tensor<?> | Create tensor |
| `tensor.floatValue()` | None | float | Get tensor value |
| `tensor.dataType()` | None | DataType | Get tensor type |
| `tensor.shape()` | None | long[] | Get tensor shape |

### Architecture Verification
All applications verify they're running on ARM64:
- OS Architecture: `aarch64`
- Library Type: `ELF 64-bit LSB shared object, ARM aarch64`

## 🐛 Troubleshooting

### Common Issues:
1. **UnsatisfiedLinkError**: Check library paths and permissions
2. **ClassNotFoundException**: Ensure `libtensorflow.jar` is in classpath
3. **Compilation Errors**: Use Java 11+ and correct classpath

### Verification Steps:
```bash
# Check library architecture
file libtensorflow_jni.so
file libtensorflow_framework.so

# Check library permissions
ls -la *.so

# Verify Java version
java -version
```

## 📦 Files Created
- `SimpleJNIHelloWorld.java` - Basic JNI demo
- `DetailedJNIDemo.java` - Comprehensive demo  
- `TensorFlowJNIHelloWorld.java` - Full functionality demo
- `run_jni_demos.sh` - Interactive demo runner
- Compiled `.class` files for each application

These applications prove that the compiled TensorFlow JNI libraries are fully functional on ARM64 and can be loaded and used via standard Java JNI mechanisms.
