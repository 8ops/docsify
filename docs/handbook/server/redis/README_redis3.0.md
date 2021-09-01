
1，系统中编译安装3.0.1版本

2，配置 6个端口
7000 ~ 7005
7000 ~ 7002 master（自动分配）
7003 ~ 7005 slave （自动分配）
cat /usr/local/redis/conf/7000.conf

daemonize yes
port 7000
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
dbfilename dump.rdb
dir /data/redis/7000
pidfile /var/run/redis-3.0.1-7000.pid

3，启动 redis node
redis-server /usr/local/redis/conf/7000.conf

4，设置 ruby 环境
ruby >=2.0
yum install ruby rubygems 
gem sources -r https://rubygems.org/
gem sources -a http://ruby.taobao.org/ 
gem install redis --version 3.0.0

5，设置cluster
redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005

6，具体使用 
http://redis.io/documentation

