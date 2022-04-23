# 实战 | 基于Helm使用Redis





```yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo redis

helm show values bitnami/redis > redis.yaml-default

helm install redis bitnami/redis \
    -f redis.yaml \
    -n kube-server \
    --create-namespace \
    --version 16.8.7 --debug

helm upgrade --install redis bitnami/redis \
    -f redis.yaml \
    -n kube-server \
    --create-namespace \
    --version 16.8.7 --debug

helm -n kube-server uninstall redis 

# ---
helm show values bitnami/redis-cluster > redis-cluster.yaml-default

```

