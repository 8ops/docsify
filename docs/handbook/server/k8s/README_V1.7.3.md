
systemctl stop flanneld
systemctl stop kube-controller-manager
systemctl stop kube-scheduler
systemctl stop kube-apiserver
systemctl stop etcd
ss -nutl

1, base env

dir: /data/k8s
        ├── bin
        └── conf

mkdir -p /data/k8s/bin /data/k8s/conf 
cd /data/k8s

head -c 16 /dev/urandom | od -An -t x | tr -d ' '

cat > bin/env.sh <<EOF
K8S_HOME=/data/k8s
NODE_IPS="10.10.20.101 10.10.20.102 10.10.20.103"
ETCD_NODES=etcd-101=https://10.10.20.101:2380,etcd-102=https://10.10.20.102:2380,etcd-103=https://10.10.20.103:2380

BOOTSTRAP_TOKEN="1396c3a5f1a347d4a59286da231b33c8"
SERVICE_CIDR="10.254.0.0/16"
CLUSTER_CIDR="172.30.0.0/16"
NODE_PORT_RANGE="8400-9000"
ETCD_ENDPOINTS="https://10.10.20.101:2379,https://10.10.20.102:2379,https://10.10.20.103:2379"
FLANNEL_ETCD_PREFIX="/kubernetes/network"
CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"
CLUSTER_DNS_SVC_IP="10.254.0.2"
CLUSTER_DNS_DOMAIN="cluster.local."
EOF

. bin/env.sh
PATH=${K8S_HOME}/bin:$PATH

2, cfssl


wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O bin/cfssljson
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O bin/cfssl-certinfo
chmod +x bin/cfssl*

mkdir -p conf/ssl

cfssl print-defaults config > conf/ssl/config.json
cfssl print-defaults csr > conf/ssl/csr.json

cat > conf/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > conf/ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -initca conf/ca-csr.json | cfssljson -bare ca

mkdir -p ${K8S_HOME}/etc/kubernetes/ssl
cp ca* conf/ca* ${K8S_HOME}/etc/kubernetes/ssl

# CA 证书拷贝到每个节点

openssl x509  -noout -text -in ca.pem
cfssl-certinfo -cert ca.pem
openssl x509 -noout -text -in ca.pem

3, etcd

wget https://github.com/coreos/etcd/releases/download/v3.2.5/etcd-v3.2.5-linux-amd64.tar.gz \
-O /tmp/etcd-v3.2.5-linux-amd64.tar.gz
tar xvzf /tmp/etcd-v3.2.5-linux-amd64.tar.gz -C /tmp
cp /tmp/etcd-v3.2.5-linux-amd64/etcd* bin/


export NODE_NAME=$(ifconfig em1 | sed -n "2,2p" | awk '{print $2}' | awk -F'.' '{print "etcd-"$4}')
export NODE_IP=$(ifconfig em1 | sed -n "2,2p" | awk '{print $2}')
. bin/env.sh

cat > conf/etcd-csr.json <<EOF
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/etcd-csr.json | cfssljson -bare etcd

mkdir -p ${K8S_HOME}/etc/etcd/ssl
cp etcd*.pem ${K8S_HOME}/etc/etcd/ssl

# 每个节点上的签名证书需要单独颁发

rm -rf /data/etcd
mkdir -p /data/etcd

cat > conf/etcd.service <<EOF
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

rm -f /etc/systemd/system/etcd.service
ln -s ${K8S_HOME}/conf/etcd.service /etc/systemd/system/etcd.service

systemctl daemon-reload
systemctl start etcd


for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 ${K8S_HOME}/bin/etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
  --cert=${K8S_HOME}/etc/etcd/ssl/etcd.pem \
  --key=${K8S_HOME}/etc/etcd/ssl/etcd-key.pem \
  endpoint health
done

4, flannel

wget https://github.com/coreos/flannel/releases/download/v0.8.0/flannel-v0.8.0-linux-amd64.tar.gz \
-O /tmp/flannel-v0.8.0-linux-amd64.tar.gz
tar xvzf /tmp/flannel-v0.8.0-linux-amd64.tar.gz -C /tmp
cp /tmp/{mk-docker-opts.sh,flanneld} bin/

cat > conf/flanneld-csr.json <<EOF
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/flanneld-csr.json | cfssljson -bare flanneld

mkdir -p ${K8S_HOME}/etc/flanneld/ssl
cp flanneld*.pem ${K8S_HOME}/etc/flanneld/ssl

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

cat > conf/flanneld.service << EOF
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

rm -f /etc/systemd/system/flanneld.service
ln -s ${K8S_HOME}/conf/flanneld.service /etc/systemd/system/flanneld.service

systemctl daemon-reload
systemctl start flanneld

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
get /kubernetes/network/subnets/172.30.23.0-24

==> {"PublicIP":"10.10.20.103","BackendType":"vxlan","BackendData":{"VtepMAC":"1a:72:af:1c:52:1f"}}

5, MASTER (kube-apiserver,kube-controller-manager,kube-schedule)

export MASTER_IP=${NODE_IP}
export KUBE_APISERVER="https://${MASTER_IP}:6443"

wget https://dl.k8s.io/v1.7.3/kubernetes-client-linux-amd64.tar.gz \
-O /tmp/kubernetes-client-linux-amd64.tar.gz
tar xvzf /tmp/kubernetes-client-linux-amd64.tar.gz -C /tmp/
cp /tmp/kubernetes/client/bin/* bin/

cat > conf/admin-csr.json <<EOF
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/admin-csr.json | cfssljson -bare admin

cp admin*.pem ${K8S_HOME}/etc/kubernetes/ssl/

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

sync ~/.kube/config to other nodes

cat > conf/kubernetes-csr.json <<EOF
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/kubernetes-csr.json | cfssljson -bare kubernetes

/bin/cp kubernetes*.pem ${K8S_HOME}/etc/kubernetes/ssl/

cat > conf/token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
cp conf/token.csv ${K8S_HOME}/etc/kubernetes/

wget https://github.com/kubernetes/kubernetes/releases/download/v1.7.3/kubernetes.tar.gz \
-O /tmp/kubernetes.tar.gz
cd kubernetes; ./cluster/get-kube-binaries.sh
or
wget https://dl.k8s.io/v1.7.3/kubernetes-server-linux-amd64.tar.gz \
-O /tmp/kubernetes-server-linux-amd64.tar.gz
tar xvzf /tmp/kubernetes-server-linux-amd64.tar.gz -C /tmp/
find /tmp/kubernetes/server/bin/ -perm /+x -type f -exec cp {} ./bin/ \;

cat  > conf/kube-apiserver.service <<EOF
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
  --v=2
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

rm -f /etc/systemd/system/kube-apiserver.service
ln -s ${K8S_HOME}/conf/kube-apiserver.service /etc/systemd/system/kube-apiserver.service

systemctl start kube-apiserver

systemctl daemon-reload
systemctl restart kube-apiserver

kubectl get rc,po,svc

cat > conf/kube-controller-manager.service <<EOF
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
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

rm -f /etc/systemd/system/kube-controller-manager.service
ln -s ${K8S_HOME}/conf/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service

systemctl daemon-reload
systemctl start kube-controller-manager

kubectl get componentstatuses

cat > conf/kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=${K8S_HOME}/bin/kube-scheduler \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_IP}:8080 \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

rm -f /etc/systemd/system/kube-scheduler.service
ln -s ${K8S_HOME}/conf/kube-scheduler.service /etc/systemd/system/kube-scheduler.service

systemctl daemon-reload
systemctl start kube-scheduler

kubectl get componentstatuses

==> 

NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-1               Healthy   {"health": "true"}
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}

6, NODE (kubelet/kube-proxy)

export NODE_NAME=$(ifconfig em1 | sed -n "2,2p" | awk '{print $2}' | awk -F'.' '{print "etcd-"$4}')
export NODE_IP=$(ifconfig em1 | sed -n "2,2p" | awk '{print $2}')
export MASTER_IP=${NODE_IP}
export KUBE_APISERVER="https://${MASTER_IP}:6443"
. bin/env.sh

wget https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
-O /tmp/docker-17.04.0-ce.tgz
tar xvzf /tmp/docker-17.04.0-ce.tgz -C /tmp
cp /tmp/docker/docker* bin/
cp /tmp/docker/completion/bash/docker /etc/bash_completion.d/

rm -rf /data/docker; mkdir -p /data/docker

cat > conf/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=${K8S_HOME}/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/flannel/docker
ExecStart=${K8S_HOME}/bin/dockerd \\
  --log-level=error \\
  --insecure-registry r.8ops.cc \\
  --graph=/data/docker \\
  --storage-driver=overlay \\
  \$DOCKER_NETWORK_OPTIONS
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

rm -f /etc/systemd/system/docker.service
ln -s ${K8S_HOME}/conf/docker.service /etc/systemd/system/docker.service

systemctl daemon-reload
systemctl start docker

# 后面版本的docker默认策略为DROP，需要手动变更
iptables -P FORWARD ACCEPT 

# （每个Node执行）
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
kubectl get clusterrolebinding

# （每个Node执行）
# 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
--token=${BOOTSTRAP_TOKEN} \
--kubeconfig=bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
cp bootstrap.kubeconfig ${K8S_HOME}/etc/kubernetes/

kubectl get csr
==> 
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI   1h        kubelet-bootstrap   Pending
node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI   18m       kubelet-bootstrap   Pending
node-csr-neHMIX3ditVK8N7DQyi9Is_BgLozHnUKxYjGFxwX26k   0s        kubelet-bootstrap   Pending

rm -rf /data/kubelet;mkdir /data/kubelet

cat > conf/kubelet.service <<EOF
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
  --pod-infra-container-image=r.8ops.cc/base/pod-infrastructure:latest \\
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
  --v=2
ExecStartPost=/sbin/iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -s 172.30.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -s 192.168.0.0/16 -p tcp --dport 4194 -j ACCEPT
ExecStartPost=/sbin/iptables -A INPUT -p tcp --dport 4194 -j DROP
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

rm -f /etc/systemd/system/kubelet.service
ln -s ${K8S_HOME}/conf/kubelet.service /etc/systemd/system/kubelet.service

systemctl daemon-reload
systemctl start kubelet

kubectl certificate approve node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI
kubectl certificate approve node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI
kubectl certificate approve node-csr-neHMIX3ditVK8N7DQyi9Is_BgLozHnUKxYjGFxwX26k

kubectl get no
==> 
NAME           STATUS    AGE       VERSION
10.10.20.102   Ready     2m        v1.7.3

kubectl get csr
==>
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr--0PrvYqUzAGNBfuLpfGQ1am8ZcKFMmVwjFZHzoI8PsI   1h        kubelet-bootstrap   Approved,Issued
node-csr-I_JTx-I7MXtB4VzKdaIAGhTzyQCrORD9rbIxmqWlWgI   21m       kubelet-bootstrap   Approved,Issued
node-csr-neHMIX3ditVK8N7DQyi9Is_BgLozHnUKxYjGFxwX26k   3m        kubelet-bootstrap   Approved,Issued



cat > conf/kube-proxy-csr.json <<EOF
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
-ca-key=${K8S_HOME}/etc/kubernetes/ssl/ca-key.pem \
-config=${K8S_HOME}/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes conf/kube-proxy-csr.json | cfssljson -bare kube-proxy
cp kube-proxy*.pem ${K8S_HOME}/etc/kubernetes/ssl/

# 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=${K8S_HOME}/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-proxy.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
--client-certificate=${K8S_HOME}/etc/kubernetes/ssl/kube-proxy.pem \
--client-key=${K8S_HOME}/etc/kubernetes/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig

# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
cp kube-proxy.kubeconfig ${K8S_HOME}/etc/kubernetes/

rm -rf /data/kube-proxy; mkdir -p /data/kube-proxy
cat > conf/kube-proxy.service <<EOF
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
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

rm -f /etc/systemd/system/kube-proxy.service
ln -s ${K8S_HOME}/conf/kube-proxy.service /etc/systemd/system/kube-proxy.service

systemctl daemon-reload
systemctl start kube-proxy

7, USAGE

systemctl status etcd
systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler
systemctl status kubelet
systemctl status kube-proxy

kubectl get rc,po,svc,ep,ds --all-namespaces -o wide

mkdir -p conf/yaml
cat > conf/yaml/nginx-ds.yml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ds
  labels:
    app: nginx-ds
spec:
  type: NodePort
  selector:
    app: nginx-ds
  ports:
  - name: http
    port: 80
    targetPort: 80

---

apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ds
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: nginx-ds
    spec:
      containers:
      - name: my-nginx
        image: r.8ops.cc/base/nginx:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
EOF

kubectl create -f conf/yaml/nginx-ds.yml

kubectl create secret \
docker-registry registrykey \
--namespace=kube-system \
--docker-server=r.8ops.cc \
--docker-username=jesse \
--docker-password=Harbor123 \
--docker-email=m@8ops.cc

kubectl create secret \
docker-registry registrykey \
--namespace=default \
--docker-server=r.8ops.cc \
--docker-username=jesse \
--docker-password=Harbor123 \
--docker-email=m@8ops.cc

cat > conf/yaml/tomcat-po.yml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: tomcat-po
  labels:
    app: tomcat
spec:
  containers:
  - name: tomcat-po
    image: r.8ops.cc/base/tomcat
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 18080
  imagePullSecrets:
  - name: registrykey
EOF


## DNS

dnsmasq
skydns

dashboard

http://10.10.20.101:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
http://10.10.20.101:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:8083/
kubectl  proxy --address=10.10.20.101 --port=8086 --accept-hosts='^*$'
http://10.10.20.101:8086/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
http://10.10.20.101:8086/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:8083/
kubectl cluster-info

heapster  

再重启 dashboard, dashboard 启动时要加载heapster
Creating in-cluster Heapster client
Successful initial request to heapster

EFK
curl -i 'http://172.30.85.2:9200/_cat/indices?v' 查看已经生成的日志

Harbor

wget https://github.com/docker/compose/releases/download/1.15.0/docker-compose-Linux-x86_64
or 
curl -sL https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > ${K8S_HOME}/bin/docker-compose
chmod +x ${K8S_HOME}/bin/docker-compose

wget https://github.com/vmware/harbor/releases/download/v1.1.2/harbor-offline-installer-v1.1.2.tgz
or
wget http://yp.cdn.8ops.cc/tools/k8s/harbor/harbor-offline-installer-v1.1.2.tgz
































