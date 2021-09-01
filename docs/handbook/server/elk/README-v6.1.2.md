
https://www.elastic.co/start

vim /etc/security/limits.conf 
* soft nofile 65536
* hard nofile 102400
* soft nproc 4096 
* hard nproc 8192  #256791

vim /etc/security/limits.d/90-nproc.conf 
* soft nproc 10240

vim /etc/sysctl.conf
vm.max_map_count=262144

vim config/jvm.options  
-Xms512m  
-Xmx512m  

vim config/elasticsearch.yml
cluster.name: gat_es_cluster
node.name: gat_es_node_9_240
node.master: true
node.data: true  #指定该节点是否存储索引数据，默认为true。
#index.number_of_replicas: 1
network.host: 10.101.9.240
http.port: 9200 #设置对外服务的http端口，默认为9200。
transport.tcp.port: 9300 #设置节点间交互的tcp端口，默认是9300。
#path.data: /data1/data
#discovery.zen.ping.multicast.enabled: false #关掉多播
#discovery.zen.fd.ping_timeout: 120s
#discovery.zen.fd.ping_retries: 6
#discovery.zen.fd.ping_interval: 30s
bootstrap.memory_lock: false         #centos6兼容
bootstrap.system_call_filter: false  #centos6兼容


vim config/kibana.yml
server.host: "0.0.0.0"
elasticsearch.url: "http://10.101.9.240:9200"









10.10.10.62 yum mirror/ansible/fpm
10.10.20.101 es/filebeat/logstash/k8s




























