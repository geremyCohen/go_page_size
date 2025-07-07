# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 && \
sudo update-alternatives --config java && java -version


# 2. Clone and compile XGBoost with JNI bindings
git clone --recursive https://github.com/dmlc/xgboost.git ~/xgboost
git clone https://github.com/geremyCohen/go_page_size.git ~/XGBoostJavaDemo


# Patch so with hello world
# (A) Ensure the source file exists
XCPP=~/xgboost/jvm-packages/xgboost4j/src/native/xgboost4j.cpp
test -f "$XCPP" || { echo "ERROR: $XCPP not found"; exit 1; }

# (B) Prepend a JNI_OnLoad implementation
sed -i '1i\
#include <cstdio>\
#include <unistd.h>\
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) { \
    long page_size = sysconf(_SC_PAGESIZE); \
    printf("my local xgboost! PAGE_SIZE %ld\n", page_size); \
    fflush(stdout); \
    return JNI_VERSION_1_8; \
}\
' "$XCPP"

cd ~/xgboost && mkdir build && cd build && \
cmake .. -DJVM_BINDINGS=ON && make -j$(nproc) && sudo make install && sudo ldconfig && \
cd ~/xgboost/jvm-packages && python3 create_jni.py && \
mvn clean package -DskipTests -Dcheckstyle.skip=true -Dscalastyle.skip=true && \

# 3. Install Java XGBoost jar locally into Maven repository
cd ~/xgboost/jvm-packages && \
mvn install:install-file \
  -Dfile=$(pwd)/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar \
  -DgroupId=ml.dmlc \
  -DartifactId=xgboost4j-local \
  -Dversion=3.1.0-SNAPSHOT \
  -Dpackaging=jar && \

# 4. Explicitly copy compiled JNI library to system library path
sudo cp ~/xgboost/build/lib/libxgboost4j.so /usr/local/lib/ && sudo ldconfig

cd ~/XGBoostJavaDemo
sed -i '/<dependencies>/,/<\/dependencies>/c\
<dependencies>\
    <dependency>\
        <groupId>ml.dmlc</groupId>\
        <artifactId>xgboost4j-local</artifactId>\
        <version>3.1.0-SNAPSHOT</version>\
    </dependency>\
    <dependency>\
        <groupId>commons-logging</groupId>\
        <artifactId>commons-logging</artifactId>\
        <version>1.2</version>\
    </dependency>\
    <dependency>\
        <groupId>com.esotericsoftware</groupId>\
        <artifactId>kryo</artifactId>\
        <version>5.6.0</version>\
    </dependency>\
</dependencies>\
<build>\
    <plugins>\
        <plugin>\
            <groupId>org.codehaus.mojo</groupId>\
            <artifactId>exec-maven-plugin</artifactId>\
            <version>3.1.1</version>\
            <configuration>\
                <executable>java</executable>\
                <arguments>\
                    <argument>-classpath</argument>\
                    <classpath/>\
                    <argument>com.example.XGBoostDemo</argument>\
                </arguments>\
            </configuration>\
        </plugin>\
    </plugins>\
</build>' pom.xml

# 8. Set JNI library visibility permanently
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && source ~/.bashrc && \

# 9. Compile and prepare Java app and its dependencies
cd ~/XGBoostJavaDemo && \
mvn clean compile dependency:copy-dependencies