# 实战 | 维护集群关键问题

## 一、信息查看

kubernetes 所有组件中只会有 ETCD 存在 leader 选举

```bash
etcdctl member list \
  --endpoints=https://10.101.11.240:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

etcdctl endpoint status \
  --cluster \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

etcdctl endpoint status \
  --endpoints=https://10.101.11.240:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# 切换leader
etcdctl move-leader ed1afb9abd383490 \
  --endpoints=https://10.101.11.240:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
  
# The items in the lists are endpoint, ID, version, db size, is leader, is learner, raft term, raft index, raft applied index, errors.

# 节点信息
K-KUBE-LAB-01 10.101.11.240
K-KUBE-LAB-02 10.101.11.114
K-KUBE-LAB-03 10.101.11.154

K-KUBE-LAB-201 10.101.11.238
K-KUBE-LAB-202 10.101.11.93
K-KUBE-LAB-203 10.101.11.53

```



## 二、MOCK场景

kubernetes cluster 在运行过程中会有很多异常情况，此处用于模拟异常并尝试恢复。

当control-plane不可用时，集群中业务的pod不受影响，流量正常接入。



### 2.1 场景一：终止部分control-plane节点

> 模拟故障

```bash
# 共3台control-plane
# 停第一台
cd /etc/kubernetes
mv manifests manifests-20230310
# etcd leader 成功飘移 集群正常

# 停第二台
cd /etc/kubernetes
mv manifests manifests-20230310
# etcd learner/leader 集群崩溃
```

> 恢复故障

```bash
# 恢复第二台
cd /etc/kubernetes
rsync -av manifests-20230310/ manifests/
# etcd leader 未发生飘移 集群正常

# 恢复第一台
cd /etc/kubernetes
rsync -av manifests-20230310/ manifests/
# etcd leader 未发生飘移 集群正常
```



### 2.2 场景二：终止全部control-plane节点

参考场景一当恢复到第二台control-plane时集群恢复可用。



### 2.3 场景三：挪用其他节点证书恢复





### 2.4 场景三：当集群不可用时join新节点

```bash
kubeadm init phase upload-certs --upload-certs
# I0310 17:40:27.320512 1479993 version.go:256] remote version is much newer: v1.26.2; falling back to: stable-1.25
# [upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
# error execution phase upload-certs: error uploading certs: error creating token: timed out waiting for the condition
# To see the stack trace of this error execute with --v=5 or higher

# 不可行
# 无法往etcd插入节点数据
```

