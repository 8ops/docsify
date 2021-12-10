# Helm的使用

[docs](https://helm.sh/zh/docs/)

[helm hub](https://artifacthub.io/) 

## 镜像源私有化

```bash
#!/bin/bash

#
# example
#  pull_image_to_local.sh kubernetesui/metrics-scraper:v1.0.7
#  pull_image_to_local.sh registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.1.0
#
# explain
#  docker pull kubernetesui/metrics-scraper:v1.0.7
#  docker tag kubernetesui/metrics-scraper:v1.0.7 registry.wuxingdev.cn/google_containers/metrics-scraper:v1.0.7
#  docker push registry.wuxingdev.cn/google_containers/metrics-scraper:v1.0.7
#  docker rmi kubernetesui/metrics-scraper:v1.0.7
#  docker rmi registry.wuxingdev.cn/google_containers/metrics-scraper:v1.0.7
#

src=$1
docker pull ${src}
docker tag ${src} `echo ${src} |awk -F'/' '{printf("registry.wuxingdev.cn/google_containers/%s",$NF)}'`
docker push `echo ${src} |awk -F'/' '{printf("registry.wuxingdev.cn/google_containers/%s",$NF)}'`
docker rmi ${src}
docker rmi `echo ${src} |awk -F'/' '{printf("registry.wuxingdev.cn/google_containers/%s",$NF)}'`

```



## 优化源

生成缓存文件，必要时清空

- ~/.config/helm
- ~/.cache/helm

```bash
# helm repo list
NAME       URL
azure      https://mirror.azure.cn/kubernetes/charts
aliyun     https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
elastic    https://helm.elastic.co
gitlab     https://charts.gitlab.io
harbor     https://helm.goharbor.io
bitnami    https://charts.bitnami.com/bitnami
incubator  https://kubernetes-charts-incubator.storage.googleapis.com
google     https://kubernetes-charts.storage.googleapis.com
ingress-nginx       	https://kubernetes.github.io/ingress-nginx
kubernetes-dashboard	https://kubernetes.github.io/dashboard/
```

推荐使用`azure`和`aliyun`

## 使用场景

### Ingress-nginx

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm search repo ingress-nginx

helm show values ingress-nginx/ingress-nginx > ingress-nginx-default.yaml

# vim ingress-nginx-external-config.yaml

# 若不FW需要变更 ~/.cache/helm/repository/ingress-nginx-index.yaml 从私有文件站下载
## sed -i 's#https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.0.13/ingress-nginx-4.0.13.tgz#http://filestorage.wuxingdev.cn/ops/helm/ingress-nginx-4.0.13.tgz#' ~/.cache/helm/repository/ingress-nginx-index.yaml

kubectl label no gat-dev-k8s-node-11 edge=external
helm install ingress-nginx-external-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-external-config.yaml \
    -n kube-server \
    --create-namespace \
    --version 4.0.13 --debug

kubectl label no gat-dev-k8s-node-12 edge=internal
helm install ingress-nginx-internal-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-internal-config.yaml \
    -n kube-server \
    --version 4.0.13 --debug

helm list -A

helm -n kube-server uninstall ingress-nginx-external-controller
```

> vim ingress-nginx-external-config.yaml

```yaml
controller:
  name: external
  image:
    registry: registry.wuxingdev.cn
    image: google_containers/nginx-ingress-controller
    tag: "v1.1.0"
    digest:

  hostNetwork: true
  hostPort:
    enabled: true
    ports:
      http: 80
      https: 443

  ingressClassResource:
    name: external
    enabled: true
    default: false
    controllerValue: "k8s.io/ingress-nginx"

  kind: DaemonSet
  nodeSelector:
    kubernetes.io/os: linux
    edge: external

  lifecycle:
  admissionWebhooks:
    enabled: false
```



### Dashboard

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm search repo kubernetes-dashboard

helm show values kubernetes-dashboard/kubernetes-dashboard > kubernetes-dashboard-default.yaml

# 若不FW需要变更 ~/.cache/helm/repository/kubernetes-dashboard-index.yaml 从私有文件站下载
## sed -i 's#kubernetes-dashboard-5.0.4.tgz#http://filestorage.wuxingdev.cn/ops/helm/kubernetes-dashboard-5.0.4.tgz#' ~/.cache/helm/repository/kubernetes-dashboard-index.yaml

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -f kubernetes-dashboard-config.yaml \
    -n kube-server \
    --create-namespace \
    --version 5.0.4 --debug

helm upgrade kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f kubernetes-dashboard-config.yaml -n kube-server --version 5.0.4 --debug

kubectl create serviceaccount dashboard-admin -n kube-server
kubectl create clusterrolebinding dashboard-server --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
kubectl describe secrets -n kube-system $(kubectl -n kube-server get secret | awk '/dashboard-admin/{print $1}')
```

> vim kubernetes-dashboard-config.yaml

```yaml
image:
  repository: registry.wuxingdev.cn/google_containers/dashboard
  tag: v2.4.0
```













kubelet

```yaml

    nodeStatusReportFrequency: 10s
    nodeStatusUpdateFrequency: 10s
    imageGCLowThresholdPercent: 40
    imageGCHighThresholdPercent: 50
    systemReserved:
      cpu: 500m
      memory: 500m
    kubeReserved:
      cpu: 500m
      memory: 500m
    evictionPressureTransitionPeriod: 300s
    maxPods: 200
```

