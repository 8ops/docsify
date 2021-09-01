


================================================================================
整合搭建 hdfs/zookeeper/bookkeeper/hbase/flume/stome
================================================================================

一，基础环境准备

ps: 需要在每一台机器上做此操作

以 root 用户先在每台机器上操作

1，DNS 解析

192.168.1.235       nn01.hadoop.youja.cn zk01.hadoop.youja.cn 
192.168.1.236       sn01.hadoop.youja.cn zk02.hadoop.youja.cn
192.168.1.237       dn01.hadoop.youja.cn zk03.hadoop.youja.cn
192.168.1.238       dn02.hadoop.youja.cn zk04.hadoop.youja.cn
192.168.1.239       dn03.hadoop.youja.cn zk05.hadoop.youja.cn

192.168.1.220       bn01.hadoop.youja.cn

2，更改每台机器 hostname

vim /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=nn01.hadoop.youja.cn

3，创建用户并埋key

useradd -m -G sshuser hadoop

mkdir /home/hadoop/.ssh
chmod 700 /home/hadoop/.ssh

vim /home/hadoop/.ssh/id_dsa
-----BEGIN DSA PRIVATE KEY-----
MIIBvAIBAAKBgQDWWwKgd8fbTJJvxqHghBMRac6kZHbvJpaBB+yY8cqzHukNOVN6
gCtN5gXvGo1GGBP7Mnz/4DwcgyCSwjBWiZrCgtjm3gwj69tuNMkgEatCteUsYplv
LCrL2BDUvAGIj+kxafvCwdZcuEm1Ytgks5VRpE/yBF2lp/8ARWr+EDnBQwIVALmu
4+axCWYHw8cVtEMJhcV9EaQ7AoGBAMncFL+ZXn7KWe9tiCrKqjTXomPSr+0+5YVk
E1yd/YUgoytkQheQ0oCBLgzmt8dCindWhMPQs4A+FAO3AgNpHfPIDVr9MLPcAhtG
HQy6kx5CVAYfK6A/cJkBpgUYczWOniealJWdqN8EVza60x8ekLkCuhi0OjNJIiQj
CPE1GlXxAoGBAJbA969PnhmOm9T3h2aUhNDXuA3yyc9Gg3dpySKelGTsVsuNip86
gx7z3Yder4R1jgiQFTdFLrd1e6P4V5WJ4eG3Ibxwbu95yceSWCLpKckgBNjnF/6L
5vCwGKp3wjXrE1P856gfFLNvbYWN/hkV6vbgPitGzTK0fXunV4esvtGqAhQ5G1Sg
To2sKaGMpzmz0DfktK1QcA==
-----END DSA PRIVATE KEY-----

vim /home/hadoop/.ssh/authorized_keys
ssh-dss AAAAB3NzaC1kc3MAAACBANZbAqB3x9tMkm/GoeCEExFpzqRkdu8mloEH7JjxyrMe6Q05U3qAK03mBe8ajUYYE/syfP/gPByDIJLCMFaJmsKC2ObeDCPr2240ySARq0K15SximW8sKsvYENS8AYiP6TFp+8LB1ly4SbVi2CSzlVGkT/IEXaWn/wBFav4QOcFDAAAAFQC5ruPmsQlmB8PHFbRDCYXFfRGkOwAAAIEAydwUv5lefspZ722IKsqqNNeiY9Kv7T7lhWQTXJ39hSCjK2RCF5DSgIEuDOa3x0KKd1aEw9CzgD4UA7cCA2kd88gNWv0ws9wCG0YdDLqTHkJUBh8roD9wmQGmBRhzNY6eJ5qUlZ2o3wRXNrrTHx6QuQK6GLQ6M0kiJCMI8TUaVfEAAACBAJbA969PnhmOm9T3h2aUhNDXuA3yyc9Gg3dpySKelGTsVsuNip86gx7z3Yder4R1jgiQFTdFLrd1e6P4V5WJ4eG3Ibxwbu95yceSWCLpKckgBNjnF/6L5vCwGKp3wjXrE1P856gfFLNvbYWN/hkV6vbgPitGzTK0fXunV4esvtGq hadoop@master.hadoop.youja.cn

chown -R hadoop.hadoop /home/hadoop/.ssh
chmod 600 /home/hadoop/.ssh/id_dsa
chmod 600 /home/hadoop/.ssh/authorized_keys
ls -l /home/hadoop/.ssh

echo "hadoop^2014" | passwd hadoop --stdin

4，创建目录并授权给 hadoop

mkdir -p /data/hadoop /data/zookeeper
chown -R hadoop.hadoop /data/hadoop /data/zookeeper

cd /usr/local
mkdir -p jdk1.6.0_27 hadoop-2.2.0 zookeeper-3.4.6 bookkeeper-server-4.2.3  hbase-0.96.2-hadoop2
ln -s jdk1.6.0_27 jdk
ln -s hadoop-2.2.0 hadoop
ln -s zookeeper-3.4.6 zookeeper
ln -s bookkeeper-server-4.2.3 bookkeeper
ln -s hbase-0.96.2-hadoop2 hbase
chown -R hadoop.hadoop jdk1.6.0_27 hadoop-2.2.0 zookeeper-3.4.6 bookkeeper-server-4.2.3  hbase-0.96.2-hadoop2 jdk hadoop zookeeper bookkeeper hbase

5，环境配置

vim /etc/profile.d/hadoop-env.sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# env jdk1.6
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:%JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

# env hadoop
export HADOOP_HOME=/usr/local/hadoop
export PATH=$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
export HADOOP_HOME_WARN_SUPPRESS=1

# env zookeeper
export ZOOKEEPER_HOME=/usr/local/zookeeper
export BOOKKEEPER_HOME=/usr/local/bookkeeper
export PATH=$ZOOKEEPER_HOME/bin:$BOOKKEEPER_HOME/bin:$PATH

# env hbase
export HBASE_HOME=/usr/local/hbase
export PATH=$HBASE_HOME/bin:$PATH

6，ntp 设置

echo "0 1 1 * * /usr/sbin/ntpdate -u ntp.uplus.youja.cn" > /var/spool/cron/root


7，生成~/known_hosts信息

su hadoop 

for host in nn01.hadoop.youja.cn sn01.hadoop.youja.cn dn01.hadoop.youja.cn dn02.hadoop.youja.cn dn03.hadoop.youja.cn
do
    echo "====> $host"
    ssh -p 50022 hadoop@$host "date"
done

for i in {1..5}
do
    host=zk0$i.hadoop.youja.cn
    echo "====> $host"
    ssh -p 50022 hadoop@$host "date"
done


二，软件安装　

ps: 只需要在一台机器上安装，然后同步至其它机器。在一台机器上同步配置至其它机器并启动和停止

su hadoop

1，对应版本
jdk1.6.0_27
hadoop-2.2.0
zookeeper-3.4.6
bookkeeper-server-4.2.3
hbase-0.96.2-hadoop2

2，下载并安装

cd /usr/local/src
wget http://file.uplus.youja.cn/maven%2beclipse/jdk-6u27-linux-x64.bin
wget http://file.uplus.youja.cn/hadoop/hadoop-centos6.4-x64-2.2.0.tar.gz
wget http://file.uplus.youja.cn/hadoop/zookeeper/zookeeper-3.4.6.tar.gz
wget http://file.uplus.youja.cn/hadoop/zookeeper/bookkeeper-server-4.2.3-bin.tar.gz
wget http://file.uplus.youja.cn/hadoop/hbase/hbase-0.96.2-hadoop2-bin.tar.gz

chmod +x jdk-6u27-linux-x64.bin
./jdk-6u27-linux-x64.bin
tar xvzf hadoop-centos6.4-x64-2.2.0.tar.gz 
tar xvzf zookeeper-3.4.6.tar.gz
tar xvzf bookkeeper-server-4.2.3-bin.tar.gz
tar xvzf hbase-0.96.2-hadoop2-bin.tar.gz

rsync -rtlv jdk1.6.0_27/ /usr/local/jdk1.6.0_27/
rsync -rtlv hadoop-2.2.0/ /usr/local/hadoop-2.2.0/
rsync -rtlv zookeeper-3.4.6/ /usr/local/zookeeper-3.4.6/
rsync -rtlv bookkeeper-server-4.2.3/ /usr/local/bookkeeper-server-4.2.3/
rsync -rtlv hbase-0.96.2-hadoop2/ /usr/local/hbase-0.96.2-hadoop2

3，修改 hdfs 配置

vim /usr/local/hadoop/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://nn01.hadoop.youja.cn:9000</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/data/hadoop/hdfs/temp</value>
  </property>
  <property>
    <name>fs.checkpoint.dir</name>
    <value>/data/hadoop/hdfs/name,/data/hadoop/hdfs/2ndname</value> 
  </property>
  <property>
    <name>fs.checkpoint.period</name>
    <value>600</value>
  </property>
  <property>
    <name>fs.checkpoint.size</name>
    <value>67108864</value>
  </property>
</configuration>


vim /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <property>
    <name>dfs.permissions</name>
    <value>true</value>
  </property>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.name.dir</name>
    <value>/data/hadoop/hdfs/name,/data/hadoop/hdfs/2ndname</value>
  </property>
  <property>
    <name>dfs.data.dir</name>
    <value>/data/hadoop/hdfs/data</value>
  </property>
  <property>
    <name>dfs.secondary.http.address</name>
    <value>sn01.hadoop.youja.cn:50090</value>
  </property>
  <property>
    <name>dfs.http.address</name>
    <value>nn01.hadoop.youja.cn:50070</value>
  </property>
</configuration>


vim /usr/local/hadoop/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <property>
    <name>mapred.job.tracker</name>
    <value>hdfs://nn01.hadoop.youja.cn:9001</value>
  </property>
</configuration>


vim /usr/local/hadoop/etc/hadoop/masters
nn01.hadoop.youja.cn

vim /usr/local/hadoop/etc/hadoop/slaves
dn01.hadoop.youja.cn
dn02.hadoop.youja.cn
dn03.hadoop.youja.cn

vim /usr/local/hadoop/etc/hadoop/hadoop-env.sh

...

# Extra ssh options.  Empty by default.
export HADOOP_SSH_OPTS="-p 50022 -o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

# map reduce slow
export HADOOP_HEAPSIZE=4000


4，修改 zookeeper 配置

vim /usr/local/zookeeper/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/log

clientPort=2181

server.1=zk01.hadoop.youja.cn:2888:3888
server.2=zk02.hadoop.youja.cn:2888:3888
server.3=zk03.hadoop.youja.cn:2888:3888
server.4=zk04.hadoop.youja.cn:2888:3888
server.5=zk05.hadoop.youja.cn:2888:3888


X 5，修改 bookkeeper 配置

vim /usr/local/bookkeeper/conf/bk_server.conf 
#!/bin/sh

bookiePort=3181

journalDirectory=/data/hadoop/zookeeper/bookkeeper/bk-txn
ledgerDirectories=/data/hadoop/zookeeper/bookkeeper/bk-data
zkLedgersRootPath=/ledgers
flushInterval=100
zkServers=zk01.hadoop.youja.cn:2181,zk02.hadoop.youja.cn:2181,zk03.hadoop.youja.cn:2181,zk04.hadoop.youja.cn:2181,zk05.hadoop.youja.cn
zkTimeout=10000
serverTcpNoDelay=true

6，修改 hbase 配置

vim /usr/local/hbase/conf/hbase-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://nn01.hadoop.youja.cn:9000/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>zk01.hadoop.youja.cn:2181,zk02.hadoop.youja.cn:2181,zk03.hadoop.youja.cn:2181,zk04.hadoop.youja.cn:2181,zk05.hadoop.youja.cn</value>
  </property>
</configuration>

vim /usr/local/hbase/conf/regionservers
dn01.hadoop.youja.cn 
dn02.hadoop.youja.cn 
dn03.hadoop.youja.cn

vim /usr/local/hbase/conf/hbase-env.sh

...

# Extra ssh options.  Empty by default.
export HBASE_SSH_OPTS="-p 50022 -o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

vim /usr/local/hadoop/libexec/hadoop-config.sh

...

if [ "$HADOOP_CLASSPATH" != "" ]; then
  # add for balaamwe
  HBASE_CLASSPATH=$HBASE_HOME/lib/* 
  # Prefix it if its to be preceded
  if [ "$HADOOP_USER_CLASSPATH_FIRST" != "" ]; then
    CLASSPATH=${HADOOP_CLASSPATH}:${CLASSPATH}:$HBASE_CLASSPATH
  else
    CLASSPATH=${CLASSPATH}:${HADOOP_CLASSPATH}:$HBASE_CLASSPATH
  fi
fi

rm -f /usr/local/hbase-0.96.2-hadoop2/lib/slf4j-log4j12-1.6.4.jar

7，同步程序和目录结构至其它机器

rm -f /usr/local/hbase/lib/jasper-runtime-5.5.23.jar
rm -f /usr/local/hadoop/share/hadoop/common/lib/jasper-runtime-5.5.23.jar
rm -f /usr/local/hadoop/share/hadoop/hdfs/lib/jasper-runtime-5.5.23.jar
rm -f /usr/local/hbase/lib/jasper-compiler-5.5.23.jar
rm -f /usr/local/hadoop/share/hadoop/common/lib/jasper-compiler-5.5.23.jar
wget -O /usr/local/hbase/lib/jasper-runtime-5.5.12.jar http://file.uplus.youja.cn/hadoop/jasper-runtime-5.5.12.jar
wget -O /usr/local/hadoop/share/hadoop/common/lib/jasper-runtime-5.5.12.jar http://file.uplus.youja.cn/hadoop/jasper-runtime-5.5.12.jar
wget -O /usr/local/hadoop/share/hadoop/hdfs/lib/jasper-runtime-5.5.12.jar http://file.uplus.youja.cn/hadoop/jasper-runtime-5.5.12.jar
wget -O /usr/local/hbase/lib/jasper-compiler-5.5.12.jar http://file.uplus.youja.cn/hadoop/jasper-compiler-5.5.12.jar
wget -O /usr/local/hadoop/share/hadoop/common/lib/jasper-compiler-5.5.12.jar http://file.uplus.youja.cn/hadoop/jasper-compiler-5.5.12.jar

for i in {1..5}
do
    host=zk0$i.hadoop.youja.cn
    echo "====> $host"
    ssh -p 50022 hadoop@$host "mkdir -p /data/hadoop/hdfs/{name,2ndname,data,temp};mkdir -p /data/zookeeper/{data,log,bookkeeper}"
    rsync -rtlv --delete -e "ssh -p 50022" --exclude "*/logs" /usr/local/jdk/ hadoop@$host:/usr/local/jdk/
    rsync -rtlv --delete -e "ssh -p 50022" --exclude "*/logs" /usr/local/hadoop/ hadoop@$host:/usr/local/hadoop/
    rsync -rtlv --delete -e "ssh -p 50022" --exclude "*/logs" /usr/local/zookeeper/ hadoop@$host:/usr/local/zookeeper/
    rsync -rtlv --delete -e "ssh -p 50022" --exclude "*/logs" /usr/local/hbase/ hadoop@$host:/usr/local/hbase/
done

配置过程中修复

for i in {1..5}
do
    host=zk0$i.hadoop.youja.cn
    echo "====> $host"
    
    ssh -p 50022 hadoop@$host "killall java;"
    ssh -p 50022 hadoop@$host "rm -rf /usr/local/hadoop/logs;rm -rf /usr/local/hbase/logs;rm -rf /tmp/*;rm -rf /data/hadoop/*;rm -rf /data/zookeeper/*"
    ssh -p 50022 hadoop@$host "mkdir -p /data/hadoop/hdfs/{name,2ndname,data,temp};mkdir -p /data/zookeeper/{data,log,bookkeeper}"
    
    #ssh -p 50022 hadoop@$host "tree /data"
    #ssh -p 50022 hadoop@$host "netstat -nutlp"
done


三，启动

1，hdfs 

格式化

hadoop namenode -format

启动／停止

start-all.sh
stop-all.sh

2，zookeeper

for i in {1..5}
do
    host=zk0$i.hadoop.youja.cn
    echo "====> $host"
    
    #ssh -p 50022 hadoop@$host "/usr/local/zookeeper/bin/zkServer.sh stop /usr/local/zookeeper/conf/zoo.cfg"
    #ssh -p 50022 hadoop@$host "rm -f /data/zookeeper/data/zookeeper_server.pid"
    
    #ssh -p 50022 hadoop@$host "echo \"$i\" >  /data/zookeeper/data/myid"
    ssh -p 50022 hadoop@$host "/usr/local/zookeeper/bin/zkServer.sh start /usr/local/zookeeper/conf/zoo.cfg"
    
    #ssh -p 50022 hadoop@$host "tree /data/zookeeper"
done

X 3，bookkeeper

zkCli.sh -server zk01.hadoop.youja.cn
create /ledgers bookkeeper
create /ledgers/available bookkeeper

for i in {1..5}
do
    host=zk0$i.hadoop.youja.cn
    echo "====> $host"
    
    #ssh -p 50022 hadoop@$host "bookkeeper-daemon.sh start bookie"
    ssh -p 50022 hadoop@$host "bookkeeper-daemon.sh stop bookie"
done

4，hbase

start-hbase.sh
stop-hbase.sh


四，使用测试

1，查看当前运行进程

watch jps

2，hadoop 使用

tree /data/hadoop

hadoop fs -mkdir /test
hadoop fs -put /etc/service /test/
hadoop fs -copyFromLocal /etc/ssh/ssh_config /test/txt002.txt

hadoop dfsadmin -report

http://nn01.hadoop.youja.cn:50070/dfshealth.jsp

3，zookeeper 使用

zkCli.sh -server zk01.hadoop.youja.cn

4，hbase 使用

hbase shell
create 'test','cf'
put 'test','row1','cf:a','value1'
put 'test','row2','cf:b','value2'
put 'test','row3','cf:c','value3'
scan 'test'
get 'test','row1'
disable 'test'
drop 'test'

http://nn01.hadoop.youja.cn:60010

hbase zkcli -server nn01.hadoop.youja.cn:2181

--------------------------------------------------------------------------------

问题集锦

1，启动与停止，重启的顺序

启动　hdfs --> zookeeper --> bookkeeper --> hbase

停止　hbase --> bookkeeper --> zookeeper --> hdfs

重启　停止 --> 启动

2，jar 版本替换（遇到namenode datanode 启不来，报jar notsuchfileerror is_security_enabled）

/usr/local/hbase/lib/jasper-runtime-5.5.23.jar
/usr/local/hadoop/share/hadoop/common/lib/jasper-runtime-5.5.23.jar
/usr/local/hadoop/share/hadoop/hdfs/lib/jasper-runtime-5.5.23.jar

/usr/local/hbase/lib/jasper-compiler-5.5.23.jar
/usr/local/hadoop/share/hadoop/common/lib/jasper-compiler-5.5.23.jar

替换为
jasper-compiler-5.5.12.jar
jasper-runtime-5.5.12.jar

3，运行脚本的时候报out of memory

vim hadoop-env.sh

export HADOOP_CLIENT_OPTS="-Xmx1024m $HADOOP_CLIENT_OPTS"



--------------------------------------------------------------------------------

整理数据

create 'YoujaData','unumber','retention','action'
scan 'YoujaData'
put 'YoujaData','2014-07-01','unumber:device','6786787'


echo "list" | hbase shell

================================================================================

三，追加安装Flume

cd /usr/local/src
wget http://file.uplus.youja.cn/hadoop/apache-flume-1.5.0.1-bin.tar.gz
tar xvzf apache-flume-1.5.0.1-bin.tar.gz -C /usr/local/
ln -s /usr/local/apache-flume-1.5.0.1-bin /usr/local/flume
chown -R hadoop.hadoop /usr/local/apache-flume-1.5.0.1-bin /usr/local/flume

vim /etc/profile.d/hadoop-env.sh

...

#JAVA_OPTS="-server -Xms4096m -Xmx4096m -Xmn2g -XX:SurvivorRatio=6 -XX:PermSize=256M -XX:MaxPermSize=256m -Xss160k -XX:GCTimeRatio=19 -XX:+DisableExplicitGC -Xnoclassgc -XX:MaxTenuringThreshold=7 -XX:ParallelGCThreads=5 -XX:+UseParNewGC -XX:MaxGCPauseMillis=100 -XX:+UseConcMarkSweepGC -XX:CMSFullGCsBeforeCompaction=5"

# env flume
export FLUME_HOME=/usr/local/flume
export FLUME_CONF_DIR=$FLUME_HOME/conf
export PATH=$FLUME_HOME/bin:$PATH














































