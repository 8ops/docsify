# 实战 | Helm的使用

![helm](../images/kubernetes/cover/05-helm-usage.png)

Helm 是 Kubernetes 的包管理器，从CNCF毕业。

使用Helm安装Kubernetes中的插件将会变得是一件容易的事情。



[官方文档](https://helm.sh/zh/docs/)

[helm hub](https://artifacthub.io/ ) 

![Helm](../images/kubernetes/helm.png)

Helm是个很意思的工具，简化了kubernetes上常用组件的管理。



## 一、镜像源私有化

将外部镜像产物拉到私有环境缓存起来[下载脚本](https://books.8ops.top/attachment/kubernetes/02-pull-image-to-local.sh)

```bash
#!/bin/bash

#
# example
#  pull_image_to_local.sh kubernetesui/metrics-scraper:v1.0.7
#  pull_image_to_local.sh registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:v1.1.0
#  pull_image_to_local.sh nginx:1.21.4 third
#
# explain
#  docker pull kubernetesui/metrics-scraper:v1.0.7
#  docker tag kubernetesui/metrics-scraper:v1.0.7 hub.8ops.top/google_containers/metrics-scraper:v1.0.7
#  docker push hub.8ops.top/google_containers/metrics-scraper:v1.0.7
#  docker rmi kubernetesui/metrics-scraper:v1.0.7
#  docker rmi hub.8ops.top/google_containers/metrics-scraper:v1.0.7
#

set -e

src=$1
dst=$2
harbor=hub.8ops.top
[ -z ${dst} ] && dst=google_containers
docker pull ${src}
docker tag ${src} `echo ${src} |awk -v harbor=${harbor} -v dst=${dst} -F'/' '{printf("%s/%s/%s",harbor,dst,$NF)}'`
docker push `echo ${src} |awk -v harbor=${harbor} -v dst=${dst} -F'/' '{printf("%s/%s/%s",harbor,dst,$NF)}'`
docker rmi ${src}
docker rmi `echo ${src} |awk -v harbor=${harbor} -v dst=${dst} -F'/' '{printf("%s/%s/%s",harbor,dst,$NF)}'`

```



## 二、优化源

使用Helm后会生成相应的缓存文件，使用过程中必要时可以主动清空。目录如下

- ~/.config/helm
- ~/.cache/helm



> 常用源

```bash
# helm repo list
NAME       						URL
azure                 https://mirror.azure.cn/kubernetes/charts
aliyun                https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
elastic               https://helm.elastic.co
gitlab                https://charts.gitlab.io
harbor                https://helm.goharbor.io
bitnami               https://charts.bitnami.com/bitnami
incubator             https://kubernetes-charts-incubator.storage.googleapis.com
google                https://kubernetes-charts.storage.googleapis.com
ingress-nginx         https://kubernetes.github.io/ingress-nginx
kubernetes-dashboard  https://kubernetes.github.io/dashboard/
```

推荐使用`azure`和`aliyun`



## 三、组件

### 3.1 Ingress-nginx

> 宿主机kernel优化

```bash
sysctl -w net.core.somaxconn=32768; sysctl -w net.ipv4.ip_local_port_range='1024 65000'
```



```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm search repo ingress-nginx

helm show values ingress-nginx/ingress-nginx > ingress-nginx.yaml-default

# vim ingress-nginx-external.yaml

# deprecated
# 若不FW需要变更 ~/.cache/helm/repository/ingress-nginx-index.yaml 从私有文件站下载
## sed -i 's#https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.0.13/ingress-nginx-4.0.13.tgz#http://d.8ops.top/ops/helm/ingress-nginx-4.0.13.tgz#' ~/.cache/helm/repository/ingress-nginx-index.yaml

kubectl label no k-kube-lab-04 edge=external
kubectl cordon k-kube-lab-04
helm install ingress-nginx-external-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-external.yaml \
    -n kube-server \
    --create-namespace \
    --version 4.0.13 --debug

kubectl label no k-kube-lab-05 edge=internal
kubectl cordon k-kube-lab-05
helm install ingress-nginx-internal-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-internal.yaml \
    -n kube-server \
    --version 4.0.13 --debug

helm list -A

# upgrade
helm upgrade ingress-nginx-external-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-external.yaml \
    -n kube-server \
    --version 4.0.13 --debug

helm upgrade ingress-nginx-internal-controller ingress-nginx/ingress-nginx \
    -f ingress-nginx-internal.yaml \
    -n kube-server \
    --version 4.0.13 --debug


# uninstall     
helm -n kube-server uninstall ingress-nginx-external-controller
```



> vim [ingress-nginx-external.yaml](https://books.8ops.top/attachment/kubernetes/helm/ingress-nginx-external.yaml)

```yaml
controller:
  name: external
  image:
    registry: hub.8ops.top
    image: google_containers/nginx-ingress-controller
    tag: "v1.1.0"
    digest:

  hostNetwork: true
  hostPort:
    enabled: true
    ports:
      http: 80
      https: 443

  config: {} # nginx.conf 全局配置

  ingressClassResource:
    name: external
    enabled: true
    default: false
    controllerValue: "k8s.io/ingress-nginx" # 这里的nginx是缺省的ingress-class

  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 256Mi

  kind: DaemonSet
  nodeSelector:
    kubernetes.io/os: linux
    edge: external

  service:
    enabled: false

  lifecycle:
  admissionWebhooks:
    enabled: false
```



> 演示效果

![查看应用效果](../images/kubernetes/screen/05-20.png)



### 3.2 Dashboard

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm search repo kubernetes-dashboard

helm show values kubernetes-dashboard/kubernetes-dashboard > kubernetes-dashboard.yaml-default

# vim kubernetes-dashboard.yaml

# deprecated
# 若不FW需要变更 ~/.cache/helm/repository/kubernetes-dashboard-index.yaml 从私有文件站下载
## sed -i 's#kubernetes-dashboard-5.0.4.tgz#http://d.8ops.top/ops/helm/kubernetes-dashboard-5.0.4.tgz#' ~/.cache/helm/repository/kubernetes-dashboard-index.yaml

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -f kubernetes-dashboard.yaml \
    -n kube-server \
    --create-namespace \
    --version 5.0.4 --debug

helm upgrade kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -f kubernetes-dashboard.yaml \
    -n kube-server \
    --version 5.0.4 --debug

#-----------------------------------------------------------
# create sa for guest
kubectl create serviceaccount dashboard-guest -n kube-server

# binding clusterrole
kubectl create clusterrolebinding dashboard-guest \
  --clusterrole=view \
  --serviceaccount=kube-server:dashboard-guest

# output token
kubectl describe secrets \
  -n kube-server $(kubectl -n kube-server get secret | awk '/dashboard-guest/{print $1}')

#----
# create sa for ops
kubectl create serviceaccount dashboard-ops -n kube-server

# binding clusterrole
kubectl create clusterrolebinding dashboard-ops \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-server:dashboard-ops

# output token
kubectl describe secrets \
  -n kube-server $(kubectl -n kube-server get secret | awk '/dashboard-ops/{print $1}')
```



> vim kubernetes-dashboard.yaml

```yaml
image:
  repository: hub.8ops.top/google_containers/dashboard
  tag: v2.4.0

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1
    memory: 512Mi

ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

  className: "external"

  hosts:
    - dashboard.8ops.top
  tls:
    - secretName: tls-8ops.top
      hosts:
        - dashboard.8ops.top

extraArgs: 
  - --token-ttl=86400

settings:
  clusterName: "Dashboard of Lab"
  itemsPerPage: 20
  labelsLimit: 3
  logsAutoRefreshTimeInterval: 10
  resourceAutoRefreshTimeInterval: 10

metricsScraper:
  enabled: true
  image:
    repository: hub.8ops.top/google_containers/metrics-scraper
    tag: v1.0.7
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi

metrics-server:
  enabled: true
  image:
    repository: hub.8ops.top/google_containers/metrics-server
    tag: v0.5.0
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi
  args:
    - --kubelet-preferred-address-types=InternalIP
    - --kubelet-insecure-tls

```



> 演示效果


![打开Dashboard](../images/kubernetes/screen/05-21.png)



![登录Dashboard](../images/kubernetes/screen/05-22.png)

### 3.3 Elastic

```bash
helm repo add elastic https://helm.elastic.co

helm search repo logstash

helm show values elastic/logstash > elastic_logstash.yaml-default

helm install logstash elastic/logstash \
    -f elastic_logstash.yaml \
    -n kube-server \
    --create-namespace \
    --version 7.16.2 --debug
    
helm upgrade logstash elastic/logstash \
    -f elastic_logstash.yaml \
    -n kube-server \
    --version 7.16.2 --debug
    
#------------------------------------------#
helm search repo elastic

helm show values elastic/eck-operator > elastic_eck.yaml-default

helm install elastic-operator elastic/eck-operator \
		-f elastic_eck.yaml \
		-n kube-server \
		--create-namespace \
		--version 1.9.1 --debug
		
helm upgrade elastic-operator elastic/eck-operator \
		-f elastic_eck.yaml \
		-n kube-server \
		--create-namespace \
		--version 1.9.1 --debug
		
#------------------------------------------#
kubectl create -f https://download.elastic.co/downloads/eck/1.9.1/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/1.9.1/operator.yaml

kubectl -n elastic-system logs -f statefulset.apps/elastic-operator
```



### 3.4 Prometheus

```bash
```



### 3.5 ~~Zadig~~

`TODO`

```bash

helm repo add koderover-chart https://koderover.tencentcloudcr.com/chartrepo/chart

helm search repo zadig

helm show values koderover-chart/zadig > koderover-zadig.yaml-default

export NAMESPACE=kube-server
export DOMAIN=zadig.8ops.top

# helm upgrade --install zadig \
#     --namespace ${NAMESPACE} \
#     koderover-chart/zadig \
#     --version=1.8.0 \
#     --set endpoint.FQDN=${DOMAIN} \
#     --set global.extensions.extAuth.extauthzServerRef.namespace=${NAMESPACE} \
#     --set "dex.config.staticClients[0].redirectURIs[0]=http://${DOMAIN}/api/v1/callback,dex.config.staticClients[0].id=zadig,dex.config.staticClients[0].name=zadig,dex.config.staticClients[0].secret=ZXhhbXBsZS1hcHAtc2VjcmV0"

helm install zadig koderover-chart/zadig \
    -f koderover-zadig.yaml \
    -n kube-server \
    --create-namespace \
    --version 1.8.0 --debug

helm -n kube-server uninstall zadig
kubectl -n kube-server delete all -l app.kubernetes.io/name=zadig

# backup. Either IP+PORT or DOMAIN shoule be provided
# export IP=10.101.11.234
# export PORT=30010
export NAMESPACE=kube-server
export DOMAIN=zadig.8ops.top
export INGRESS_CLASS=external

curl -SsL https://download.koderover.com/install?type=standard -o zadig-install.sh
bash zadig-install.sh


```

> vim koderover-zadig.yaml

```yaml
endpoint:
  FQDN: zadig.8ops.top
global:
  image:
    registry: koderover.tencentcloudcr.com/koderover-public
  extensions:
    extAuth:
      extauthzServerRef:
        namespace: kube-server

dex:
  config:
    staticClients:
      - id: zadig
        redirectURIs:
          - 'http://zadig.8ops.top/api/v1/callback'
        name: 'zadig'
        secret: ZXhhbXBsZS1hcHAtc2VjcmV0
```



### 3.6 ~~Banzai~~

`TODO`

```bash
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com

helm repo update

helm search repo logging-operator-logging

helm install banzaicloud-stable/logging-operator-logging

helm install banzaicloud banzaicloud-stable/logging-operator-logging \
    -n kube-server \
    --create-namespace \
    --version 3.16.0 --debug

```

