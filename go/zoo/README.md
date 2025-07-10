git clone https://github.com/apache/zookeeper.git
cd zookeeper
sudo apt-get install openjdk-11-jdk
sudo update-alternatives --config java  # choose Java 11

# grab path for java home from above (minus bin/java part)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
mvn clean install -DskipTests

cd zookeeper-assembly/target
tar -xzf apache-zookeeper-*-bin.tar.gz
cd apache-zookeeper-*-bin

cp conf/zoo_sample.cfg conf/zoo.cfg
dataDir=/tmp/zookeeper
mkdir -p /tmp/zookeeper
bin/zkServer.sh start
bin/zkServer.sh status

## Test with CLI
bin/zkCli.sh
create /hello "Hello ZooKeeper"
get /hello
