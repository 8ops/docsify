
GitHinub:

https://github.com/coreos/etcd
https://github.com/kubernetes/kubernetes
https://github.com/gravitational/kube2sky
https://github.com/skynetservices/skydns

==== online

10.10.20.101
10.10.20.102
10.10.20.103

systemctl disable firewalld
systemctl stop firewalld
systemctl disable postfix
systemctl stop postfix

-- vm list 

master-01: 10.10.10.36
node-01  : 10.10.10.37
node-02  : 10.10.10.38
node-03  : 10.10.10.39

harbor   : 10.10.10.41
dashboard: 10.10.10.42

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ etcd/kubernetes(master,node) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

== Master

yum install -y -q etcd kubernetes flanneld

systemctl daemon-reload

systemctl start etcd
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start flanneld

systemctl status etcd
systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler
systemctl status flanneld

systemctl stop etcd
systemctl stop kube-apiserver
systemctl stop kube-controller-manager
systemctl stop kube-scheduler
systemctl stop flanneld

systemctl enable etcd
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable flanneld

systemctl disable etcd
systemctl disable kube-apiserver
systemctl disable kube-controller-manager
systemctl disable kube-scheduler
systemctl disable flanneld

== Node

yum install -y -q kubernetes flanneld

systemctl daemon-reload

systemctl start flanneld
systemctl start kubelet
systemctl start kube-proxy
systemctl start docker

systemctl status flanneld
systemctl status kubelet
systemctl status kube-proxy
systemctl status docker




---- vim ----

== Master

vim /etc/etcd/etcd.conf

ETCD_DATA_DIR="/data/etcd"

ETCD_LISTEN_PEER_URLS="http://10.10.10.36:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.10.10.36:2379"

ETCD_ADVERTISE_CLIENT_URLS="http://10.10.10.36:2379"

chown etcd.etcd /data/etcd

vim /lib/systemd/system/docker.service

            --graph=/data/docker \
            --storage-driver=overlay \

vim /etc/kubernetes/config

KUBE_MASTER="--master=http://10.10.10.36:8080"

vim /etc/kubernetes/apiserver

KUBE_API_ADDRESS="--insecure-bind-address=10.10.10.36"

KUBE_ETCD_SERVERS="--etcd-servers=http://10.10.10.36:2379"

KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"

vim /etc/kubernetes/controller-manager

KUBE_CONTROLLER_MANAGER_ARGS=" --master=http://10.10.10.36:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=2"

vim /etc/kubernetes/scheduler

KUBE_SCHEDULER_ARGS=" --master=http://10.10.10.36:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=0"

vim /etc/sysconfig/flanneld

FLANNEL_ETCD_ENDPOINTS="http://10.10.10.36:2379"

== Node

vim /etc/sysconfig/flanneld

FLANNEL_ETCD_ENDPOINTS="http://10.10.10.36:2379"

vim /etc/kubernetes/kubelet

KUBELET_HOSTNAME="--hostname-override=node-01.k8s.8ops.cc"

KUBELET_API_SERVER="--api-servers=http://10.10.10.36:8080"

vim /etc/kubernetes/proxy

KUBE_PROXY_ARGS=" --master=http://10.10.10.36:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=0"




-- Use --

kubectl -s http://10.10.10.36:8080 get rc,po,svc,ds,hpa,ev,ep,ing,limits,deployments,pv,pvc,quota,jobs,secrets,serviceaccounts --all-namespaces=true
kubectl -s http://10.10.10.36:8080 get ns,no,cs

kubectl -s http://10.10.10.31:8080 get rc,po,svc,ep --all-namespaces=true -o wide
kubectl -s http://10.10.10.31:8080 get ns,no


etcdctl --endpoints http://10.10.10.36:2379 member list
etcdctl --endpoint http://10.10.10.36:2379 set /atomic.io/network/config '{"Network": "10.1.0.0/16"}'

- 注意顺序
systemctl start flanneld
systemctl restart docker
systemctl restart kube-apiserver

ip a
ip route show | column -t

etcdctl --endpoint http://10.10.10.36:2379 ls /atomic.io/network/config
etcdctl --endpoint http://10.10.10.36:2379 get /atomic.io/network/config
etcdctl --endpoint http://10.10.10.36:2379 ls /atomic.io/network
etcdctl --endpoint http://10.10.10.36:2379 ls /atomic.io/network/subnets
etcdctl --endpoint http://10.10.10.36:2379 get /atomic.io/network/subnets/10.1.5.0-24

node config: 
vim /etc/sysconfig/flanneld
vim /etc/kubernetes/config
vim /etc/kubernetes/kubelet
vim /etc/kubernetes/proxy

- master
systemctl start etcd
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start flanneld

- node
systemctl start flanneld
systemctl start docker
systemctl start kubelet
systemctl start kube-proxy

kubectl -s http://10.10.10.36:8080 create -f http://z.8ops.cc/k8s/yaml/guestbook/redis-master-controller.yaml

kubectl -s http://10.10.10.36:8080 apply -f http://z.8ops.cc/k8s/yaml/guestbook/redis-master-controller.yaml

kubectl -s http://10.10.10.36:8080 delete -f http://z.8ops.cc/k8s/yaml/guestbook/redis-master-controller.yaml

watch kubectl -s http://10.10.10.36:8080 get rc,po,svc,ep --all-namespaces=true

kubectl -s http://10.10.10.36:8080 create -f  http://z.8ops.cc/k8s/yaml/guestbook/redis-master-service.yaml

ip route add 192.168.1.0/24 via 10.10.10.254 dev enp0s3
ip route show | column -t

in vm with normal: 10.10.10.62
--
ip route add 10.1.18.0/24 via 10.10.10.37 dev eth0
ip route add 10.1.71.0/24 via 10.10.10.38 dev eth0
ip route show | column -t 

redis-cli -h 10.1.18.2 ==> is OK
redis-cli -h 10.1.71.2 ==> is OK

kubectl -s http://10.10.10.36:8080 get rc,po,svc,ep --all-namespaces=true -o wide



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Harbor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DNS record: 10.10.10.41 r.8ops.cc

yum install -y -q docker-compose

systemctl start docker

Harbor UI : admin / Harbor12345
Mysql root: root  / root123

vim /etc/sysconfig/docker

OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --registry-mirror=https://z4xpl3y1.mirror.aliyuncs.com --insecure-registry r.8ops.cc'

or 

INSECURE_REGISTRY='--insecure-registry r.8ops.cc'

wget http://yp.cdn.8ops.cc/tools/k8s/harbor/harbor-offline-installer-v1.1.2.tgz

vim harbor.cfg

hostname = r.8ops.cc

ui_url_protocol = https

ssl_cert = /data/cert/r.8ops.cc.crt
ssl_cert_key = /data/cert/r.8ops.cc.key

email_server = smtp.exmail.qq.com
email_server_port = 465
email_username = k8s@8ops.cc
email_password = password
email_from = K8S <k8s@8ops.cc>
email_ssl = true

- yml or harbor.cfg 里面默认指定 /data, 未改变默认位置

curl -s -o /data/cert/r.8ops.cc.crt http://yp.cdn.8ops.cc/cert/r.8ops.cc.pem
curl -s -o /data/cert/r.8ops.cc.key http://yp.cdn.8ops.cc/cert/r.8ops.cc.key

./prepare

./install.sh

-- Harbor and (Node，认证过的ssl证书此步骤可免) 
mkdir -p /etc/docker/certs.d/r.8ops.cc
curl -s -o /etc/docker/certs.d/r.8ops.cc/ca.crt http://yp.cdn.8ops.cc/cert/r.8ops.cc.pem
tree /etc/docker/certs.d

docker-compose down
docker-compose up -d

docker login r.8ops.cc -u admin -p Harbor12345

docker tag docker.io/kubeguide/redis-master:latest r.8ops.cc/kubeguide/redis-master:latest
docker push r.8ops.cc/kubeguide/redis-master:latest

docker pull r.8ops.cc/kubeguide/redis-master:latest

-- with github/kubernetes only test
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 365 -out ca.crt
openssl req -newkey rsa:4096 -nodes -sha256 -keyout r.8ops.cc.key -out r.8ops.cc.csr
openssl x509 -req -days 365 -in r.8ops.cc.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out r.8ops.cc.crt
  
echo subjectAltName = IP:10.10.10.40> extfile.cnf

openssl x509 -req -days 365 -in r.8ops.cc.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out r.8ops.cc.crt


-- with net only test
localdomain=reg.8ops.cc 
openssl req -nodes -subj "/C=CN/ST=Shanghai/L=Shanghai/CN=$localdomain" -newkey rsa:2048 -keyout $localdomain.key -out $localdomain.csr 
openssl x509 -req -days 3650 -in $localdomain.csr -signkey $localdomain.key -out $localdomain.crt 
openssl x509 -req -in $localdomain.csr -CA $localdomain.crt -CAkey $localdomain.key -CAcreateserial -out $localdomain.crt -days 10000 


openssl x509 -in r.8ops.cc.pem -noout -text
openssl x509 -in r.8ops.cc.pem -noout -subject

-- trust the ca
On Ubuntu
cp youdomain.com.crt /usr/local/share/ca-certificates/reg.yourdomain.com.crt
update-ca-certificates

On RedHat/CentOS
cp yourdomain.com.crt /etc/pki/ca-trust/source/anchors/reg.yourdomain.com.crt
update-ca-trust


-- pod or pause  镜像默认去gcr拉太慢，改从私有仓库拉
vim /etc/kubernetes/kubelet
KUBELET_ARGS="--pod-infra-container-image=r.8ops.cc/base/pod-infrastructure:latest"


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Dashboard ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- >= 1.6
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard-head.yaml

https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
https://git.io/kube-dashboard

- <= 1.5
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard-head-no-rbac.yaml

https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard-no-rbac.yaml
https://git.io/kube-dashboard-no-rbac

kubectl -s http://10.10.10.36:8080 create -f kubernetes-dashboard.yaml

try ...
--apiserver-host=http://{{ .Env.MASTER_PRIVATE }}:8080
--apiserver-host=https://{{ .Env.MASTER_PRIVATE }}:6443

docker pull r.8ops.cc/kubernetes/kubernetes-dashboard-amd64:v1.5.1

kubectl -s http://10.10.10.36:8080 get ServiceAccounts --all-namespaces=true
kubectl -s http://10.10.10.36:8080 describe po/kubernetes-dashboard-566722641-z7bp1 --namespace=kube-system

kubectl -s http://10.10.10.36:8080 create -f kubernetes-dashboard.yaml --validate=false
kubectl -s http://10.10.10.36:8080 delete -f kubernetes-dashboard.yaml --validate=false

vim kube-dashboard-no-rbac

        image: r.8ops.cc/kubernetes/kubernetes-dashboard-amd64:v1.5.1
        imagePullPolicy: IfNotPresent

          - --apiserver-host=http://10.10.10.36:8080

kubectl -s http://10.10.10.36:8080 create -f kube-dashboard-no-rbac



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ skydns ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim /etc/kubernetes/kubelet
KUBELET_ARGS="--cluster_dns=10.254.0.10 --cluster_domain=cluster.local"

watch 'uptime;echo "----";kubectl -s http://10.10.10.36:8080 get rc,po,svc,ep,secret,ing --all-namespaces=true -o wide;echo "----";kubectl -s http://10.10.10.36:8080 get no'

docker exec -i -t xxx nslookup redis-master



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ secret ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

kubectl -s http://10.10.10.36:8080 get componentstatuses

kubectl -s http://10.10.10.36:8080 get secret,deployments,rs --all-namespaces=true

-- docker 认证方式
docker login r.8ops.cc -u jesse -p Harbor123

-- kubernetes 认证方式，在使用时需要是同一个空间
kubectl -s http://10.10.10.36:8080 create secret \
docker-registry registrykey \
--namespace=development \
--docker-server=r.8ops.cc \
--docker-username=jesse \
--docker-password=password \
--docker-email=m@8ops.cc

kubectl -s http://10.10.10.36:8080 create secret \
docker-registry registrykey \
--namespace=default \
--docker-server=r.8ops.cc \
--docker-username=jesse \
--docker-password=password \
--docker-email=m@8ops.cc

kubectl -s http://10.10.10.36:8080 create secret \
docker-registry registrykey \
--namespace=kube-system \
--docker-server=r.8ops.cc \
--docker-username=jesse \
--docker-password=password \
--docker-email=m@8ops.cc

vim secret_registrykey.yaml

vim busybox_pod_namespace.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: development
spec:
  containers:
  - image: r.8ops.cc/base/busybox
    imagePullPolicy: IfNotPresent
    command:
      - sleep
      - "3600"
    name: busybox
  imagePullSecrets:
  - name: registrykey

kubectl -s http://10.10.10.36:8080 create -f busybox_pod_namespace.yaml



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ingress ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


kubectl -s http://10.10.10.36:8080 run echoheaders \
  --image=r.8ops.cc/kubeguide/echoserver:latest \
  --image-pull-policy=IfNotPresent \
  --replicas=1 \
  --port=8080

kubectl -s http://10.10.10.36:8080 expose rc ingress-rc --port=80 --target-port=8080 --name=echoheaders-x -l app=ingress
kubectl -s http://10.10.10.36:8080 expose rc ingress-rc --port=80 --target-port=8080 --name=echoheaders-y -l app=ingress

vim ingress-demo.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: ingress-rc
  labels:
    app: ingress
spec:
  replicas: 1
  selector:
    name: ingress-po
  template:
    metadata:
      labels:
        name: ingress-po
        app: ingress
    spec:
      containers:
      - name: echoserver
        image: r.8ops.cc/kubeguide/echoserver:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
#          hostPort: 8080
      imagePullSecrets:
      - name: registrykey
---
kind: Service
metadata:
  name: echoheaders-x
  labels:
    app: ingress
spec:
  selector:
    name: ingress
  ports:
  - name: echoheaders-x-port
    port: 80
    targetPort: 8080
#    nodePort: 30002
---
kind: Service
metadata:
  name: echoheaders-y
  labels:
    app: ingress
spec:
  selector:
    name: ingress
  ports:
  - name: echoheaders-y-port
    port: 80
    targetPort: 8080
#    nodePort: 30002
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-ing
  labels:
    app: ingress
spec:
  rules:
  - host: a.8ops.cc
    http:
      paths:
      - path: /foo
        backend:
          serviceName: echoheaders-x
          servicePort: 80
  - host: b.8ops.cc
    http:
      paths:
      - path: /bar
        backend:
          serviceName: echoheaders-y
          servicePort: 80
      - path: /foo
        backend:
          serviceName: echoheaders-x
          servicePort: 80



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ USE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`国内访问Google镜像资源`
grc.io/google_containers/etcd-amd64:2.2.1
index.tenxcloud.com/google_containers/etcd-amd64:2.2.1

kubeguide/redis-master:2.0
index.tenxcloud.com/kubeguide/redis-master:2.0




































secret
skydns
ingress
heapster
serviceaccount


======== Cluster HA 参考 ========

# TO-DO ETCD Cluster 
https://segmentfault.com/a/1190000005345466

#ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
#ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
#ETCD_INITIAL_CLUSTER_STATE="new"
#ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://10.10.10.36:2379"



https://t.goodrain.com/t/kubernetes/131

参考步骤 https://github.com/opsnull/follow-me-install-kubernetes-cluster

集群详情
Kubernetes 1.6.1
Docker 17.04.0-ce
Etcd 3.1.5
Flanneld 0.7 vxlan 网络
TLS 认证通信 (所有组件，如 etcd、kubernetes master 和 node)
RBAC 授权
kublet TLS BootStrapping
kubedns、dashboard、heapster(influxdb、grafana)、EFK(elasticsearch、fluentd、kibana)集群插件
私有 registry 仓库，使用 ceph rgw 做存储，TLS + Basic 认证

步骤介绍
创建 TLS 证书和秘钥
下载和配置 Kubectl 命令行工具
部署高可用 Etcd 集群
部署 Master 节点
配置 Node Kubeconfig 文件
部署 Node 节点
部署 DNS 插件
部署 Dashboard 插件
部署 Heapster 插件
部署 EFK 插件
部署 Docker Registry
清理集群

https://www.gitbook.com/download/pdf/book/opsnull/follow-me-install-kubernetes-cluster
















