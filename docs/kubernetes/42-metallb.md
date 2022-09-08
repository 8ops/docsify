# 实战 | MetalLB 使用



> 更新 kube-proxy 

```bash
kubectl edit configmap -n kube-system kube-proxy

apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true # relative
  
kubectl -n kube-system rollout restart ds kube-proxy

```

> 安装 metallb

```bash

helm show values metallb/metallb > metallb.yaml-0.13.5-default

helm install metallb metallb/metallb \
    -f metallb.yaml-0.13.5 \
    --namespace=kube-server \
    --version 0.13.5

curl -i -k -H Host:echoserver.lab.wuxingdev.cn https://10.101.9.112
```



> vim metallb.yaml-0.13.5

```yaml
prometheus:
  scrapeAnnotations: true

controller:
  enabled: true
  logLevel: info
  image:
    repository: hub.8ops.top/google_containers/metallb-controller
    tag: v0.13.5

speaker:
  enabled: true
  logLevel: info
  image:
    repository: hub.8ops.top/google_containers/metallb-speaker
    tag: v0.13.5
```



> vim metallb-ipaddresspool.yaml

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: kube-server
spec:
  addresses:
  - 10.101.9.112-10.101.9.116
```



> edit svc

```bash
kubectl edit svc ingress-nginx-external-controller-external -n kube-server

kubectl patch svc loadbalancer -p '{"spec":{"externalTrafficPolicy":"Local"}}'
  externalTrafficPolicy: Local
```





> Reference

- https://metallb.universe.tf/faq/









