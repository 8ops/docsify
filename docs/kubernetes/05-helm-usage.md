# Helm的使用

[guide](https://helm.sh/zh/docs/)

[helm hub](https://artifacthub.io/) 

## 优化源

```bash
# helm repo list
NAME       URL
azure      https://mirror.azure.cn/kubernetes/charts/
aliyun     https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
elastic    https://helm.elastic.co
gitlab     https://charts.gitlab.io
harbor     https://helm.goharbor.io
bitnami    https://charts.bitnami.com/bitnami
incubator  https://kubernetes-charts-incubator.storage.googleapis.com
google     https://kubernetes-charts.storage.googleapis.com
```

推荐使用`azure`和`aliyun`

## 使用场景

### ingress-nginx

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm search repo ingress-nginx

helm show values ingress-nginx/ingress-nginx > ingress-nginx-default.yaml

helm install ingress-nginx-external-controller ingress-nginx/ingress-nginx -f ingress-nginx-external-configs.yaml -n kube-server --version 4.0.8 --debug

helm install ingress-nginx-internal-controller ingress-nginx/ingress-nginx -f ingress-nginx-internal-configs.yaml -n kube-server --version 4.0.8 --debug

#变更 ~/.cache/helm/repository/ingress-nginx-index.yaml 从私有文件站下载
sed -i 's#https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.0.8/ingress-nginx-4.0.8.tgz#http://filestorage.wuxingdev.cn/ops/helm/ingress-nginx-4.0.8.tgz#' ~/.cache/helm/repository/ingress-nginx-index.yaml

helm list -A

helm -n kube-server uninstall ingress-nginx-external-controller
```

edit external.yaml

```yaml
controller:
  name: external
  image:
    registry: registry.wuxingdev.cn
    image: google_containers/nginx-ingress-controller
    tag: "v1.0.5"
    digest:
    pullPolicy: IfNotPresent
    runAsUser: 101
    allowPrivilegeEscalation: true

  kind: DaemonSet
  nodeSelector:
    edge: external
  hostNetwork: true
  service:
    enabled: false

  ingressClassResource:
    name: external
    enabled: true
    default: false
    controllerValue: "k8s.io/ingress-nginx"

  lifecycle:
  admissionWebhooks:
    enabled: false

    patch:
      enabled: true
      image:
        registry: registry.wuxingdev.cn
        image: google_containers/kube-webhook-certgen
        tag: v1.1.1
        digest:

defaultBackend:
  enabled: true
  name: defaultbackend
  image:
    registry: registry.wuxingdev.cn
    image: google_containers/defaultbackend
    tag: "1.5"
```



### dashboard

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm search repo kubernetes-dashboard

helm show values kubernetes-dashboard/kubernetes-dashboard > kubernetes-dashboard-default.yaml

sed -i 's#kubernetes-dashboard-5.0.4.tgz#http://filestorage.wuxingdev.cn/ops/helm/kubernetes-dashboard-5.0.4.tgz#' ~/.cache/helm/repository/kubernetes-dashboard-index.yaml

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f kubernetes-dashboard-config.yaml -n kube-server --version 5.0.4 --debug

```

edit dashboard.yaml

```yaml

```

