
step 1: 下载安装包及环境安装

cd /usr/local/src
wget http://uplus.file.youja.cn/tomcat_jdk/jdk-6u27-linux-x64.bin
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
wget http://apache.fayea.com//kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz

./jdk-6u27-linux-x64.bin
tar xvzf zookeeper-3.4.6.tar.gz
tar xvzf kafka_2.11-0.8.2.1.tgz
mv jdk1.6.0_37 /usr/local/
mv zookeeper-3.4.6 /usr/local/
mv kafka_2.11-0.8.2.1 /usr/local/
ln -s jdk1.6.0_37 jdk
ln -s kafka_2.11-0.8.2.1 kafka
ln -s zookeeper-3.4.6 zookeeper

cat > /etc/profile.d/jdk-env.sh <<EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
EOF

cat > /etc/profile.d/zookeeper-env.sh <<EOF
export ZOOKEEPER_HOME=/usr/local/zookeeper
export PATH=\$ZOOKEEPER_HOME/bin:\$PATH
EOF

cat > /etc/profile.d/kafka-env.sh <<EOF
export KAFKA_HOME=/usr/local/kafka
export PATH=\$KAFKA_HOME/bin:\$PATH
EOF

. /etc/profile
echo $PATH

step 2: zookeeper环境启动（测试期仅启动一台，集群至少3台顺序启动）

rm -f zookeeper.out
rm -rf /data/zookeeper
mkdir -p /data/zookeeper/data /data/zookeeper/logs

echo 1 > /data/zookeeper/data/myid
echo 2 > /data/zookeeper/data/myid
echo 3 > /data/zookeeper/data/myid

cat > /usr/local/zookeeper/conf/zoo_kafka.cfg <<EOF
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
clientPort=2181
tickTime=2000
initLimit=5
syncLimit=2
server.1=192.168.1.219:2888:3888
server.2=192.168.1.220:2888:3888
server.3=192.168.1.221:2888:3888

EOF

/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo_kafka.cfg

step 3: kafka配置及启动

>>>>>
vi bin/kafka-run-class.sh  
...
KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true"  
...
# 若32bit就去掉 -XX:+UseCompressedOops
<<<<<

mkdir -p /data/kafka/logs /data/kafka/metrics

cat > /usr/local/kafka/config/kafka_server.properties <<EOF
# 1,2,3
broker.id=1
port=9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dir=/data/kafka/logs
num.partitions=3
log.flush.interval.messages=10000
log.flush.interval.ms=1000
log.retention.hours=24
log.retention.bytes=1073741824
log.segment.bytes=536870912
num.replica.fetchers=2
log.cleanup.interval.mins=10
zookeeper.connect=192.168.1.219:2181,192.168.1.220:2181,192.168.1.221:2181
zookeeper.connection.timeout.ms=1000000
kafka.metrics.polling.interval.secs=5
kafka.metrics.reporters=kafka.metrics.KafkaCSVMetricsReporter
kafka.csv.metrics.dir=/data/kafka/metrics
kafka.csv.metrics.reporter.enabled=false

EOF

# start server
/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/kafka_server.properties

step 4: use

# default config
#/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties 

# test console producer
kafka-console-producer.sh --broker-list localhost:9092 --topic test
kafka-console-producer.sh --broker-list 192.168.1.220:9092 --topic test

# test console consumer
kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning
kafka-console-consumer.sh --zookeeper 192.168.1.220:2181 --topic test --from-beginning # 从头拉消息
kafka-console-consumer.sh --zookeeper 192.168.1.220:2181 --topic test # 即时收取消息

# general use
kafka-topics.sh --create   --zookeeper localhost:2181 --topic t1
kafka-topics.sh --delete   --zookeeper localhost:2181 --topic t1
kafka-topics.sh --describe --zookeeper localhost:2181 --topic t1
kafka-topics.sh --list --zookeeper localhost:2181

kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic t1
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 2 --topic t2
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 3 --topic t3



