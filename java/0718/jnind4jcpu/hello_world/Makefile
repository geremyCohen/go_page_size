JAVA_HOME := $(shell readlink -f /usr/bin/javac | sed "s:/bin/javac::")
BUILD_DIR := build
SRC_DIR := src/main/java
NATIVE_DIR := src/main/native
PACKAGE := com.example.helloworld
PACKAGE_PATH := com/example/helloworld
CLASS_NAME := HelloWorldJNI
CLASS_FILE := $(BUILD_DIR)/$(PACKAGE_PATH)/$(CLASS_NAME).class
HEADER_FILE := $(NATIVE_DIR)/com_example_helloworld_$(CLASS_NAME).h
NATIVE_SRC := $(NATIVE_DIR)/com_example_helloworld_$(CLASS_NAME).c
NATIVE_LIB := $(BUILD_DIR)/lib/libhelloworldjni.so

all: $(CLASS_FILE) $(NATIVE_LIB)

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

run: all
	java -Djava.library.path=$(BUILD_DIR)/lib -cp $(BUILD_DIR) $(PACKAGE).$(CLASS_NAME)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
