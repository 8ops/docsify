# 实战 | ArgoCD 使用



## 一、安装

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm search repo argo-cd
helm show values argo/argo-cd > argocd-configs.yaml-5.4.2-default

# Example
#   https://books.8ops.top/attachment/kubernetes/helm/argocd-configs.yaml-5.4.2
# 

helm install argo-cd argo/argo-cd \
    -n kube-server \
    -f argocd-configs.yaml-5.4.2 \
    --version 5.4.2

helm upgrade --install argo-cd argo/argo-cd \
    -n kube-server \
    -f argocd-configs.yaml-5.4.2 \
    --version 5.4.2

helm -n kube-server uninstall argo-cd

kubectl -n kube-server get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -D

```



## 二、使用

可以通过 `UI` 界面向导操作，也可以通过 `argocd` 命令操作

```bash
wget -O ~/bin/argocd https://argo-cd.8ops.top/download/argocd-linux-amd64
chmod +x ~/bin/argocd
```



### 2.1 多集群

```bash
# 查看 kubeconfig
kubectl config get-contexts

# 登录 argo-cd
argocd login argo-cd.8ops.top --grpc-web
argocd context

# 添加 kubernetes cluster
argocd cluster add kubernetes-guest \
    --kubeconfig ~/.kube/config \
    --name kubernetes-guest-from-kubeconfig
# 非安全模式 - token认证
argocd cluster add kubernetes-guest --name kubernetes-guest-from-kubeconfig
argocd cluster list
```



### 2.2 应用

```bash
# Create a directory app
argocd app create guestbook \
    --repo https://github.com/argoproj/argocd-example-apps.git \
    --path guestbook \
    --dest-namespace default \
    --dest-server https://kubernetes.default.svc --directory-recurse

# Create a Jsonnet app
argocd app create jsonnet-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path jsonnet-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --jsonnet-ext-str replicas=2

# Create a Helm app
argocd app create helm-guestbook --repo https://gitlab.wuxingdev.cn/gce/argocd-example-apps.git --path helm-guestbook --dest-namespace kube-app --dest-server https://kubernetes.default.svc --helm-set replicaCount=2 --project argo-example-apps

# Create a Helm app from a Helm repo
argocd app create nginx-ingress --repo https://charts.helm.sh/stable --helm-chart nginx-ingress --revision 1.24.3 --dest-namespace default --dest-server https://kubernetes.default.svc

# Create a Kustomize app
argocd app create kustomize-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path kustomize-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --kustomize-image gcr.io/heptio-images/ks-guestbook-demo:0.1

# Create a app using a custom tool:
argocd app create kasane --repo https://github.com/argoproj/argocd-example-apps.git --path plugins/kasane --dest-namespace default --dest-server https://kubernetes.default.svc --config-management-plugin kasane
```







