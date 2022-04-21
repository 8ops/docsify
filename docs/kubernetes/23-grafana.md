# 通过Helm搭建Grafana

先准备mysql存储grafana的metedata信息

| name     | value   |
| -------- | ------- |
| database | grafana |
| username | grafana |
| password | grafana |



## Install

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm search repo grafana
 
helm show values grafana/grafana > grafana.yaml-default 

helm install grafana grafana/grafana \
    -f grafana.yaml \
    -n kube-server \
    --create-namespace \
    --version 6.26.4 --debug

helm upgrade --install grafana grafana/grafana \
    -f grafana.yaml \
    -n kube-server \
    --create-namespace \
    --version 6.26.4 --debug
    
helm -n kube-server uninstall grafana    

CREATE DATABASE `grafana` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
```



