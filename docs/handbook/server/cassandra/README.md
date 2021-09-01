

1, install

# wget http://mirror.bit.edu.cn/apache/cassandra/3.2/apache-cassandra-3.2-bin.tar.gz
# wget http://uplus.file.youja.cn/tomcat_jdk/jdk-7u75-linux-x64.tar.gz

version
cassandra: 3.2
jdk: 1.8
python: 2.7.11

cd /usr/local/src
wget -O apache-cassandra-2.2.4-bin.tar.gz http://mirror.bit.edu.cn/apache/cassandra/2.2.4/apache-cassandra-2.2.4-bin.tar.gz
tar xzf apache-cassandra-2.2.4-bin.tar.gz
mv apache-cassandra-2.2.4 /usr/local/
ln -s /usr/local/apache-cassandra-2.2.4 /usr/local/cassandra

wget -O jre-8u66-linux-x64.tar.gz "http://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u66-b17/jre-8u66-linux-x64.tar.gz?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u66-b17/jre-8u66-linux-x64.tar.gz&BHost=javadl.sun.com&File=jre-8u66-linux-x64.tar.gz&AuthParam=1453199905_497f3bf4423d22b33b77c9b1a383ff9d&ext=.gz"
tar xzf jre-8u66-linux-x64.tar.gz
mv jre1.8.0_66 /usr/local/
ln -s /usr/local/jre1.8.0_66 /usr/local/jdk

wget http://uplus.file.youja.cn/python/Python-2.7.11.tar.xz
xz -d Python-2.7.11.tar.xz
tar xf Python-2.7.11.tar
cd Python-2.7.11
./configure --prefix=/usr/local/python
make && make install

2, config

cat > /etc/profile.d/cassandra-env.sh <<EOF
export CASSANDRA_HOME=/usr/local/cassandra
export PATH=\${CASSANDRA_HOME}/bin:\$PATH
EOF

cat > /etc/profile.d/jdk-env.sh <<EOF
export JAVA_HOME=/usr/local/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
EOF

cat > /etc/profile.d/python-env.sh <<EOF
export PYTHON_HOME=/usr/local/python
export PATH=$PYTHON_HOME/bin:\$PATH
EOF

. /etc/profile

sudo rm -rf /data/cassandra
sudo mkdir -p /data/cassandra/caches /data/cassandra/data /data/cassandra/logs
sudo chown jesse.jesse -R /usr/local/cassandra /data/cassandra

----
vim conf/cassandra.yaml

cluster_name: 'j_cassandra_cluster'
num_tokens: 256

data_file_directories:
- /data/cassandra/data

commitlog_directory: /data/cassandra/logs

saved_caches_directory: /data/cassandra/caches

seed_provider:
- class_name: org.apache.cassandra.locator.SimpleSeedProvider
  parameters:
      - seeds: "192.168.1.220"
      - seeds: "192.168.1.221"

listen_address: 192.168.1.221

start_rpc: true
rpc_address: 192.168.1.221

endpoint_snitch: SimpleSnitch
----

3，use

nodetool -h 127.0.0.1 -p 7199 info
nodetool ring
nodetool cfstats
nodetool status

cqlsh 192.168.1.220 -k "mykeyspace" -e "desc tables"
cqlsh 192.168.1.220 9042
cqlsh 192.168.1.220
help;
desc keyspaces;
use system_auth;
desc tables;

CREATE KEYSPACE mykeyspace 
 WITH REPLICATION = { 
  'class' : 'SimpleStrategy', 
  'replication_factor' : 1 
};

CREATE TABLE users (
 user_id int PRIMARY KEY,
 fname text,
 lname text
);

INSERT INTO users (user_id,fname,lname)
 VALUES (10000,'fjesse','ljesse');
INSERT INTO users (user_id,fname)
 VALUES (10003,'fjesse');

使用SimpleStrategy策略创建一个新的keyspace，Cassandra里的keyspace对应MySQL里的database的概念，这种策略不会区分不同的数据中心和机架，数据复制份数为2，也就是说同一份数据最多存放在两台机器上：

cqlsh> CREATE KEYSPACE testks
 WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': '2'
};
Cassandra中之前是没有表的概念，之前叫Column Family，现在这个概念逐渐被淡化，像CQL中就直接称作Table，和传统数据库中表是一个意思。但是和传统数据库表的明显区别是必须有主键，因为一个表的数据可能是分布在多个机器上的，Cassandra使用主键来做分区，常用的分区方法有Murmur3Partioner、RandomPartitioner、ByteOrderedPartioner，一般默认使用第一个它的效率和散列性更好。还一个非常让人振奋的特性是列支持List、Set、Map三种集合类型，不仅仅是整形、字符串、日期等基本类型了，这给很多数据存储带来极大方便，比如一个用户帐号对应多个Email地址，或者一个事件对应多个属性等，就可以分别使用List和Map来表示，并且支持对集合的追加操作，这对一些追加的场景就特别方便，比如我们在做Velocity计算时，同一个Key值往往对应多条记录，比如记录一个IP过去3个月所有的登陆信息，就可以放在List中来表示，而不用拆成多条来存储了。创建一个表如下所示：

create table mytab (id text,List<text>) ;

INSERT INTO mytab1 (id) VALUES ("jesse");

desc table mytab;
CREATE TABLE mytab (
  id text,
  values list<text>,
  PRIMARY KEY (id)
) WITH
  bloom_filter_fp_chance=0.010000 AND
  caching='KEYS_ONLY' AND
  comment='' AND
  dclocal_read_repair_chance=0.000000 AND
  gc_grace_seconds=864000 AND
  index_interval=128 AND
  read_repair_chance=0.100000 AND
  replicate_on_write='true' AND
  populate_io_cache_on_flush='false' AND
  default_time_to_live=0 AND
  speculative_retry='99.0PERCENTILE' AND
  memtable_flush_period_in_ms=0 AND
  compaction={'class': 'SizeTieredCompactionStrategy'} AND
  compression={'sstable_compression': 'LZ4Compressor'};
bloom_filter_fp_change：在进行读请求操作时，Cassandra首先到Row Cache中查看缓存中是否有结果，如果没有会看查询的主键是否Bloom filter中，每一个SSTable都对应一个Bloom filter，以便快速确认查询结果在哪个SSTable文件中。但是共所周知，Bloom filter是有一定误差的，这个参数就是设定它的误差率。

caching：是否做Partition Key的缓存，它用来标明实际数据在SSTable中的物理位置。Cassandra的缓存包括Row Cache、Partitioin Key Cache，默认是开启Key Cache，如果内存足够并且有热点数据开启Row Cache会极大提升查询性能，相当于在前面加了一个Memcached。

memtable_flush_period_in_ms：Memtable间隔多长时间把数据刷到磁盘，实际默认情况下Memtable一般是在容量达到一定值之后会被刷到SSTable永久存储。

compaction：数据整理方式，Cassandra进行更新或删除操作时并不是立即对原有的旧数据进行替换或删除，这样会影响读写的性能，而是把这些操作顺序写入到一个新的SSTable中，而在定期在后台进行数据整理，把多个SSTable进行合并整理。合并的策略有SizeTieredCompactionStrategy和LeveledCompactionStrategy两种策略，前者比较适合写操作比较多的情况，后者适合读比较多的情况。

compression：是否对存储的数据进行压缩，一般情况下数据内容都是文本，进行压缩会节省很多磁盘空间，但会稍微消耗一些CPU时间。除了LZ4Compressor这种默认的压缩方式外，还有SnoopyCompressor等压缩方式，这种是Google发明的，号称压缩速度非常快，但压缩比一般。






4, 注意

语句中，字符串的使用只能使用'单引号'



















