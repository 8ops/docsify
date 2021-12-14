# 升级kubernetes

[Upgrading kubeadm clusters | Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

[kubeadm upgrade | Kubernetes](https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/kubeadm-upgrade/)





## 镜像同步

[image-syncer](https://github.com/AliyunContainerService/image-syncer)

> auth.json

```json
{
  "hub.8ops.top": {
    "username": "",
    "password": ""
  }
}
```



> images.json

```json
{
  "registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.23.0": "hub.8ops.top/google_containers/kube-apiserver",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.23.0": "hub.8ops.top/google_containers/kube-controller-manager",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.23.0": "hub.8ops.top/google_containers/kube-scheduler",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.23.0": "hub.8ops.top/google_containers/kube-proxy",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.8.6": "hub.8ops.top/google_containers/coredns",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.1-0": "hub.8ops.top/google_containers/etcd",
  "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6": "hub.8ops.top/google_containers/pause"
}
```

需要存在项目 hub.8ops.top/google_containers ，否则会出现同步不成功情况



```bash
image-syncer --auth=auth.json --images=images.json --arch=amd64 --os=linux
```

一定要指定arch，否则会同步非预期的arch镜像产物过来



## 安装二进制

```bash
# --------- update ----------- #
apt update
apt-mark showhold
apt install kubeadm=1.23.0-00 kubectl=1.23.0-00 kubelet=1.23.0-00 

# --------- check ----------- #
dpkg -l | grep kube && kubeadm version
apt-mark hold kubeadm kubectl kubelet
apt-mark showhold
```



## 升级

```yaml
kubeadm upgrade plan 

# first master
kubeadm upgrade apply v1.23.0 -v 5

## kubelet配置未随kubernetes升级，手动介入
# vim /var/lib/kubelet/kubeadm-flags.env
# sed -i 's/pause:3.5/pause:3.6/' /var/lib/kubelet/kubeadm-flags.env
systemctl restart kubelet
systemctl status kubelet

# other master/node
kubeadm upgrade node -v 5

kubeadm certs check-expiration

## coredns未随kubernetes升级，手动介入

```



> vim /var/lib/kubelet/kubeadm-flags.env

```bash
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/var/run/containerd/containerd.sock --pod-infra-container-image=hub.8ops.top/google_containers/pause:3.6"
```



## 迁移应用

[yq](https://github.com/mikefarah/yq)

```bash

for OBJ in $(kubectl api-resources --verbs=list --namespaced -o name)
do
   for DEF in $(kubectl get --show-kind --ignore-not-found $OBJ -o name)
   do
      mkdir -p $(dirname $DEF)
      kubectl get $DEF -o yaml \
      | yq eval 'del(.metadata.resourceVersion, .metadata.uid, .metadata.annotations, .metadata.creationTimestamp, .metadata.selfLink, .metadata.managedFields)' - > $DEF.yaml 
   done
done


kubectl get ep  -l k8s-ep=custom-ep -o yaml | \
    ./yq eval 'del(.items[].metadata.resourceVersion, .items[].metadata.uid, .items[].metadata.annotations, .items[].metadata.creationTimestamp, .items[].metadata.selfLink, .items[].metadata.managedFields, .metadata)' - > endpoints.list.yaml
```



