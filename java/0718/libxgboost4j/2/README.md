# XGBoost Hello World with JNI

This is a simple Hello World application that demonstrates loading the XGBoost library via JNI and creating a DMatrix to verify that the JNI binding is working correctly.

## Files

- `XGBoostHelloWorld.java`: The Java Hello World application that loads the XGBoost native library and creates a DMatrix.
- `compile_and_run.sh`: Script to compile and run the Hello World application on the current machine.
- `default_jre_jni_hello_world_run.sh`: Script to set up and run the Hello World application on another machine.

## Running on the Current Machine

To compile and run the Hello World application on the current machine:

```bash
./compile_and_run.sh
```

## Running on Another Machine

To run the Hello World application on another machine:

1. First, run the JNI installation script from the previous step:

```bash
./default_jre_jni_install.sh
```

2. Copy the XGBoost artifacts to the target machine:

```bash
# Create a directory for the artifacts
mkdir -p ~/xgboost_hello_world

# Copy the artifacts
cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar ~/xgboost_hello_world/
cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libxgboost.so ~/xgboost_hello_world/
cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/2/default_jre_jni_hello_world_run.sh ~/xgboost_hello_world/
```

3. Run the Hello World script:

```bash
cd ~/xgboost_hello_world
./default_jre_jni_hello_world_run.sh
```

## What the Hello World Application Does

1. Explicitly loads the XGBoost native library using `System.load()`.
2. Creates a simple DMatrix with 2 rows and 3 columns.
3. Sets labels for the DMatrix.
4. Retrieves and prints the number of rows in the DMatrix.
5. Disposes of the DMatrix to clean up resources.

If all steps complete successfully, it confirms that the JNI binding is working correctly.
