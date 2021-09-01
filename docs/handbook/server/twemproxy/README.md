
==twemproxy安装与使用

1，编译安装

参考：https://github.com/twitter/twemproxy

autoconf下载地址：http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
twemproxy下载地址：https://github.com/twitter/twemproxy/archive/v0.3.0.tar.gz

twemproxy的安装要求autoconf的版本在2.64以上，否则提示”error: Autoconf version 2.64 or higher is required“
autoconf直接make和make install即可

tar xvzf autoconf-2.69.tar.gz
cd autoconf
./configure --prefix=/usr/local/autoconf
make
make install

vim /etc/profile.d/autoconf-env.sh
export AUTOCONF_HOME=/usr/local/autoconf
export PATH=$AUTOCONF_HOME/bin:$PATH

. /etc/profile

yum install -y automake.noarch
yum install -y libtool.x86_64

tar xvzf v0.3.0.tar.gz
cd twemproxy
autoreconf -fvi (or autoconfig)
./configure --prefix=/usr/local/twemproxy
make -j 8
make install

vim /etc/profile.d/twemproxy-env.sh
export TWEMPROXY_HOME=/usr/local/twemproxy
export PATH=$TWEMPROXY_HOME/sbin:$PATH

. /etc/profile

2，配置

cd /usr/local/twemproxy
mkdir run conf

vim conf/nutcracker.yml
alpha:
  listen: 192.168.1.206:22120
  redis: true
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  timeout: 400
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:
   - 192.168.1.206:6379:1
   - 192.168.1.206:6380:1
   - 192.168.1.206:6381:1

b1:
  listen: 0.0.0.0:22121
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  server_failure_limit: 1
  servers:
   - 192.168.1.206:6379:1

b2:
  listen: 0.0.0.0:22122
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  server_failure_limit: 1
  servers:
   - 192.168.1.206:6380:1
   - 192.168.1.206:6381:1

b3:
  listen: 0.0.0.0:22123
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  server_failure_limit: 1
  servers:
   - 192.168.1.206:6379:1
   - 192.168.1.206:6380:1
   - 192.168.1.206:6381:1
   
t1:
  listen: 0.0.0.0:23001
  redis: true
  hash: fnv1a_64
  distribution: ketama #ketama, modula, random
  auto_eject_hosts: true
  timeout: 400
  preconnect: true
  server_connections: 20
  server_retry_timeout: 2000
  server_failure_limit: 3
  servers:
   - 192.168.1.206:6407:1
   - 192.168.1.206:6408:1
   - 192.168.1.206:6409:1
   - 192.168.1.206:6410:1
   
3，测试配置并启动

nutcracker -t 测试配置文件
/usr/local/twemproxy/sbin/nutcracker -d -c /usr/local/twemproxy/conf/nutcracker.yml -p /usr/local/twemproxy/run/redisproxy.pid -o /usr/local/twemproxy/run/redisproxy.log


4，使用

redis-cli -h 192.168.1.206 -p 22121

5，压力对比

redis-benchmark -h 192.168.1.206 -p 6379 set name jesse -n 1000 -c 10 -q
redis-benchmark -h 192.168.1.206 -p 22121 set name jesse -n 1000 -c 10 -q


6，问题

twemproxy 后

aof文件读取不支持
pipe方式支持不友好
get失败后会保持连接
不支持多条查询
其它部分命令支持效果不佳

一台twemproxy比一台redis性能低20%

实际生产环境应该

twemproxy1 (redis1 redis2 redis3)
twemproxy2 (redis1 redis2 redis3)
twemproxy3 (redis1 redis2 redis3)

程序中调用twemproxy1 twemproxy2 twemproxy3，或在前面加haproxy







