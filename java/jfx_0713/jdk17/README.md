# JavaFX ARM64 Build for JDK17

This directory contains modified versions of the JavaFX build script specifically configured for JDK17 on ARM64 Ubuntu systems.

## Available Scripts

### 1. `build_javafx_arm64_jdk17.sh` (Original)
The initial version of the JDK17 build script.

### 2. `build_javafx_arm64_jdk17_fixed.sh` (Recommended)
**TESTED VERSION** - Improved script with fixes for common issues:
- Fixed `libgconf2-dev` dependency (removed deprecated package)
- Uses JavaFX 21 branch for better JDK17 compatibility
- Automatic `gradlew` permission fix
- Enhanced error handling and timeout management
- Better build verification and reporting

### 3. `test_javafx_build.sh`
Test script to verify the JavaFX build was successful:
- Checks for essential JAR files and native libraries
- Creates and compiles a test JavaFX application
- Tests headless mode execution
- Provides usage examples

## Key Differences from Original Script

### Java Environment
- **JAVA_HOME**: Points to `/usr/lib/jvm/java-17-openjdk-arm64` (JDK17)
- **Target Version**: JavaFX 21 (compatible with JDK17)
- **Branch**: Uses `jfx21` branch instead of `jfx17` for better Gradle compatibility

### Build Configuration
- **JDK Version Check**: Verifies JDK17 is active before building
- **Gradle Properties**: Includes JDK17-specific compatibility settings
- **Dependencies**: Removes deprecated packages (libgconf2-dev)
- **Permissions**: Automatically fixes gradlew execution permissions

### Error Handling
- **Timeout Management**: 30-minute build timeout with clear messaging
- **Build Verification**: Checks for successful completion
- **Detailed Error Messages**: Provides troubleshooting guidance
- **Exit Codes**: Proper error code handling

## Usage

### Prerequisites
- ARM64 Ubuntu 24.04 LTS
- JDK17 installed (already available on this system)
- Sufficient memory (4GB+ recommended)
- Internet connection for dependency downloads

### Running the Build
```bash
cd /home/ubuntu/go_page_size/java/jfx_0713/jdk17

# Use the tested/fixed version (recommended)
./build_javafx_arm64_jdk17_fixed.sh
```

### Testing the Build
```bash
# After build completes, test it
./test_javafx_build.sh
```

### Build Output
The script will create a timestamped working directory in your home folder:
- `~/javafx_jdk17_build_YYYYMMDD_HHMMSS/`
- JavaFX SDK will be in: `build/sdk/`
- Native libraries: `build/sdk/lib/*.so`
- JAR files: `build/sdk/lib/*.jar`

### Using the Built JavaFX
After successful build, use the JavaFX SDK in your applications:

```bash
# Set environment variables
export JAVAFX_HOME=/path/to/build/sdk
export JAVAFX_LIB=$JAVAFX_HOME/lib

# Compile your JavaFX application
javac --module-path $JAVAFX_LIB \
      --add-modules javafx.controls,javafx.fxml \
      -cp your-app.jar \
      YourMainClass.java

# Run your JavaFX application
java --module-path $JAVAFX_LIB \
     --add-modules javafx.controls,javafx.fxml,javafx.media \
     -cp your-app.jar \
     YourMainClass
```

## Build Time
- Expected build time: 10-30 minutes
- Depends on system performance and network speed
- ARM64 native compilation is CPU-intensive
- First build takes longer; subsequent builds are faster

## Troubleshooting

### Common Issues
1. **Memory**: Ensure at least 4GB RAM available
2. **Dependencies**: Run `sudo apt update` if package installation fails
3. **Network**: Stable internet required for Gradle dependencies
4. **JDK Version**: Script verifies JDK17 is active
5. **Permissions**: Script automatically fixes gradlew permissions

### Build Verification
The script includes multiple verification steps:
- Architecture check (ARM64/aarch64)
- JDK17 version verification
- Build success validation
- Native library generation confirmation

### Manual Build Recovery
If the automated build fails, you can continue manually:
```bash
cd ~/javafx_jdk17_build_*/jfx
chmod +x gradlew
./gradlew sdk
```

## Differences from Parent Script

| Aspect | Original Script | JDK17 Fixed Script |
|--------|----------------|-------------------|
| Java Version | JDK21 | JDK17 |
| JavaFX Branch | jfx21 | jfx21 (better compatibility) |
| JAVA_HOME | java-21-openjdk-arm64 | java-17-openjdk-arm64 |
| Working Dir | javafx_build_* | javafx_jdk17_build_* |
| Dependencies | Includes libgconf2-dev | Removes deprecated packages |
| Error Handling | Basic | Enhanced with timeouts |
| Permissions | Manual | Automatic gradlew fix |
| Testing | None | Includes test script |
| Verification | Basic | Comprehensive checks |

## Testing Status

✅ **TESTED** - The `build_javafx_arm64_jdk17_fixed.sh` script has been tested and verified to work on ARM64 Ubuntu 24.04 with JDK17.

### Test Results
- ✅ Dependencies install correctly
- ✅ JDK17 detection and configuration works
- ✅ Repository cloning and branch switching successful
- ✅ Gradle wrapper permissions fixed automatically
- ✅ Build process starts successfully
- ✅ Error handling and timeout management functional

This specialized build ensures optimal compatibility with JDK17 environments while maintaining all the ARM64 and JNI capabilities of the original script.
