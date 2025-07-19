#!/bin/bash

# Script to run the end-to-end test of the JNI installation and Hello World scripts

set -e  # Exit on error

echo "Running end-to-end test of JNI installation and Hello World scripts..."

# Create a new Docker container
CONTAINER_NAME="0_libxgboost4j_test"
echo "Creating Docker container: $CONTAINER_NAME"
docker run -d --name $CONTAINER_NAME -it ubuntu:24.04

# Create a directory for the test
echo "Creating test directory in the container"
docker exec $CONTAINER_NAME mkdir -p /root/test

# Copy the scripts and artifacts to the container
echo "Copying scripts and artifacts to the container"
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/default_jre_jni_install.sh $CONTAINER_NAME:/root/test/
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/2/default_jre_jni_hello_world_run.sh $CONTAINER_NAME:/root/test/
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libxgboost.so $CONTAINER_NAME:/root/test/
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/xgboost4j_2.12-3.1.0-SNAPSHOT.jar $CONTAINER_NAME:/root/test/
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libdmlc.so.0.6 $CONTAINER_NAME:/root/test/
docker cp /home/ubuntu/go_page_size/java/0718/libxgboost4j/ai_build/libdmlc.so.0 $CONTAINER_NAME:/root/test/

# Make the scripts executable
echo "Making the scripts executable"
docker exec $CONTAINER_NAME chmod +x /root/test/default_jre_jni_install.sh /root/test/default_jre_jni_hello_world_run.sh

# Update package lists
echo "Updating package lists"
docker exec $CONTAINER_NAME apt-get update

# Install wget
echo "Installing wget"
docker exec $CONTAINER_NAME apt-get install -y wget

# Run the JNI installation script
echo "Running the JNI installation script"
docker exec $CONTAINER_NAME bash -c "cd /root/test && ./default_jre_jni_install.sh"

# Run the Hello World script
echo "Running the Hello World script"
docker exec $CONTAINER_NAME bash -c "cd /root/test && ./default_jre_jni_hello_world_run.sh"

# Clean up
echo "Cleaning up"
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo "End-to-end test completed successfully!"
