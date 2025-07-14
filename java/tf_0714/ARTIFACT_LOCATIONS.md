# TensorFlow JNI Artifacts Location Guide

## Current Working Directory: `/home/ubuntu/go_page_size/java/tf_0714/`

### 🎯 **PRIMARY DELIVERABLES (Ready to Use)**

#### Main Directory (`/home/ubuntu/go_page_size/java/tf_0714/`)
```
libtensorflow-arm64.jar          96M   - COMPLETE JAR with embedded native libraries (RECOMMENDED)
libtensorflow.jar               2.6M   - Java API classes only
libtensorflow_jni.so            214M   - ARM64 JNI native library
libtensorflow_framework.so       40M   - TensorFlow framework shared library
```

### 🔧 **BUILD ARTIFACTS (Original Build Outputs)**

#### TensorFlow Build Directory (`tensorflow/bazel-bin/tensorflow/`)
```
libtensorflow_framework.so.2.13.0    41M   - Original framework library with version
libtensorflow_framework.so.2         →     - Symlink to versioned library
libtensorflow_framework.so            →     - Symlink to versioned library
```

#### Java Build Directory (`tensorflow/bazel-bin/tensorflow/java/`)
```
libtensorflow.jar                   2.6M   - Java API classes
libtensorflow-class.jar             2.6M   - Compiled Java classes
libtensorflow-gensrc.jar             74K   - Generated source code
libtensorflow-native-header.jar     6.6K   - Native header files
libtensorflow_jni.so                214M   - ARM64 JNI native library
```

### 📁 **DETAILED FILE BREAKDOWN**

#### JAR Files
| File | Size | Location | Purpose |
|------|------|----------|---------|
| `libtensorflow-arm64.jar` | 96M | Main directory | **RECOMMENDED** - Complete self-contained JAR |
| `libtensorflow.jar` | 2.6M | Main directory & build dir | Java API classes only |
| `libtensorflow-class.jar` | 2.6M | Build directory | Compiled Java classes |
| `libtensorflow-gensrc.jar` | 74K | Build directory | Generated source code |
| `libtensorflow-native-header.jar` | 6.6K | Build directory | JNI header files |

#### Shared Libraries (.so files)
| File | Size | Location | Purpose |
|------|------|----------|---------|
| `libtensorflow_jni.so` | 214M | Main directory & build dir | ARM64 JNI native library |
| `libtensorflow_framework.so` | 40M | Main directory | Framework shared library |
| `libtensorflow_framework.so.2.13.0` | 41M | Build directory | Original versioned framework |

### 🚀 **USAGE RECOMMENDATIONS**

#### Option 1: Self-Contained JAR (Easiest)
```bash
# Use the complete JAR with embedded native libraries
java -cp .:libtensorflow-arm64.jar YourApp
```

#### Option 2: Separate JAR and Libraries
```bash
# Use separate JAR and native libraries
java -cp .:libtensorflow.jar -Djava.library.path=. YourApp
```

#### Option 3: Convenience Script
```bash
# Use the provided script
./run_tensorflow_java.sh YourApp
```

### 🔍 **FILE VERIFICATION**

#### Checksums (SHA256)
```
663ecce8ae0d54f4c8a20b084c355eeb688b1f2578d4c31210487b3f923c8b0a  libtensorflow-arm64.jar
863f8e187fd6902ac1cd5e5a08ce2a844a4b526c5e83c6d213f532da9373be34  libtensorflow_jni.so
0e1b4fe6917b201aa8ad9832b5245028fc370f70f41c686f559bd053d4b2ffe8  libtensorflow_framework.so
```

#### Architecture Verification
```bash
file libtensorflow_jni.so
# Output: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV)

file libtensorflow_framework.so  
# Output: ELF 64-bit LSB shared object, ARM aarch64, version 1 (GNU/Linux)
```

### 📦 **DEPLOYMENT PACKAGE**

For deployment, you only need:
1. **`libtensorflow-arm64.jar`** - Complete self-contained library
2. **`run_tensorflow_java.sh`** - Convenience script (optional)

The `libtensorflow-arm64.jar` contains:
- All Java API classes
- ARM64 native JNI library (`libtensorflow_jni.so`)
- ARM64 framework library (`libtensorflow_framework.so.2`)
- Proper directory structure for automatic loading

### 🎯 **RECOMMENDED DEPLOYMENT**

Copy these files to your target system:
```
libtensorflow-arm64.jar    # Complete TensorFlow library
run_tensorflow_java.sh     # Convenience script
YourApplication.java       # Your Java application
```

Then run:
```bash
chmod +x run_tensorflow_java.sh
./run_tensorflow_java.sh YourApplication
```
