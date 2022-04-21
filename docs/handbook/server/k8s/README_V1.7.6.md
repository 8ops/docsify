

# K8S 安装笔记

## 1. 基础环境准备

### WORK DIR: 

```
/data/k8s
    ├── bin
    └── conf
```

### HOST LIST:

+ 10.10.20.101
+ 10.10.20.102
+ 10.10.20.103

### VERSION

+ etcd: 3.2.7 [Github](https://github.com/coreos/etcd)
+ flannel: v0.9.0 [Github](https://github.com/coreos/flannel)
+ kubernetes: 1.7.6 [Github](https://github.com/kubernetes/kubernetes)
+ docker: 17.06.2-ce [Github](https://github.com/docker/docker-install) [Download](https://download.docker.com/linux/static/stable/x86_64/)
+ kubedns [Github](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons)
+ dashboard
+ heapster
+ efk
+ harbor: v1.2.0 [Github](https://github.com/vmware/harbor)
+ docker-compose: 1.16.1 [Github](https://github.com/docker/compose)


mkdir -p /data/k8s/{conf,etc,bin,src}
cd /data/k8s

```bash
cat > rsync.sh <<EOF
#!/bin/bash
chown jesse.jesse -R /data/k8s
for host in 10.10.20.102 10.10.20.103
do
    echo "==== \$host ===="
    su jesse -c 'ssh -p 50022 jesse@'\$host' "sudo mkdir -p /data/k8s/{bin,conf,etc/kubernetes/ssl};sudo chown -R jesse.jesse /data/k8s"'
    su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/bin/ jesse@'\$host':/data/k8s/bin/'
    su jesse -c 'scp -P 50022 /data/k8s/etc/kubernetes/ssl/ca* jesse@'\$host':/data/k8s/etc/kubernetes/ssl/'

    cp ~/.kube/config /tmp/kube-config
    chown jesse.jesse /tmp/kube-config
    su jesse -c 'scp -P 50022 /tmp/kube-config jesse@'\$host':/tmp/'
    su jesse -c 'ssh -p 50022 jesse@'\$host' "sudo mkdir -p /root/.kube;sudo cp /tmp/kube-config /root/.kube/config"'
done
EOF

host=10.10.20.102;su jesse -c 'rsync -av --delete -e "ssh -p 50022" /data/k8s/src/ jesse@'$host':/data/k8s/src/'

```

chmod +x ./rsync.sh

> 生成密钥

head -c 16 /dev/urandom | od -An -t x | tr -d ' '

```bash
cat > bin/env-k8s-ext.sh <<EOF
BOOTSTRAP_TOKEN="1396c3a5f1a347d4a59286da231b33c8"
SERVICE_CIDR="10.3.0.0/16"
CLUSTER_CIDR="10.4.0.0/16"
NODE_PORT_RANGE="30000-50000"
ETCD_ENDPOINTS="https://10.10.20.101:2379,https://10.10.20.102:2379,https://10.10.20.103:2379"
FLANNEL_ETCD_PREFIX="/kubernetes/network"
CLUSTER_KUBERNETES_SVC_IP="10.3.0.1"
CLUSTER_DNS_SVC_IP="10.3.0.2"
CLUSTER_DNS_DOMAIN="cluster.local."
EOF

cat > bin/env-k8s.sh <<EOF
echo "Init K8S env..."
K8S_HOME=/data/k8s
NODE_IPS="10.10.20.101 10.10.20.102 10.10.20.103"
ETCD_NODES=etcd-101=https://10.10.20.101:2380,etcd-102=https://10.10.20.102:2380,etcd-103=https://10.10.20.103:2380

export PATH=\${K8S_HOME}/bin:\$PATH
export NODE_NAME=\$(ifconfig em1 | sed -n "2,2p" | awk '{print \$2}' | awk -F'.' '{print "etcd-"\$4}')
export NODE_IP=\$(ifconfig em1 | sed -n "2,2p" | awk '{print \$2}')
export MASTER_IP=\${NODE_IP}
export KUBE_APISERVER="https://\${MASTER_IP}:6443"

. /data/k8s/bin/env-k8s-ext.sh

EOF

# 随终端加载环境
grep -q env-k8s.sh ~/.bashrc || echo ". /data/k8s/bin/env-k8s.sh" >> ~/.bashrc

# 手动加载环境
. ~/.bashrc

```

## 2. ca

wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O ${K8S_HOME}/bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O ${K8S_HOME}/bin/cfssljson
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O ${K8S_HOME}/bin/cfssl-certinfo
chmod +x ${K8S_HOME}/bin/cfssl*

cfssl print-defaults config > ${K8S_HOME}/conf/config.json
cfssl print-defaults csr > ${K8S_HOME}/conf/csr.json

```bash
cat > ${K8S_HOME}/conf/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

cat > ${K8S_HOME}/conf/ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
# CA 证书拷贝到每个节点
cfssl gencert -initca conf/ca-csr.json | cfssljson -bare ${K8S_HOME}/conf/ca
mkdir -p ${K8S_HOME}/etc/kubernetes/ssl
/bin/cp ${K8S_HOME}/conf/ca* ${K8S_HOME}/etc/kubernetes/ssl

# 查看CA证书信息
openssl x509  -noout -text -in ${K8S_HOME}/conf/ca.pem
cfssl-certinfo -cert ${K8S_HOME}/conf/ca.pem
openssl x509 -noout -text -in ${K8S_HOME}/conf/ca.pem

```

## 3. etcd

```bash
ETC_VERSION=v3.2.7
[ ! -e ${K8S_HOME}/src/etcd-${ETC_VERSION}-linux-amd64.tar.gz ] && \
wget https://github.com/coreos/etcd/releases/download/${ETC_VERSION}/etcd-${ETC_VERSION}-linux-amd64.tar.gz \
-O ${K8S_HOME}/src/etcd-${ETC_VERSION}-linux-amd64.tar.gz
tar xvzf ${K8S_HOME}/src/etcd-${ETC_VERSION}-linux-amd64.tar.gz -C ${K8S_HOME}/src/
/bin/cp ${K8S_HOME}/src/etcd-${ETC_VERSION}-linux-amd64/etcd* ${K8S_HOME}/bin/

```

```bash
cat > ${K8S_HOME}/conf/etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
# 每个节点上的签名证书需要单独颁发
cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes ${K8S_HOME}/conf/etcd-csr.json | cfssljson -bare ${K8S_HOME}/conf/etcd

mkdir -p ${K8S_HOME}/etc/etcd/ssl
/bin/cp ${K8S_HOME}/conf/etcd*.pem ${K8S_HOME}/etc/etcd/ssl

```

```bash
cat > ${K8S_HOME}/etc/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/data/etcd
ExecStart=${K8S_HOME}/bin/etcd \\
  --name=${NODE_NAME} \\
  --cert-file=${K8S_HOME}/etc/etcd/ssl/etcd.pem \\
  --key-file=${K8S_HOME}/etc/etcd/ssl/etcd-key.pem \\
  --peer-cert-file=${K8S_HOME}/etc/etcd/ssl/etcd.pem \\
  --peer-key-file=${K8S_HOME}/etc/etcd/ssl/etcd-key.pem \\
  --trusted-ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --peer-trusted-ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --initial-advertise-peer-urls=https://${NODE_IP}:2380 \\
  --listen-peer-urls=https://${NODE_IP}:2380 \\
  --listen-client-urls=https://${NODE_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls=https://${NODE_IP}:2379 \\
  --initial-cluster-token=etcd-cluster-0 \\
  --initial-cluster=${ETCD_NODES} \\
  --initial-cluster-state=new \\
  --data-dir=/data/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/etcd.service
cp ${K8S_HOME}/etc/etcd.service /etc/systemd/system/etcd.service

rm -rf /data/etcd 
mkdir -p /data/etcd

systemctl daemon-reload
systemctl start etcd
systemctl status etcd

for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
  --cert=${K8S_HOME}/etc/etcd/ssl/etcd.pem \
  --key=${K8S_HOME}/etc/etcd/ssl/etcd-key.pem \
  endpoint health
done

ETCDCTL_API=3 etcdctl \
--cacert=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert=${K8S_HOME}/etc/etcd/ssl/etcd.pem \
--key=${K8S_HOME}/etc/etcd/ssl/etcd-key.pem \
--endpoints=${ETCD_ENDPOINTS} \
member list

```

## 4. flannel

```bash
FLANNEL_VERSION=v0.9.0
[ ! -e ${K8S_HOME}/src/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz ] && \
wget https://github.com/coreos/flannel/releases/download/${FLANNEL_VERSION}/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz \
-O ${K8S_HOME}/src/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz
tar xvzf ${K8S_HOME}/src/flannel-${FLANNEL_VERSION}-linux-amd64.tar.gz -C ${K8S_HOME}/src/
/bin/cp ${K8S_HOME}/src/{mk-docker-opts.sh,flanneld} ${K8S_HOME}/bin/

```

```
cat > ${K8S_HOME}/conf/flanneld-csr.json <<EOF
{
  "CN": "flanneld",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes ${K8S_HOME}/conf/flanneld-csr.json | cfssljson -bare ${K8S_HOME}/conf/flanneld

mkdir -p ${K8S_HOME}/etc/flanneld/ssl
/bin/cp ${K8S_HOME}/conf/flanneld*.pem ${K8S_HOME}/etc/flanneld/ssl

# 只需要一次写入

etcdctl \
--endpoints=${ETCD_ENDPOINTS} \
--ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert-file=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \
--key-file=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \
set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'

etcdctl \
--endpoints=${ETCD_ENDPOINTS} \
--ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert-file=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \
--key-file=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \
ls ${FLANNEL_ETCD_PREFIX}

etcdctl \
--endpoints=${ETCD_ENDPOINTS} \
--ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert-file=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \
--key-file=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \
get ${FLANNEL_ETCD_PREFIX}/config

```

```bash
cat > ${K8S_HOME}/etc/flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=${K8S_HOME}/bin/flanneld \\
  -etcd-cafile=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  -etcd-certfile=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \\
  -etcd-keyfile=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \\
  -etcd-endpoints=${ETCD_ENDPOINTS} \\
  -etcd-prefix=${FLANNEL_ETCD_PREFIX} \\
  -iface=em1
ExecStartPost=${K8S_HOME}/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF

```

```bash
rm -f /etc/systemd/system/flanneld.service
cp ${K8S_HOME}/etc/flanneld.service /etc/systemd/system/flanneld.service

systemctl daemon-reload
systemctl start flanneld
systemctl status flanneld

ip a

etcdctl \
--endpoints=${ETCD_ENDPOINTS} \
--ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert-file=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \
--key-file=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \
ls ${FLANNEL_ETCD_PREFIX}/subnets/

etcdctl \
--endpoints=${ETCD_ENDPOINTS} \
--ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--cert-file=${K8S_HOME}/etc/flanneld/ssl/flanneld.pem \
--key-file=${K8S_HOME}/etc/flanneld/ssl/flanneld-key.pem \
get \
/kubernetes/network/subnets/10.4.36.0-24

{"PublicIP":"10.10.20.101","BackendType":"vxlan","BackendData":{"VtepMAC":"ce:71:25:6b:50:b6"}}

```

## 5. master

`kube-apiserver`,`kube-controller-manager`,`kube-schedule`,`docker`

### kubectl

```bash
KUBERNETES_VERSION=v1.7.6
[ ! -e ${K8S_HOME}/src/kubernetes-client-linux-amd64.tar.gz ] && \
wget https://dl.k8s.io/${KUBERNETES_VERSION}/kubernetes-client-linux-amd64.tar.gz \
-O ${K8S_HOME}/src/kubernetes-client-linux-amd64.tar.gz
tar xvzf ${K8S_HOME}/src/kubernetes-client-linux-amd64.tar.gz -C ${K8S_HOME}/src/
/bin/cp ${K8S_HOME}/src/kubernetes/client/bin/* ${K8S_HOME}/bin/

or 

KUBERNETES_VERSION=v1.7.6
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl \
-o ${K8S_HOME}/bin/kubectl

```

```bash
cat > ${K8S_HOME}/conf/admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes ${K8S_HOME}/conf/admin-csr.json | cfssljson -bare ${K8S_HOME}/conf/admin

/bin/cp ${K8S_HOME}/conf/admin*.pem ${K8S_HOME}/etc/kubernetes/ssl/

# 集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER}

# 客户端认证
kubectl config set-credentials admin \
--client-certificate=${K8S_HOME}/etc/kubernetes/ssl/admin.pem \
--embed-certs=true \
--client-key=${K8S_HOME}/etc/kubernetes/ssl/admin-key.pem

# 上下文参数
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=admin

# 默认使用
kubectl config use-context kubernetes

```

同步 `~/.kube/config` 至其它节点

### kube-apiserver

```bash
cat > ${K8S_HOME}/conf/kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${MASTER_IP}",
    "${CLUSTER_KUBERNETES_SVC_IP}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/kubernetes-csr.json | cfssljson -bare ${K8S_HOME}/conf/kubernetes

/bin/cp ${K8S_HOME}/conf/kubernetes*.pem ${K8S_HOME}/etc/kubernetes/ssl/

# 同步至其它节点
cat > ${K8S_HOME}/conf/token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
/bin/cp ${K8S_HOME}/conf/token.csv ${K8S_HOME}/etc/kubernetes/

KUBERNETES_VERSION=v1.7.6
[ ! -e ${K8S_HOME}/src/kubernetes-${KUBERNETES_VERSION}.tar.gz ] && \
wget https://github.com/kubernetes/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz \
-O ${K8S_HOME}/src/kubernetes-${KUBERNETES_VERSION}.tar.gz
tar xvzf ${K8S_HOME}/src/kubernetes-${KUBERNETES_VERSION}.tar.gz -C ${K8S_HOME}/src
cd kubernetes && ./cluster/get-kube-binaries.sh # online install
cd .. && tar xvzf server/kubernetes-server-linux-amd64.tar.gz -C server/
find client/bin -perm /+x -type f -exec /bin/cp {} ${K8S_HOME}/bin/ \;
find server/kubernetes/server/bin -perm /+x -type f -exec /bin/cp {} ${K8S_HOME}/bin/ \;

or

KUBERNETES_VERSION=v1.7.6
[ ! -e ${K8S_HOME}/src/kubernetes-server-linux-amd64-${KUBERNETES_VERSION}.tar.gz ] && \
wget https://dl.k8s.io/${KUBERNETES_VERSION}/kubernetes-server-linux-amd64.tar.gz \
-O ${K8S_HOME}/src/kubernetes-server-linux-amd64-${KUBERNETES_VERSION}.tar.gz
tar xvzf ${K8S_HOME}/src/kubernetes-server-linux-amd64-${KUBERNETES_VERSION}.tar.gz -C ${K8S_HOME}/src/
find ${K8S_HOME}/src/kubernetes/server/bin/ -perm /+x -type f -exec /bin/cp {} ${K8S_HOME}/bin/ \;

```

```bash
cat  > ${K8S_HOME}/etc/kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=${K8S_HOME}/bin/kube-apiserver \\
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --advertise-address=${MASTER_IP} \\
  --bind-address=${MASTER_IP} \\
  --insecure-bind-address=${MASTER_IP} \\
  --authorization-mode=RBAC \\
  --runtime-config=rbac.authorization.k8s.io/v1alpha1 \\
  --kubelet-https=true \\
  --experimental-bootstrap-token-auth \\
  --token-auth-file=${K8S_HOME}/etc/kubernetes/token.csv \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=${NODE_PORT_RANGE} \\
  --tls-cert-file=${K8S_HOME}/etc/kubernetes/ssl/kubernetes.pem \\
  --tls-private-key-file=${K8S_HOME}/etc/kubernetes/ssl/kubernetes-key.pem \\
  --client-ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --service-account-key-file=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \\
  --etcd-cafile=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --etcd-certfile=${K8S_HOME}/etc/kubernetes/ssl/kubernetes.pem \\
  --etcd-keyfile=${K8S_HOME}/etc/kubernetes/ssl/kubernetes-key.pem \\
  --etcd-servers=${ETCD_ENDPOINTS} \\
  --enable-swagger-ui=true \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/tmp/audit.log \\
  --event-ttl=1h \\
  --v=0
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/kube-apiserver.service
cp ${K8S_HOME}/etc/kube-apiserver.service /etc/systemd/system/kube-apiserver.service

systemctl daemon-reload
systemctl start kube-apiserver
systemctl status kube-apiserver

kubectl get rc,po,svc,ds,deployment,secret --all-namespaces -o wide

```

### kube-controller-manager

```bash
cat > ${K8S_HOME}/etc/kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${K8S_HOME}/bin/kube-controller-manager \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_IP}:8080 \\
  --allocate-node-cidrs=true \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --cluster-signing-key-file=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \\
  --service-account-private-key-file=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \\
  --root-ca-file=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \\
  --leader-elect=true \\
  --v=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/kube-controller-manager.service
cp ${K8S_HOME}/etc/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service

systemctl daemon-reload
systemctl start kube-controller-manager
systemctl status kube-controller-manager

kubectl get componentstatuses

or 

kubectl get cs

```

### kube-scheduler

```bash
cat > ${K8S_HOME}/etc/kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${K8S_HOME}/bin/kube-scheduler \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_IP}:8080 \\
  --leader-elect=true \\
  --v=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/kube-scheduler.service
cp ${K8S_HOME}/etc/kube-scheduler.service /etc/systemd/system/kube-scheduler.service

systemctl daemon-reload
systemctl start kube-scheduler
systemctl status kube-scheduler

kubectl get cs

NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-1               Healthy   {"health": "true"}
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
```

## 6. node

`flanneld`,`docker`,`kubelet`,`kube-proxy` 

`这里 MASTER & NODE 共用机器，节点名称就用 etc，环境继续使用 master 的环境`，可以考虑在docker启动后通过docker-compose启动harbor

### docker

```bash
DOCKER_VERSION=17.06.2-ce
[ ! -e ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz ] && \
wget https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
-O ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz
tar xvzf ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz -C ${K8S_HOME}/src/
/bin/cp ${K8S_HOME}/src/docker/docker* bin/

or

DOCKER_VERSION=17.06.2-ce
[ ! -e ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz ] && \
wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
-O ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz
tar xvzf ${K8S_HOME}/src/docker-${DOCKER_VERSION}.tgz -C ${K8S_HOME}/src/
/bin/cp ${K8S_HOME}/src/docker/docker* bin/

```

```bash
cat > ${K8S_HOME}/etc/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=${K8S_HOME}/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/flannel/docker
ExecStart=${K8S_HOME}/bin/dockerd \\
  --log-level=error \\
  --insecure-registry r.k8s.8ops.cc \\
  --insecure-registry r.8ops.cc \\
  --data-root=/data/docker \\
  --storage-driver=overlay \\
  \$DOCKER_NETWORK_OPTIONS
ExecStartPost=/sbin/iptables -P FORWARD ACCEPT
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/docker.service
cp ${K8S_HOME}/etc/docker.service /etc/systemd/system/docker.service

rm -rf /data/docker 
mkdir -p /data/docker

systemctl daemon-reload
systemctl start docker
systemctl status docker

# 后面版本的docker默认策略为DROP，需要手动变更
iptables -P FORWARD ACCEPT 

```

### kubelet

```
# 每个Node执行
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
kubectl get clusterrolebinding
kubectl get clusterrolebinding | grep kubelet-bootstrap


NAME                                           AGE
cluster-admin                                  15h
kubelet-bootstrap                              7s
system:basic-user                              15h
system:controller:attachdetach-controller      15h
system:controller:certificate-controller       15h
system:controller:cronjob-controller           15h
system:controller:daemon-set-controller        15h
system:controller:deployment-controller        15h
system:controller:disruption-controller        15h
system:controller:endpoint-controller          15h
system:controller:generic-garbage-collector    15h
system:controller:horizontal-pod-autoscaler    15h
system:controller:job-controller               15h
system:controller:namespace-controller         15h
system:controller:node-controller              15h
system:controller:persistent-volume-binder     15h
system:controller:pod-garbage-collector        15h
system:controller:replicaset-controller        15h
system:controller:replication-controller       15h
system:controller:resourcequota-controller     15h
system:controller:route-controller             15h
system:controller:service-account-controller   15h
system:controller:service-controller           15h
system:controller:statefulset-controller       15h
system:controller:ttl-controller               15h
system:discovery                               15h
system:kube-controller-manager                 15h
system:kube-dns                                15h
system:kube-scheduler                          15h
system:node                                    15h
system:node-proxier                            15h

```

```bash
# 每个Node执行 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=${K8S_HOME}/conf/bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
--token=${BOOTSTRAP_TOKEN} \
--kubeconfig=${K8S_HOME}/conf/bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=${K8S_HOME}/conf/bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default \
--kubeconfig=${K8S_HOME}/conf/bootstrap.kubeconfig

/bin/cp ${K8S_HOME}/conf/bootstrap.kubeconfig ${K8S_HOME}/etc/kubernetes/

```

```bash
cat > ${K8S_HOME}/etc/kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/data/kubelet
ExecStart=${K8S_HOME}/bin/kubelet \\
  --address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --pod-infra-container-image=r.k8s.8ops.cc/library/pod-infrastructure:latest \\
  --experimental-bootstrap-kubeconfig=${K8S_HOME}/etc/kubernetes/bootstrap.kubeconfig \\
  --kubeconfig=${K8S_HOME}/etc/kubernetes/kubelet.kubeconfig \\
  --require-kubeconfig \\
  --cert-dir=${K8S_HOME}/etc/kubernetes/ssl \\
  --cluster-dns=${CLUSTER_DNS_SVC_IP} \\
  --cluster-domain=${CLUSTER_DNS_DOMAIN} \\
  --hairpin-mode promiscuous-bridge \\
  --allow-privileged=true \\
  --serialize-image-pulls=false \\
  --logtostderr=true \\
  --root-dir=/data/kubelet \\
  --v=0
ExecStartPost=/sbin/iptables -A INPUT -s 10.10.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -s 10.3.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -s 10.4.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -s 192.168.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -p tcp --dport 4194 -j DROP
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/kubelet.service
cp ${K8S_HOME}/etc/kubelet.service /etc/systemd/system/kubelet.service

rm -rf /data/kubelet 
mkdir /data/kubelet

systemctl daemon-reload
systemctl start kubelet
systemctl status kubelet

kubectl get csr

NAME                                                   AGE       REQUESTOR           CONDITION
node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI   1h        kubelet-bootstrap   Pending
node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI   21m       kubelet-bootstrap   Pending
node-csr-neHMIX3ditVK8N7DQyi9Is_BgLozHnUKxYjGFxwX26k   3m        kubelet-bootstrap   Pending

kubectl certificate approve node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI
kubectl certificate approve node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI

kubectl get csr

NAME                                                   AGE       REQUESTOR           CONDITION
node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI   1h        kubelet-bootstrap   Approved,Issued
node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI   21m       kubelet-bootstrap   Approved,Issued
node-csr-neHMIX3ditVK8N7DQyi9Is_BgLozHnUKxYjGFxwX26k   3m        kubelet-bootstrap   Pending

kubectl get no

NAME           STATUS    AGE       VERSION
10.10.20.102   Ready     2m        v1.7.3
10.10.20.103   Ready     2m        v1.7.3
```

### kube-proxy

```bash
cat > ${K8S_HOME}/conf/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shanghai",
      "L": "Shanghai",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

```bash
cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes ${K8S_HOME}/conf/kube-proxy-csr.json | cfssljson -bare ${K8S_HOME}/conf/kube-proxy
/bin/cp ${K8S_HOME}/conf/kube-proxy*.pem ${K8S_HOME}/etc/kubernetes/ssl/

# 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=${K8S_HOME}/conf/kube-proxy.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
--client-certificate=${K8S_HOME}/etc/kubernetes/ssl/kube-proxy.pem \
--client-key=${K8S_HOME}/etc/kubernetes/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=${K8S_HOME}/conf/kube-proxy.kubeconfig

# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=${K8S_HOME}/conf/kube-proxy.kubeconfig

# 设置默认上下文
kubectl config use-context default \
--kubeconfig=${K8S_HOME}/conf/kube-proxy.kubeconfig
/bin/cp ${K8S_HOME}/conf/kube-proxy.kubeconfig ${K8S_HOME}/etc/kubernetes/

```

```bash
cat > ${K8S_HOME}/etc/kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/data/kube-proxy
ExecStart=${K8S_HOME}/bin/kube-proxy \\
  --bind-address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --cluster-cidr=${SERVICE_CIDR} \\
  --kubeconfig=${K8S_HOME}/etc/kubernetes/kube-proxy.kubeconfig \\
  --logtostderr=true \\
  --v=0
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

```bash
rm -f /etc/systemd/system/kube-proxy.service
cp ${K8S_HOME}/etc/kube-proxy.service /etc/systemd/system/kube-proxy.service

rm -rf /data/kube-proxy 
mkdir -p /data/kube-proxy

systemctl daemon-reload
systemctl start kube-proxy
systemctl status kube-proxy

systemctl enable kube-proxy

```

## 7. harbor

`这里固定把harbor部署在10.10.20.101机器` 在Node节点添加之前搭建，后面要以直接引用此harbor做为内部镜像地址

```bash
DOCKER_COMPOSE_VERSION=1.16.1
curl -sL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
-o ${K8S_HOME}/bin/docker-compose
chmod +x ${K8S_HOME}/bin/docker-compose

Harbor UI : admin / Harbor12345
Mysql root: root  / root123

HARBOR_VERSION=v1.2.0
wget https://github.com/vmware/harbor/releases/download/${HARBOR_VERSION}/harbor-offline-installer-${HARBOR_VERSION}.tgz \
-O ${K8S_HOME}/src/harbor-offline-installer-${HARBOR_VERSION}.tgz
tar xvzf ${K8S_HOME}/src/harbor-offline-installer-${HARBOR_VERSION}.tgz -C ${K8S_HOME}/src/

cd ${K8S_HOME}/src/harbor

rm -rf /data/harbor && mkdir -p /data/harbor

# 配置文件的路径引用 /data 变更为 /data/harbor

# 使用认证过的证书
ls ${K8S_HOME}/etc/harbor/ssl
r.k8s.8ops.cc.pem
r.k8s.8ops.cc.key

```

> vim docker-compose.yml
> vim docker-compose.notary.yml
> vim harbor.cfg
```
hostname = r.k8s.8ops.cc

ui_url_protocol = https

ssl_cert = /data/k8s/etc/harbor/ssl/r.k8s.8ops.cc.crt
ssl_cert_key = /data/harbor/etc/harbor/ssl/r.k8s.8ops.cc.key

secretkey_path = /data/harbor

email_server = smtp.exmail.qq.com
email_server_port = 465
email_username = k8s@8ops.cc
email_password =password 
email_from = K8S <k8s@8ops.cc>
email_ssl = true


```

```bash
./prepare

./install.sh

docker-compose down
docker-compose up -d

docker login r.k8s.8ops.cc -u jesse -p password 

docker images | awk '$1~/^vmware/{printf("docker tag %s r.k8s.8ops.cc/%s:%s\ndocker push r.k8s.8ops.cc/%s:%s\n",$3,$1,$2,$1,$2)}'
docker images | awk '$1~/^gcr\.io/{printf("docker tag %s r.k8s.8ops.cc/%s:%s\ndocker push r.k8s.8ops.cc/%s:%s\n",$3,substr($1,8,100),$2,substr($1,8,100),$2)}'
docker images | awk '$1~/^gcr\.io/&&$2~/v1\.7\.3/{printf("docker tag %s r.k8s.8ops.cc/%s:%s\ndocker push r.k8s.8ops.cc/%s:%s\n",$3,substr($1,8,100),$2,substr($1,8,100),$2)}'

```

## 8. dns

```bash
kubectl create secret \
docker-registry registrykey \
--namespace=kube-system \
--docker-server=r.k8s.8ops.cc \
--docker-username=jesse \
--docker-password=password \
--docker-email=jesse@8ops.cc

kubectl create secret \
docker-registry registrykey \
--namespace=default \
--docker-server=r.k8s.8ops.cc \
--docker-username=jesse \
--docker-password=password \
--docker-email=jesse@8ops.cc

```

`dnsmasq`

参考 yaml 文件见：[dns](https://github.com/xtso520ok/jesse-bin/tree/jesse/apps/k8s/backup/k8s/yml/kubedns)

## 9. dashbaord

参考 yaml 文件见：[dashboard](https://github.com/xtso520ok/jesse-bin/tree/jesse/apps/k8s/backup/k8s/yml/dashboard)

## 10. heapster

参考 yaml 文件见：[dashboard](https://github.com/xtso520ok/jesse-bin/tree/jesse/apps/k8s/backup/k8s/yml/heapster)

kubectl cluster-info

`再重启 dashboard, dashboard 启动时要加载heapster`

kubectl proxy --address="10.10.20.101" --port=8086 --accept-paths="^.*"

[grafana](http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana)

[influxdb](http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:8083/)

## 11. efk

参考 yaml 文件见：[efk](https://github.com/xtso520ok/jesse-bin/tree/jesse/apps/k8s/backup/k8s/yml/EFK)

[kibana](http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/kibana-logging)
[kibana 02](http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/kibana-logging:5601)

kubectl get no --show-labels
kubectl label no 10.10.20.102 beta.kubernetes.io/fluentd-ds-ready=true

`查看日志`

> curl -i 'http://10.4.36.4:9200/_cat/indices?v'

[elasticseach](http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging:9200/_cat/indices?v)

> http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging:9200
> http://8080.k8s.8ops.cc/api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging:9200/_search?q=*&pretty=on

```bash
curl -i -X DELETE 'http://172.18.22.6:9200/logstash-2017.08.28'
curl -i -X DELETE 'http://172.18.28.4:9200/logstash-2017.08.28'

```

## 12. usage

`查看所有组件启动状态`

`master`

```bash
systemctl status etcd
systemctl status flanneld
systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler

systemctl enable etcd

```

`node`

```bash
systemctl status flanneld
systemctl status docker
systemctl status kubelet
systemctl status kube-proxy

kubectl get rc,po,svc,ep,ds,deployment,secret,ing --all-namespaces -o wide
kubectl get no,ns -o wide --show-labels=true

kubectl get cs

kubectl get clusterrolebinding

```

## 13. clean

```bash

# 1
systemctl disable kube-proxy
systemctl disable kubelet
systemctl disable docker
systemctl disable flanneld
systemctl disable kube-scheduler
systemctl disable kube-controller-manager
systemctl disable kube-apiserver
systemctl disable etcd

# 2
systemctl stop kube-proxy
systemctl stop kubelet
systemctl stop docker
systemctl stop flanneld
systemctl stop kube-scheduler
systemctl stop kube-controller-manager
systemctl stop kube-apiserver
systemctl stop etcd

# 3
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

iptables -vnxL
iptables -t nat -vnxL

# 4
rm -rf /data/{etcd,kubelet,kube-proxy}

###
systemctl enable kube-proxy
systemctl enable kubelet
systemctl enable docker
systemctl enable flanneld
systemctl enable kube-scheduler
systemctl enable kube-controller-manager
systemctl enable kube-apiserver
systemctl enable etcd

systemctl status kube-proxy
systemctl status kubelet
systemctl status docker
systemctl status flanneld
systemctl status kube-scheduler
systemctl status kube-controller-manager
systemctl status kube-apiserver
systemctl status etcd

/etc/systemd/system/kube-proxy.service

```



