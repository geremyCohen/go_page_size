# Standalone XGBoost JDK17 Script

This is a standalone script that installs JDK17, compiles XGBoost with JNI support, and runs a hello world example. Unlike the clone script, this script doesn't require cloning a repository - it creates all necessary files locally.

## What the Script Does

1. Creates all necessary scripts in a local directory
2. Installs JDK17 and required tools (git, wget, maven)
3. Compiles XGBoost with JDK17 support
4. Runs a hello world example to verify the installation

## Prerequisites

- Ubuntu operating system (tested on Ubuntu 24.04)
- Internet connection
- Sudo privileges (if not running as root)

## Usage

Make the script executable and run it:

```bash
chmod +x standalone_jdk17_xgboost.sh
./standalone_jdk17_xgboost.sh
```

## Expected Output

If the script runs successfully, you should see output from each of the steps, including:

1. Creation of necessary scripts
2. Installation of JDK17 and development tools
3. Compilation of XGBoost with JDK17 support
4. Running of the XGBoost hello world application

The final output should include a message indicating that the JDK17 XGBoost installation, compilation, and hello world test have been completed successfully.

## Directory Structure

The script creates the following directory structure:

```
~/xgboost_jdk17/
├── jdk17_install.sh
├── compile_xgboost_jdk17.sh
├── jdk17_hello_world_run.sh
├── build/
│   └── xgboost/
└── artifacts/
    ├── libxgboost.so
    ├── libdmlc.so.0.6
    ├── libdmlc.so.0
    └── xgboost4j_2.12-3.1.0-SNAPSHOT.jar
```

## Troubleshooting

If the script fails at any point, check the error message for details. Common issues include:

- Network connectivity issues
- Insufficient disk space
- Missing dependencies

## Notes

- The compilation process may take some time, especially on slower machines
- The script has been tested with JDK17 on Ubuntu 24.04
- The script uses the latest version of XGBoost from the official repository
