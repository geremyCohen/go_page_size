# XGBoost JDK17 Clone and Run Script

This script automates the process of cloning the repository and running the JDK17-specific XGBoost scripts.

## What the Script Does

1. Installs required tools (git, wget, maven)
2. Clones the repository
3. Runs the JDK17 installation script
4. Runs the JDK17 XGBoost compile script
5. Runs the JDK17 XGBoost hello world script

## Prerequisites

- Ubuntu operating system (tested on Ubuntu 24.04)
- Internet connection
- Sudo privileges (if not running as root)

## Usage

Before using the script, you need to modify it to include the correct repository URL:

1. Open the script in a text editor
2. Replace the placeholder URL in the `git clone` command with your actual repository URL
3. Save the changes

Then, make the script executable and run it:

```bash
chmod +x clone_and_run_jdk17.sh
./clone_and_run_jdk17.sh
```

## Expected Output

If the script runs successfully, you should see output from each of the steps, including:

1. Installation of required tools
2. Cloning of the repository
3. Installation of JDK17 and development tools
4. Compilation of XGBoost with JDK17 support
5. Running of the XGBoost hello world application

The final output should include a message indicating that the JDK17 XGBoost installation, compilation, and hello world test have been completed successfully.

## Troubleshooting

If the script fails at any point, check the error message for details. Common issues include:

- Incorrect repository URL
- Network connectivity issues
- Insufficient disk space
- Missing dependencies

## Notes

- The script assumes a fresh Ubuntu installation
- It will create a directory called `xgboost_jdk17_test` in your home directory
- The compilation process may take some time, especially on slower machines
