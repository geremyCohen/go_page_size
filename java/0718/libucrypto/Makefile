# Makefile for libucrypto JNI library

# Directories
BUILD_DIR = ../ai_build
SRC_DIR = src/main/java
NATIVE_DIR = src/main/native
CLASSES_DIR = $(BUILD_DIR)/classes
LIB_DIR = $(BUILD_DIR)/lib

# Java compiler and flags
JAVAC = javac
JAVAC_FLAGS = -d $(CLASSES_DIR)

# C++ compiler and flags
CXX = g++
CXXFLAGS = -fPIC -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux -std=c++11 -Wall

# JNI library name
LIB_NAME = libucrypto.so

# Java package and class
PACKAGE = com.ucrypto
JAVA_FILES = $(SRC_DIR)/com/ucrypto/UCrypto.java
CLASS_NAME = UCrypto

# Default target
all: $(LIB_DIR)/$(LIB_NAME) $(LIB_DIR)/ucrypto.jar

# Create directories
$(CLASSES_DIR) $(LIB_DIR):
	mkdir -p $@

# Compile Java classes
$(CLASSES_DIR)/com/ucrypto/$(CLASS_NAME).class: $(JAVA_FILES) | $(CLASSES_DIR)
	$(JAVAC) $(JAVAC_FLAGS) $<

# Generate JNI header
$(NATIVE_DIR)/com_ucrypto_UCrypto.h: $(CLASSES_DIR)/com/ucrypto/$(CLASS_NAME).class
	javah -jni -classpath $(CLASSES_DIR) -d $(NATIVE_DIR) $(PACKAGE).$(CLASS_NAME)

# Compile JNI library
$(LIB_DIR)/$(LIB_NAME): $(NATIVE_DIR)/ucrypto.cpp $(NATIVE_DIR)/com_ucrypto_UCrypto.h | $(LIB_DIR)
	$(CXX) $(CXXFLAGS) -shared -o $@ $(NATIVE_DIR)/ucrypto.cpp

# Create JAR file
$(LIB_DIR)/ucrypto.jar: $(CLASSES_DIR)/com/ucrypto/$(CLASS_NAME).class | $(LIB_DIR)
	jar cf $@ -C $(CLASSES_DIR) .

# Clean target
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
