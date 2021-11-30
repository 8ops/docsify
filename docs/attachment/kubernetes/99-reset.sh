#!/bin/bash

# set -ex

# kubernetes cluster reset
command -v kubeadm && kubeadm reset --force --cri-socket /run/containerd/containerd.sock
# kubeadm reset --force --cri-socket /var/run/dockershim.sock

# release network
ip link delete flannel.1
ip link delete cni0
ip link delete kube-ipvs0

# release fireward
iptables -F && ipvsadm -C && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t mangle -F && iptables -t mangle -X

# crictl images | awk 'NR>1{printf("crictl rmi %s\n",$3)}' |sh

# stop services
systemctl stop kubelet
systemctl stop docker
systemctl stop containerd

# unhold packages
apt-mark unhold kubeadm
apt-mark unhold kubectl
apt-mark unhold kubelet
apt-mark unhold docker
apt-mark unhold containerd

# showhold
apt-mark showhold

# remove held packages
apt remove -y --purge --allow-change-held-packages kubelet || /bin/true
apt remove -y --purge --allow-change-held-packages kubeadm  || /bin/true
apt remove -y --purge --allow-change-held-packages kubectl  || /bin/true
apt remove -y --purge --allow-change-held-packages kubernetes-cni || /bin/true
apt remove -y --purge --allow-change-held-packages containerd  || /bin/true
apt remove -y --purge --allow-change-held-packages docker-ce  || /bin/true
apt remove -y --purge --allow-change-held-packages cri-o  || /bin/true
apt remove -y --purge --allow-change-held-packages cri-o-runc || /bin/true

# show release detail
dpkg -l | awk '$2~/kube|cni|cri|containerd|docker/'

# release auto-remove
apt auto-remove -y

# release dirs and files
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /var/lib/kubelet
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -rf /run/docker
rm -rf /run/flannel
rm -rf /run/containerd
rm -f /run/docker.sock /run/dockershim.sock
rm -rf /etc/crio/
rm -f /etc/crictl.yaml
rm -rf /opt/cni /etc/cni /var/lib/cni
rm -rf /opt/containerd /etc/containerd /run/containerd /var/lib/containerd
rm -rf /var/lib/containerd
rm -rf ~/.kube /etc/kubernetes
rm -rf ~/.cache/helm
