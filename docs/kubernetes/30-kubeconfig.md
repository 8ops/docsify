# KubeConfig 的综合使用

## 多集群管理

[Reference](https://kubernetes.io/zh-cn/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)



## 创建新用户并授权

```bash
# 新用户名称
USER=abc

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
    --server=https://10.129.4.201:6443 \
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
##   下面实例使用第2种

# 创建ClusterRole
kubectl create clusterrole cluster-reader-for-guest \
    --verb=get,list,watch \
    --resource=namespaces,nodes,pods,deployments,replicasets,daemonsets,services,ingresses,endpoints,events,configmaps,statefulsets,secrets,jobs,cronjobs,replicationcontrollers,horizontalpodautoscalers \
    --dry-run=client -o yaml 
    # | kubectl apply -f -

# 绑定ClusterRoleBinding
kubectl create clusterrolebinding cluster-reader-for-guest-binding \
    --clusterrole=cluster-reader-for-guest \
    --user=${USER} \
    --dry-run=client -o yaml 
    # | kubectl apply -f -

## kubectl delete clusterrole cluster-reader-for-guest
## kubectl delete clusterrolebinding cluster-reader-for-guest-binding
## 关联默认查看权限
##   kubectl create clusterrolebinding cluster-reader-for-guest-binding --clusterrole=view --user=${USER}
## 关联默认管理权限
##   kubectl create clusterrolebinding cluster-reader-for-guest-binding --clusterrole=cluster-admin --user=${USER}

# 使用集锦
kubectl --kubeconfig ${USER}.kubeconfig get pods
kubectl --kubeconfig ${USER}.kubeconfig get nodes
kubectl --kubeconfig ${USER}.kubeconfig get all

```









