# Install required packages
sudo apt update && sudo apt install -y openjdk-17-jdk maven git cmake build-essential python3 && \
sudo update-alternatives --config java && java -version && \

# Clone and build XGBoost with JNI bindings
git clone --recursive https://github.com/dmlc/xgboost.git ~/xgboost && \
cd ~/xgboost && mkdir build && cd build && \
cmake .. -DJVM_BINDINGS=ON && make -j$(nproc) && sudo make install && sudo ldconfig && \
cd ~/xgboost/jvm-packages && python3 create_jni.py && \
mvn clean package -DskipTests -Dcheckstyle.skip=true -Dscalastyle.skip=true && \

# Install XGBoost Java JAR to local Maven repo
mvn install:install-file \
  -Dfile=$(pwd)/xgboost4j/target/xgboost4j_2.12-3.1.0-SNAPSHOT.jar \
  -DgroupId=ml.dmlc \
  -DartifactId=xgboost4j-local \
  -Dversion=3.1.0-SNAPSHOT \
  -Dpackaging=jar && \

# Unzip Java app (ensure XGBoostJavaDemo.zip is in home directory)
cd ~ && unzip XGBoostJavaDemo.zip -d XGBoostJavaDemo && \

# Automatically update pom.xml in your Java project
cd ~/XGBoostJavaDemo && \
sed -i '/<dependencies>/,/<\/dependencies>/c\
<dependencies>\
    <dependency>\
        <groupId>ml.dmlc</groupId>\
        <artifactId>xgboost4j-local</artifactId>\
        <version>3.1.0-SNAPSHOT</version>\
    </dependency>\
</dependencies>' pom.xml && \

# Configure JNI library path permanently
echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc && \
source ~/.bashrc && \

# Compile and run your Java application
mvn clean compile exec:java