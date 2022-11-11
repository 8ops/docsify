# 实战 | KubeConfig 的综合使用

## 多集群管理

[Reference](https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)



## 创建用户并授权

```bash
# 新用户名称
USER=guest

# 创建新用户签名证书
openssl genrsa -out ${USER}.key 2048
openssl req -new -key ${USER}.key -out ${USER}.csr -subj "/C=CN/ST=ShangHai/L=ShangHai/O=Kubernetes/OU=GAT/CN=${USER}"
openssl x509 -req -in ${USER}.csr \
    -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial \
    -out ${USER}.crt -days 365

# 设置集群参数
kubectl config set-cluster kubernetes \
    --certificate-authority=/etc/kubernetes/pki/ca.crt \
    --embed-certs=true \
    --server=https://10.101.11.111:6443 \
    --kubeconfig=${USER}.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials ${USER} \
    --client-certificate=${USER}.crt \
    --client-key=${USER}.key \
    --embed-certs=true \
    --kubeconfig=${USER}.kubeconfig

# 设置上下文参数
kubectl config set-context ${USER}@kubernetes \
    --cluster=kubernetes \
    --user=${USER} \
    --kubeconfig=${USER}.kubeconfig

# 查看kubeconfig内容
kubectl config view --kubeconfig ${USER}.kubeconfig

# 设置默认上下文
kubectl config use-context ${USER}@kubernetes --kubeconfig=${USER}.kubeconfig

## 授权方式有两种
## 1, Role+RoleBinding
## 2, ClusterRole+ClusterRoleBinding
##   下面实例使用第 2 种

# 创建ClusterRole
kubectl create clusterrole cluster-reader-for-${USER} \
    --verb=get,list,watch \
    --resource=namespaces,nodes,pods,pods/log,deployments,replicasets,daemonsets,services,ingresses,endpoints,events,configmaps,statefulsets,secrets,jobs,cronjobs,replicationcontrollers,horizontalpodautoscalers \
    --dry-run=client -o yaml 
    # | kubectl apply -f -

# add rule: 连接容器
#- apiGroups:
#  - ""
#  resources:
#  - pods/exec
#  verbs:
#  - create

# 绑定 ClusterRoleBinding
kubectl create clusterrolebinding cluster-reader-for-${USER}-binding \
    --clusterrole=cluster-reader-for-${USER} \
    --user=${USER} \
    --dry-run=client -o yaml 
    # | kubectl apply -f -

## kubectl delete clusterrole cluster-reader-for-${USER}
## kubectl delete clusterrolebinding cluster-reader-for-${USER}-binding
## 关联默认查看权限
##   kubectl create clusterrolebinding cluster-reader-for-${USER}-binding --clusterrole=view --user=${USER}
## 关联默认管理权限
##   kubectl create clusterrolebinding cluster-reader-for-${USER}-binding --clusterrole=cluster-admin --user=${USER}

# 使用集锦
kubectl --kubeconfig ${USER}.kubeconfig get pods
kubectl --kubeconfig ${USER}.kubeconfig get nodes
kubectl --kubeconfig ${USER}.kubeconfig get all

```

## 示例

```bash
# 适用于kubernetes v1.24.0 之后的版本
USER=guest
kubectl delete clusterrole cluster-reader-for-${USER}
kubectl create clusterrole cluster-reader-for-${USER} \
    --verb=get,list,watch \
    --resource=namespaces,nodes,pods,pods/log,deployments,replicasets,daemonsets,services,ingresses,endpoints,events,configmaps,statefulsets,secrets,jobs,cronjobs,replicationcontrollers,horizontalpodautoscalers \
    --dry-run=client -o yaml | \
    kubectl apply -f -
kubectl edit clusterrole cluster-reader-for-${USER}    

# add
- apiGroups:
  - ""
  resources:
  - pods/exec
  verbs:
  - create
  
kubectl -n kube-server delete serviceaccount dashboard-${USER}
kubectl -n kube-server create serviceaccount dashboard-${USER}

kubectl delete clusterrolebinding dashboard-${USER} 
kubectl create clusterrolebinding dashboard-${USER} \
  --clusterrole=cluster-reader-for-${USER} \
  --serviceaccount=kube-server:dashboard-${USER}

kubectl -n kube-server delete dashboard-${USER}-secret
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-${USER}-secret
  namespace: kube-server
  annotations:
    kubernetes.io/service-account.name: dashboard-${USER}
type: kubernetes.io/service-account-token
EOF

kubectl -n kube-server get secret dashboard-august-secret -o jsonpath={.data.token} | base64 --decode > dashboard-august.token

```









