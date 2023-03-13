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

#1，停第1台静态容器
cd /etc/kubernetes
mv manifests manifests-20230310
# 现象：集群正常，etcd leader 飘移
# 原因：etcd leader 成功飘移（etcd leader 刚好在停掉的节点上）

#2，停第2台静态容器
cd /etc/kubernetes
mv manifests manifests-20230310
# 现象：集群崩溃，etcd leader 消失
# 原因：etcd learner/leader 角色未发生变化，etcd luster节点数量小于2 etcd 集群不存在leader无法正常工作
```

> 恢复故障

```bash
#1，恢复第2台静态容器
cd /etc/kubernetes
rsync -av manifests-20230310/ manifests/
# 现象：集群正常，etcd leader 出现
# 原因：etcd leader 未发生飘移 ，etcd luster节点数量为2

#2，恢复第1台静态容器
cd /etc/kubernetes
rsync -av manifests-20230310/ manifests/
# 现象：集群正常
```



### 2.2 场景二：终止全部 control-plane 节点

参考场景一，当恢复到第2台 control-plane 时集群恢复可用。



### 2.3 场景三：挪用其他节点证书恢复

**不可行**

> 模拟故障

```bash
# 在其中一个节点上操作

#1，停掉control-plane
cd /etc/kubernetes
mv manifests manifests-20230310
# 现象：集群正常，摘掉1个control-plane

#2，备份证书
mv pki pki-20230310
```



> 恢复故障

```bash
#1，从其他节点恢复证书
scp /etc/kubernetes/pki

#2，恢复control-plane
cd /etc/kubernetes
rsync -av manifests-20230310/ manifests/
# 现象：集群正常，摘掉control-plane未恢复
# 原因：拷贝过来的证书签名中 X509v3 Subject Alternative Name 未包含当前节点信息
```



### 2.4 场景三：当集群不可用时 join 新节点

**不可行**

```bash
kubeadm init phase upload-certs --upload-certs

# I0310 17:40:27.320512 1479993 version.go:256] remote version is much newer: v1.26.2; falling back to: stable-1.25
# [upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
# error execution phase upload-certs: error uploading certs: error creating token: timed out waiting for the condition
# To see the stack trace of this error execute with --v=5 or higher

# 现象：无法join
# 原因：无法往etcd插入节点数据
```

