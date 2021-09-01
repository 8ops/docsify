
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# env jdk1.6
export JAVA_HOME=/usr/local/jdk1.6.0_27
#export JAVA_HOME=/usr/local/jdk1.7.0_60
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:%JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

# env hadoop
export HADOOP_HOME=/usr/local/hadoop/hadoop-2.2.0
export PATH=$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
export HADOOP_HOME_WARN_SUPPRESS=1

# env zookeeper
export ZOOKEEPER_HOME=/usr/local/hadoop/zookeeper-3.4.6
export BOOKKEEPER_HOME=/usr/local/bookkeeper-server-4.2.3
export PATH=$ZOOKEEPER_HOME/bin:$BOOKKEEPER_HOME/bin:$PATH

# env hbase
export HBASE_HOME=/usr/local/hadoop/hbase-0.96.2-hadoop2
export PATH=$HBASE_HOME/bin:$PATH


