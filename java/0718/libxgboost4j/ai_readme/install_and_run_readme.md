# Docker Container Install and Run Script

This script creates a Docker container named `3_libxgboost4j_1` and runs the JDK17 installation and hello world applications inside it.

## What the Script Does

1. Creates a Docker container named `3_libxgboost4j_1` based on Ubuntu
2. Installs Python in the container (required for XGBoost build process)
3. Copies the JDK17 scripts and artifacts to the container
4. Runs the JDK17 installation script in the container
5. Runs the JDK17 hello world application in the container

## Prerequisites

- Docker installed on the host machine
- XGBoost artifacts already built and available in the `ai_build` directory:
  - `xgboost4j_2.12-3.1.0-SNAPSHOT.jar`
  - `libxgboost.so`
  - `libdmlc.so.0.6` or `libdmlc.so.0`

## Usage

Make the script executable and run it:

```bash
chmod +x install_and_run.sh
./install_and_run.sh
```

## Expected Output

If the script runs successfully, you should see output from each of the steps, including:

1. Creation of the Docker container
2. Installation of Python and JDK17 in the container
3. Running of the XGBoost hello world application in the container

The final output should include a message indicating that the JDK17 installation and hello world test have been completed successfully in the container.

## Container Management

- To access the container: `docker exec -it 3_libxgboost4j_1 bash`
- To stop the container: `docker stop 3_libxgboost4j_1`
- To remove the container: `docker rm 3_libxgboost4j_1`

## Troubleshooting

If the script fails at any point, check the error message for details. Common issues include:

- Docker not installed or not running
- XGBoost artifacts not built or not available in the `ai_build` directory
- Network connectivity issues in the container
- Insufficient disk space

## Notes

- The script automatically removes any existing container with the same name before creating a new one
- The container continues running after the script completes, so remember to stop and remove it when you're done
- If you need to run the script multiple times with different iterations, change the container name in the script
- Python is required for the XGBoost build process, so the script installs it automatically
