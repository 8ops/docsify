# 实战 | 通过Helm搭建 MongoDB



## 一、Helm

## 1.1 Install

```bash
helm search repo mongo
helm show values bitnami/mongodb > mongo.yaml-13.1.5-default

# standalone
# Example
#   https://books.8ops.top/attachment/mongo/helm/mongo.yaml-13.1.5
#

helm install mongo-standalone bitnami/mongodb \
    -f mongo.yaml-13.1.5 \
    -n kube-server \
    --create-namespace \
    --version 13.1.5 --debug


```

