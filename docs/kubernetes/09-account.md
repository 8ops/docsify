# 实战 | 用户体系

创建token，用于

- dashboard登录
- kubectl命令行操作
- 跨集群管理



M1

```bash
cat > ca-config.json <<EOF
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
cat > user01-csr.json <<EOF
{
  "CN": "user01",
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
      "O": "Lab",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert \
    -ca=/etc/kubernetes/pki/ca.crt \
    -ca-key=/etc/kubernetes/pki/ca.key \
    -config=ca-config.json \
    -profile=kubernetes \
    user01-csr.json | \
    cfssljson -bare user01

# 设置集群参数
export KUBE_APISERVER="https://10.101.11.240:6443"
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/pki/ca.crt \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=user01.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials user01 \
--client-certificate=user01.pem \
--client-key=user01-key.pem \
--embed-certs=true \
--token=bearer_token \
--kubeconfig=user01.kubeconfig

# 设置上下文参数
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=user01 \
--kubeconfig=user01.kubeconfig

# 设置默认上下文
kubectl config use-context kubernetes --kubeconfig=user01.kubeconfig

# kubectl create crolebinding user01-binding --clusterrole=admin --user=user01 --namespace=default

kubectl create serviceaccount user01 

kubectl create clusterrolebinding user01-binding --clusterrole=cluster-admin --user=user01 

kubectl describe secrets $(kubectl get secret | awk '/user01/{print $1}')

----
kubectl create serviceaccount user01 -n kube-server
kubectl create clusterrolebinding user01 \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-server:user01
kubectl describe secrets \
  -n kube-server $(kubectl -n kube-server get secret | awk '/user01/{print $1}')
#kubectl -n kube-system get secret admin-token-nwphb -o jsonpath={.data.token}|base64 -d
```



M2

```bash
cat > config-demo <<EOF
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
  name: kubernetes

users:
- name: lab-admin
- name: lab-guest

contexts:
- context:
  name: lab
- context:
  name: lab01
- context:
  name: lab02
EOF

kubectl config --kubeconfig=demo.kubeconfig \
    set-cluster kubernetes \
    --embed-certs=true \
    --server=https://10.101.11.240:6443 \
    --certificate-authority=/etc/kubernetes/pki/ca.crt

kubectl config --kubeconfig=demo.kubeconfig \
    set-credentials experimenter \
    --username=exp --password=some-password

kubectl config --kubeconfig=demo.kubeconfig \
    set-context lab \
    --cluster=kubernetes \
#    --namespace=default \
    --user=lab-admin

kubectl --kubeconfig=demo.kubeconfig config use-context lab

kubectl --kubeconfig=demo.kubeconfig config view --minify

kubectl -n kube-server create serviceaccount lab-admin
kubectl create clusterrolebinding demo-binding \
		--clusterrole=cluster-admin \
	  --serviceaccount=kube-server:lab-admin
```

