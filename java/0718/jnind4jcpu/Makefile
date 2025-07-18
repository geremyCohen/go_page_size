JAVA_HOME := $(shell readlink -f /usr/bin/javac | sed "s:/bin/javac::")
BUILD_DIR := ai_build
SRC_DIR := src/main/java
NATIVE_DIR := src/main/native
PACKAGE := com.example.jni
PACKAGE_PATH := com/example/jni
CLASS_NAME := CPUInfo
CLASS_FILE := $(BUILD_DIR)/$(PACKAGE_PATH)/$(CLASS_NAME).class
HEADER_FILE := $(NATIVE_DIR)/com_example_jni_$(CLASS_NAME).h
NATIVE_SRC := $(NATIVE_DIR)/com_example_jni_$(CLASS_NAME).c
NATIVE_LIB := $(BUILD_DIR)/lib/libcpuinfo.so
JAR_FILE := $(BUILD_DIR)/jnind4jcpu.jar

all: $(JAR_FILE) $(NATIVE_LIB)

$(BUILD_DIR)/$(PACKAGE_PATH)/%.class: $(SRC_DIR)/$(PACKAGE_PATH)/%.java
	@mkdir -p $(BUILD_DIR)/$(PACKAGE_PATH)
	javac -d $(BUILD_DIR) $<

$(HEADER_FILE): $(CLASS_FILE)
	@mkdir -p $(NATIVE_DIR)
	javac -h $(NATIVE_DIR) -d $(BUILD_DIR) $(SRC_DIR)/$(PACKAGE_PATH)/$(CLASS_NAME).java

$(NATIVE_LIB): $(NATIVE_SRC) $(HEADER_FILE)
	@mkdir -p $(BUILD_DIR)/lib
	gcc -shared -fPIC -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux \
		-o $@ $(NATIVE_SRC)

$(JAR_FILE): $(CLASS_FILE)
	@mkdir -p $(BUILD_DIR)
	jar cf $@ -C $(BUILD_DIR) .

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
