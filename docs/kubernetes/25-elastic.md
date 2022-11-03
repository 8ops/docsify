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

[Reference](https://developer.aliyun.com/article/861272)

### 3.1 Prepare

ElasticSearch 7.x 版本默认安装了 X-Pack 插件，并且部分功能免费，这里我们配置安全证书文件。

> 生成证书

```bash
# 运行容器生成证书
docker run --name elastic-charts-certs \
  -i -w /app hub.8ops.top/third/elasticsearch:7.17.3 \
  /bin/sh -c "elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && elasticsearch-certutil cert --name security-master --dns security-master --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12"

# 从容器中将生成的证书拷贝出来
docker cp elastic-charts-certs:/app/elastic-certificates.p12 ./ 

# 删除容器
docker rm -f elastic-charts-certs

# 将 pcks12 中的信息分离出来，写入文件
openssl pkcs12 -nodes -passin pass:'' \
  -in elastic-certificates.p12 \
  -out elastic-certificate.pem
```

> 添加证书到集群

```bash
# 添加证书
kubectl -n elastic-system create secret generic elastic-certificates \
  --from-file=lib/elastic-certificates.p12
kubectl -n elastic-system create secret generic elastic-certificate-pem \
  --from-file=lib/elastic-certificate.pem

# 设置集群用户名密码，用户名不建议修改
kubectl -n elastic-system create secret generic elastic-credentials \
  --from-literal=username=elastic --from-literal=password=ops@2022
  
kubectl -n elastic-system create secret generic kibana \
  --from-literal=encryptionkey=zGFTX0cy3ubYVmzuunACDZuRj0PALqOM
```

尝试启动xpack资料

- https://github.com/elastic/helm-charts/tree/7.17/kibana/examples/security



### 3.2 Install

> elasticsearch

```bash
helm repo add elastic https://helm.elastic.co
helm repo update

helm search repo elastic
helm show values elastic/elasticsearch --version 7.17.3 > elasticsearch.yaml-7.17.3

# Example
#   https://books.8ops.top/attachment/elastic/01-persistent-elastic-cluster.yaml
#   https://books.8ops.top/attachment/elastic/helm/elastic-cluster-master.yaml-7.17.3
#   https://books.8ops.top/attachment/elastic/helm/elastic-cluster-data.yaml-7.17.3
#   https://books.8ops.top/attachment/elastic/helm/elastic-cluster-client.yaml-7.17.3
#

# master 节点
helm upgrade --install elastic-cluster-master elastic/elasticsearch \
    -f elastic-cluster-master.yaml-7.17.3 \
    -n elastic-system\
    --version 7.17.3

# data 节点
helm upgrade --install elastic-cluster-data elastic/elasticsearch \
    -f elastic-cluster-data.yaml-7.17.3 \
    -n elastic-system\
    --version 7.17.3

# client 节点
helm upgrade --install elastic-cluster-client elastic/elasticsearch \
    -f elastic-cluster-client.yaml-7.17.3 \
    -n elastic-system\
    --version 7.17.3

#### 
# 尝试关闭 xpack.security.enabled 
# 
kubectl -n elastic-system delete pvc elastic-cluster-data-elastic-cluster-data-0 elastic-cluster-data-elastic-cluster-data-1 elastic-cluster-data-elastic-cluster-data-2 elastic-cluster-master-elastic-cluster-master-0 elastic-cluster-master-elastic-cluster-master-1 elastic-cluster-master-elastic-cluster-master-2


```



> kibana

```bash
helm search repo kibana
helm show values elastic/kibana --version 7.17.3 > kibana.yaml-7.17.3

# Example
#   https://books.8ops.top/attachment/elastic/helm/kibana.yaml-7.17.3
# 

helm upgrade --install kibana elastic/kibana \
    -f kibana.yaml-7.17.3 \
    -n elastic-system \
    --version 7.17.3
```

