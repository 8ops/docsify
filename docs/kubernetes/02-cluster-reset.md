# Kubernetes Cluster 重置环境

*已经封装一键脚本，下载直接执行*

## 一、快速应用

清除内容包括

- kubeadm reset
- release ip link
- release iptables
- stop service
- remove package
- release directory



```bash
curl -s https://m.8ops.top/attachment/kubernetes/99-reset.sh | bash
```



![kubernetes cluster reset](../images/kubernetes/screen/02-reset.png)



## 二、逻辑解析

```Bash
#!/bin/bash

# kubernetes cluster reset
kubeadm reset --force --cri-socket /run/containerd/containerd.sock
# kubeadm reset --force --cri-socket /var/run/dockershim.sock

# 释放网络设备
ip link delete flannel.1
ip link delete cni0
ip link delete kube-ipvs0

# 清除防火墙策略
iptables -F && ipvsadm -C && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t mangle -F && iptables -t mangle -X

# crictl images | awk 'NR>1{printf("crictl rmi %s\n",$3)}' |sh

# 停止服务
systemctl stop kubelet
systemctl stop docker
systemctl stop containerd

# 解除软件包版本锁定
apt-mark unhold kubeadm
apt-mark unhold kubectl
apt-mark unhold kubelet
apt-mark unhold docker
apt-mark unhold containerd

# 查看软件包锁定清单
apt-mark showhold

# 移除软件包及依赖包
apt remove -y --purge --allow-change-held-packages kubelet || /bin/true
apt remove -y --purge --allow-change-held-packages kubeadm  || /bin/true
apt remove -y --purge --allow-change-held-packages kubectl  || /bin/true
apt remove -y --purge --allow-change-held-packages kubernetes-cni || /bin/true
apt remove -y --purge --allow-change-held-packages containerd.io  || /bin/true
apt remove -y --purge --allow-change-held-packages docker-ce  || /bin/true
apt remove -y --purge --allow-change-held-packages cri-o  || /bin/true
apt remove -y --purge --allow-change-held-packages cri-o-runc || /bin/true

# 移除相关目录和文件
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /var/lib/kubelet
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -rf /run/docker
rm -rf /run/flannel/
rm -rf /run/containerd
rm -f /run/docker.sock /run/dockershim.sock
rm -rf /etc/crio/
rm -f /etc/crictl.yaml
rm -rf /opt/cni /opt/containerd
rm -rf /etc/cni /var/lib/cni
rm -rf /var/lib/containerd/
rm -rf ~/.kube
```

