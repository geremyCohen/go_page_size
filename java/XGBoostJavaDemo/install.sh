# git clone https://github.com/geremyCohen/go_page_size.git ~/XGBoostJavaDemo

# 1. Install system packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev git apt-transport-https ca-certificates gnupg

sudo update-alternatives --config java && java -version

# 2. Clone and compile XGBoost with JNI bindings
cd
git clone --recursive https://github.com/dmlc/xgboost.git ~/xgboost

# Patch so with hello world
# 1) Point at your JNI source file
XCPP=~/xgboost/jvm-packages/xgboost4j/src/native/xgboost4j.cpp

# 2) Insert the headers immediately after the xgboost4j.h include (line 16)
sed -i '16a#include <cstdio>'   "$XCPP"
sed -i '17a#include <unistd.h>' "$XCPP"

# 3) Inject your print lines immediately after 'GlobalJvm() = vm;'
#    (that assignment is on its own line; we’ll append after it)
sed -i '/GlobalJvm() = vm;/a\
    long page_size = sysconf(_SC_PAGESIZE);\
    printf("my local xgboost! PAGE_SIZE %ld\\n", page_size);\
    fflush(stdout);' "$XCPP"

cd ~/xgboost && mkdir -p build && cd build && \
cmake .. -DJVM_BINDINGS=ON && make -j$(nproc) && sudo make install && sudo ldconfig && \
cd ~/xgboost/jvm-packages && python3 create_jni.py && \
mvn clean package -DskipTests -Dcheckstyle.skip=true -Dscalastyle.skip=true

# 3. Install Java XGBoost jar locally into Maven repository
cd ~/xgboost/jvm-packages && \
mvn install:install-file \
  -Dfile=$(pwd)/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar \
  -DgroupId=ml.dmlc \
  -DartifactId=xgboost4j-local \
  -Dversion=3.1.0-SNAPSHOT \
  -Dpackaging=jar && \

# 4. Explicitly copy compiled JNI library to system library path
sudo cp ~/xgboost/lib/libxgboost4j.so /usr/local/lib/ && sudo ldconfig

cd ~/XGBoostJavaDemo/examples/java/XGBoostJavaDemo
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
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && source ~/.bashrc

# 9. Compile and prepare Java app and its dependencies
mvn clean compile dependency:copy-dependencies

# run it
java -cp "target/classes:target/dependency/*" com.example.XGBoostDemo
# sudo lsof -p $(pgrep -f com.example.XGBoostDemo) | grep libxgboost4j.so
