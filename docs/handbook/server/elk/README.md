

1，jdk 安装

cd /usr/local/src
wget http://uplus.file.youja.cn/elk/jdk-8u51-linux-x64.tar.gz
tar xvzf jdk-8u51-linux-x64.tar.gz
mv jdk1.8.0_51 /usr/local/
rm -f /usr/local/jdk
ln -s /usr/local/jdk1.8.0_51 /usr/local/jdk

cat > /etc/profile.d/jdk-env.sh << EOF
export JAVA_HOME=/usr/local/jdk
export JRE_HOME=\${JAVA_HOME}/jre  
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib  
export PATH=\${JAVA_HOME}/bin:\$PATH  
EOF

. /etc/profile
echo $PATH
java -version

>>>>>>>>
2，redis 安装

cd /usr/local/src
wget http://uplus.file.youja.cn/db/redis-2.8.9.tar.gz

cat > /etc/profile.d/redis-env.sh << EOF
export REDIS_HOME=/usr/local/redis
export PATH=\${REDIS_HOME}/bin:\$PATH
EOF
. /etc/profile
echo $PATH

/usr/local/redis/bin/redis-server /usr/local/redis/conf/6379.conf
<<<<<<<<

3，ELK安装

==== elasticsearch:
cd /usr/local/src/
wget http://uplus.file.youja.cn/elk/elasticsearch-1.7.1.tar.gz
tar xvzf elasticsearch-1.7.1.tar.gz
mv elasticsearch-1.7.1 /usr/local/
rm -f /usr/local/elasticsearch
ln -s /usr/local/elasticsearch-1.7.1 /usr/local/elasticsearch

cat > /etc/profile.d/elastic-env.sh << EOF
export ELASTIC_HOME=/usr/local/elasticsearch
export PATH=\${ELASTIC_HOME}/bin:\$PATH
EOF

. /etc/profile
echo $PATH

---- master and data（留意配置: 空格）
cat > /usr/local/elasticsearch/config/elasticsearch.yml <<EOF

cluster.name: youja.elasticsearch
http.jsonp.enable: true # 跨域
node.name: youja_node_50_101
index.number_of_shards: 10 
index.number_of_replicas: 2
bootstrap.mlockall: true
http.jsonp.enable: true
discovery.zen.ping.multicast.enabled: false

EOF

---- no master and no data elastic
cat > /usr/local/elasticsearch/config/elasticsearch.yml <<EOF

cluster.name: youja.elasticsearch 
node.name: youja_node_50_94
http.jsonp.enable: true
node.master: false
node.data: false
discovery.zen.ping.multicast.enabled: false

EOF

# 配置机器一半物理内存
vim /usr/local/elasticsearch/bin/elasticsearch.in.sh

if [ "x$ES_MIN_MEM" = "x" ]; then
    ES_MIN_MEM=8g
fi
if [ "x$ES_MAX_MEM" = "x" ]; then
    ES_MAX_MEM=8g
fi


ln -s /elk /usr/local/elasticsearch/data

>>>>>>>>
/usr/local/elasticsearch/bin/elasticsearch -d
curl http://10.10.50.94:9200
<<<<<<<<

==== logstash:
cd /usr/local/src/
wget http://uplus.file.youja.cn/elk/logstash-1.5.3.tar.gz
tar xzvf logstash-1.5.3.tar.gz
mv logstash-1.5.3 /usr/local/
rm -f /usr/local/logstash
ln -s /usr/local/logstash-1.5.3 /usr/local/logstash

cat > /etc/profile.d/logstash-env.sh << EOF
export LOGSTASH_HOME=/usr/local/logstash
export PATH=\${LOGSTASH_HOME}/bin:\$PATH
EOF

. /etc/profile
echo $PATH

---- 部署中心Logstash
mkdir /usr/local/logstash/conf/
vim /usr/local/logstash/conf/logstarsh_broker.conf
input {
  redis {
    host => "elk.redis.youja.cn"
    port => "6605"
    type => "redis-input"
    data_type => "list"
    key => "logstash:r:data"
    threads => 2000
    batch_count => 100
  }
}

output {
  elasticsearch {
    cluster => "elasticsearch"
    codec => "json"
    protocol => "http"
  }
}

# startup: logstash agent --verbose --config logstarsh_broker.conf --log stdout.log
# startup: logstash agent --quiet --config logstarsh_broker.conf

---- 部署远程LogStash
vim /usr/local/logstash/conf/logstash_nginx_dao_rpc.conf
input {
  file {
    path => ["/data/logs/nginx/default.api.youja.cn_access.log"]
    type => "nginx_api_rpc_access_log"
  }
  file {
    path => ["/data/logs/nginx/show.api.youja.cn_access.log"]
    type => "nginx_api_rpc_access_log"
  }
  file {
    path => ["/data/logs/nginx/top.api.youja.cn_access.log"]
    type => "nginx_api_rpc_access_log"
  }
  file {
    path => ["/data/logs/nginx/moplus.api.youja.cn_access.log"]
    type => "nginx_api_rpc_access_log"
  }
}

filter {
  if [type] == "nginx_api_rpc_access_log" {
    grok {
      match => { "message" => "%{IPORHOST:yj_remote_addr}`%{HOST:yj_host}`HTTP/%{NUMBER:yj_server_protocol:int}`%{WORD:yj_request_method}`%{NUMBER:yj_server_port:int}`(?:%{NUMBER:yj_bytes_sent:int}|-)`%{DATA:yj_request_uri}`(?:%{DATA:yj_query_string}|-)`%{NUMBER:yj_response_status:int}`(?:%{NUMBER:yj_request_time:float}|0)`%{HTTPDATE:yj_time_local}`(?:%{DATA:yj_http_referer}|-)`(?:%{DATA:yj_ua}|-)`(?:%{DATA:yj_upstream_addr}|-)`(?:%{NUMBER:yj_upstream_status:int}|-)`(?:%{NUMBER:yj_upstream_response_time:float}|0)`(?:%{DATA:yj_uid}|-)`(?:%{DATA:yj_vtype}|-)`(?:%{DATA:yj_imsi}|-)`(?:%{DATA:yj_imei}|-)`(?:%{DATA:yj_device_id}|-)`(?:%{DATA:yj_mac}|-)"}
      remove_field => ["message"]
    }
    date {
      match => [ "yj_time_local" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
    geoip {
      source => "yj_remote_addr"
      add_tag => ["geoip"]
    }
    urldecode {
      all_fields => true
    }
    if "_grokparsefailure" in [tags] {
      drop{}
    }
  }
}

output {
  redis {
    host => "elk_t.redis.youja.cn"
    port => "6200"
    data_type => "list"
    key => "logstash:api:data"
  }     
}

# startup: logstash agent --verbose --config logstash.conf --log stdout.log

==== kibana:
cd /usr/local/src/
wget http://uplus.file.youja.cn/elk/kibana-4.1.0-linux-x64.tar.gz
tar xzvf kibana-4.1.0-linux-x64.tar.gz
mv kibana-4.1.0-linux-x64 /usr/local/
rm -f /usr/local/kibana
ln -s /usr/local/kibana-4.1.0-linux-x64 /usr/local/kibana

cat > /etc/profile.d/kibana-env.sh << EOF
export KIBANA_HOME=/usr/local/kibana
export PATH=\${KIBANA_HOME}/bin:\${KIBANA_HOME}/node/bin:\$PATH
EOF

. /etc/profile
echo $PATH

# vim /usr/local/kibana/config/kibana.yml
# elasticsearch_url: "http://localhost:9200"
kibana_index: ".kibana4"

>>>>>>>>
# startup: /usr/local/kibana/bin/kibana
curl http://10.10.50.101:5601
<<<<<<<<

配置完成了，开始使用

4，综合使用
logstash: input-->filter-->output
kibana  : 数据定义，图形定义


==== supervisor 管理程序
yum install supervisor.noarch -y

中心机器

vim /etc/supervisord.conf

logfile_maxbytes=5MB;
logfile_backups=3;

[program:elasticsearch]
command=/usr/local/elasticsearch/bin/elasticsearch-youja
autostart=true
autorestart=true
user=root
log_stdout=false
log_stderr=true
logfile=/var/log/supervisor/elasticsearch.out

[program:logstash]
command=/usr/local/logstash/bin/logstash-youja agent --quiet -f /usr/local/logstash/conf/
autostart=false
autorestart=true
user=root
log_stdout=false
log_stderr=true
logfile=/var/log/supervisor/logstash.out

[program:kibana]
command=/usr/local/kibana/bin/kibana
autostart=false
autorestart=true
user=root
log_stdout=false
log_stderr=true
logfile=/var/log/supervisor/kibana.out

/etc/init.d/supervisord start
supervisorctl status


################################################################################
---- for elastic install _plugin 

cd /usr/local/elasticsearch/bin

./plugin -install mobz/elasticsearch-head
./plugin -install lukas-vlcek/bigdesk
./plugin -install lmenezes/elasticsearch-kopf
./plugin -install karmi/elasticsearch-paramedic

http://elastic.test.youja.cn/_plugin/paramedic/
http://elastic.test.youja.cn/_plugin/kopf/
http://elastic.test.youja.cn/_plugin/bigdesk/
http://elastic.test.youja.cn/_plugin/head/

---- for elastic clean index
curl -i -X DELETE "http://elastic.test.youja.cn/logstash-2015.06.25"




