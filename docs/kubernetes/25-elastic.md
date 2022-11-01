# 实战 | 快速搭建 ELK



## 一、ECK-Operater

基于kubernetes部署

[Reference](https://www.elastic.co/cn/downloads/elastic-cloud-kubernetes)

```bash
# https://download.elastic.co/downloads/eck/1.2.1/all-in-one.yaml
# https://download.elastic.co/downloads/eck/2.4.0/crds.yaml
# https://download.elastic.co/downloads/eck/2.4.0/operator.yaml
```

[参考](http://icyfenix.cn/appendix/operation-env-setup/elk-setup.html)



> 演示3节点的集群

```bash
# version: 7.17.3

# Example
#   https://books.8ops.top/attachment/elastic/elastic_eck_crds.yaml-2.4.0
#   https://books.8ops.top/attachment/elastic/elastic_eck_operator.yaml-2.4.0
#   https://books.8ops.top/attachment/elastic/01-persistent-elastic-pv.yaml
#   https://books.8ops.top/attachment/elastic/01-persistent-elastic-pvc.yaml
#   https://books.8ops.top/attachment/elastic/10-elastic.yaml-7.17.3
# 

# 1，安装 ECK 对应的 Operator 资源对象
kubectl apply -f elastic_eck_crds.yaml-2.4.0
kubectl apply -f elastic_eck_operator.yaml-2.4.0

# 2，创建磁盘挂载
kubectl apply -f 01-persistent-elastic-pv.yaml
kubectl apply -f 01-persistent-elastic-pvc.yaml

# 3，创建 elastic 节点
kubectl apply -f 10-elastic.yaml-7.17.3

kubectl port-forward service/quickstart-es-http 5601

## 获取 ES 密码
kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}' | echo

# 4，创建kibana组件
kubectl apply -f 11-kibana.yaml-7.17.3

kubectl port-forward service/quickstart-kb-http 5601

## 获取 KB 密码
kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

```





## 二、OneKey

基于单机部署

- version: 7.0.1

- method:  docker-compose

```
version: '2.2'
services:
  es-node-01:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.0.1
    container_name: es-node-01
    environment:
      - node.name=es-node-01
      - discovery.seed_hosts=es-node-02
      - cluster.initial_master_nodes=es-node-01,es-node-02
      - cluster.name=es-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    ports:
      - 19200:9200
    networks:
      - esnet
  es-node-02:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.0.1
    container_name: es-node-02
    environment:
      - node.name=es-node-02
      - discovery.seed_hosts=es-node-01
      - cluster.initial_master_nodes=es-node-01,es-node-02
      - cluster.name=es-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    ports:
      - 29200:9200
    networks:
      - esnet
  es-node-03:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.0.1
    container_name: es-node-03
    environment:
      - node.name=es-node-03
      - discovery.seed_hosts=es-node-01
      - cluster.initial_master_nodes=es-node-01,es-node-02
      - cluster.name=es-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - esnet

  es-redis:
    image: redis:5.0.5
    container_name: es-redis
    ports:
      - 16379:6379
    networks:
      - esnet

  es-logstash-01:
    image: docker.elastic.co/logstash/logstash:7.0.1
    container_name: es-logstash-01
    links:
      - es-node-01
      - es-node-02
      - es-redis
    volumes:
      - /data/elk/logstash/pipeline:/usr/share/logstash/pipeline
    networks:
      - esnet

networks:
  esnet:
```



## 三、Helm

```bash
helm repo add elastic https://helm.elastic.co
helm repo update

helm search repo elastic
helm show values elastic/elasticsearch --version 7.17.3 > elasticsearch.yaml-7.17.3

# Example
#   https://books.8ops.top/attachment/elastic/01-persistent-elasticsearch.yaml
#   https://books.8ops.top/attachment/elastic/helm/elasticsearch.yaml-7.17.3
#

helm upgrade --install elasticsearch elastic/elasticsearch \
    -f elasticsearch.yaml-7.17.3 \
    -n kube-server \
    --create-namespace \
    --version 7.17.3 --debug



```

