# 通过Helm搭建MySQL



```bash

# ---
# mysql
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo mysql

helm show values bitnami/mysql > mysql.yaml-default

# - mysql-standalone.yaml
# - mysql-replication.yaml

helm install mysql-8 bitnami/mysql \
    -f mysql-standalone.yaml \
    -n kube-server \
    --create-namespace \
    --version 8.9.2 --debug

helm upgrade --install mysql-8 bitnami/mysql \
    -f mysql-standalone.yaml \
    -n kube-server \
    --create-namespace \
    --version 8.9.2 --debug    

helm -n kube-server uninstall mysql-8

helm install mysql-8 bitnami/mysql \
    -f mysql-replication.yaml \
    -n kube-server \
    --create-namespace \
    --version 8.9.2 --debug

helm upgrade --install mysql-8 bitnami/mysql \
    -f mysql-replication.yaml \
    -n kube-server \
    --create-namespace \
    --version 8.9.2 --debug 


```

