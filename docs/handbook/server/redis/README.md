
wget http://download.redis.io/releases/redis-2.8.9.tar.gz

tar xvzf redis-2.8.9.tar.gz
make
make install


mkdir -p /etc/redis /data/redis
egrep -v "^($|#)" /usr/local/src/redis-2.8.9/redis.conf > /etc/redis/redis.conf


====> start_redis.sh
#! /bin/bash

add_redis_node(){
    port=$1
    [ -z $port ] && port=6379
    cp /etc/redis/redis.conf                    /etc/redis/redis-$port.conf
    sed -i '1s/no/yes/'                         /etc/redis/redis-$port.conf
    sed -i '2s/redis/redis-'$port'/'            /etc/redis/redis-$port.conf
    sed -i '3s/6379/'$port'/'                   /etc/redis/redis-$port.conf
    sed -i '16s/dump/dump-'$port'/'             /etc/redis/redis-$port.conf
    sed -i '17s/\.\//\/data\/redis/'            /etc/redis/redis-$port.conf
    /usr/local/bin/redis-server                 /etc/redis/redis-$port.conf
}

add_redis_node 6479
add_redis_node 6579
add_redis_node 6679

#==end

SLAVEOF NO ONE # 改变 master & slave 角色

SLAVEOF 127.0.0.1 6479
SLAVEOF 127.0.0.1 6579

redis-cli -h 127.0.0.1 -p 6579 "slaveof 127.0.0.1 6479"
redis-cli -h 127.0.0.1 -p 6679 "slaveof 127.0.0.1 6579"










