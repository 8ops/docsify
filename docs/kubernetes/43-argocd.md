# 实战 | ArgoCD 使用



## 一、安装

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm search repo argo-cd
helm show values argo/argo-cd --version 5.13.8 > argocd-configs.yaml-5.13.8-default

# Example
#   https://books.8ops.top/attachment/argo/helm/argocd-configs.yaml-5.13.8
#   https://books.8ops.top/attachment/argo/helm/argocd-configs.yaml-5.4.2
# 

helm upgrade --install argo-cd argo/argo-cd \
    -n kube-server \
    -f argocd-configs.yaml-5.13.8 \
    --version 5.13.8

helm -n kube-server uninstall argo-cd

kubectl -n kube-server get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -D; echo 

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
argocd context --grpc-web

# 添加 kubernetes cluster
argocd cluster add kubeconfig-guest-name \
    --kubeconfig ~/.kube/config \
    --name argocd-cluster-name --grpc-web
    
# 非安全模式 - token认证
argocd cluster add kube-context-name --name argocd-context-name --grpc-web
argocd cluster list --grpc-web
```



> argocd添加外部kubernetes cluster步骤

```bash
# 第一步，通过ingress-nginx暴露流量
kubectl apply -f kube-apiserver-ingress.yaml

# 第二步，在kubeconfig添加context

# 第三步，登录argocd
argocd login argocd.8ops.top

# 第四步，添加cluster
argocd cluster add kube-context-name --name argocd-context-name --grpc-web
# 添加完成后会在对应的 kubernetes cluster 创建 ServiceAccount/argocd-manager
# kubectl -n kube-system get ServiceAccount/argocd-manager ClusterRole/argocd-manager-role ClusterRoleBinding/argocd-manager-role-binding

# 第五步，查看cluster
argocd cluster list --grpc-web
```

> kube-apiserver-ingress.yaml

```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    service.alpha.kubernetes.io/app-protocols: '{"https":"HTTPS"}'
    nginx.ingress.kubernetes.io/whitelist-source-range: 10.1.1.0/28
  name: kube-apiserver
  namespace: default
spec:
  ingressClassName: external
  rules:
  - host: kube-apiserver.8ops.top
    http:
      paths:
      - backend:
          service:
            name: kubernetes
            port:
              number: 443
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - kube-apiserver.8ops.top
    secretName: tls-8ops.top
```

> kubeconfig

```yaml
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://kube-apiserver.8ops.top
  name: kube-external-insecure
contexts:
- context:
    cluster: kube-external-insecure
    user: kube-external-user
  name: kube-external-insecure  
current-context: kube-external-insecure 
kind: Config
preferences:
  colors: true
users:
- name: kube-external-user
  user:
    token: <data>  
```

> view

```bash
SERVER                          NAME                   VERSION STATUS     MESSAGE PROJECT
https://kube-apiserver.8ops.top kube-external-insecure 1.23    Successful
https://kubernetes.default.svc  in-cluster             1.25    Successful
```



### 2.2 accounts

Reference

- [用户管理](https://argoproj.github.io/argo-cd/operator-manual/user-management/)

- [RBAC控制](https://argoproj.github.io/argo-cd/operator-manual/rbac/)

```bash
# get account admin's pass
~ $ kubectl -n kube-server get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D  

# add account jesse
~ $ kubectl -n kube-server edit cm argocd-cm
data:
  ……
  accounts.jesse: login
  accounts.jesse.enabled: "true"

# setting account jesse's pass
# --current-password is admin's pass
~ $ argocd account update-password  --account jesse --current-password jesse2020 --new-password jesse2022 --grpc-web

# policy
# p, linyanzhi, *, *, lixian/*, allow   -----p是policy，用户名，要使用的资源，要使用的方法，项目，allow或deny
# policy.default: role:readonly     -----默认策略
#
  policy.csv: |
    p, jesse, applications, *, */*, allow
    p, jesse, clusters, *, *, allow
    p, jesse, certificates, get, *, allow
    p, jesse, repositories, get, *, allow
    p, jesse, projects, get, *, allow
    p, jesse, accounts, get, *, allow
    p, jesse, gpgkeys, get, *, allow
    p, jesse, logs, get, *, allow
    p, jesse, exec, create, */*, allow


argocd login argo-cd.8ops.top --grpc-web
argocd account list --grpc-web
argocd account update-password --account jesse --current-password jesse2022 --new-password jesse2022 --grpc-web
```





### 2.3 应用

`TODO`

```bash
# Create a directory app
argocd app create guestbook \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path guestbook \
    --dest-namespace default \
    --dest-server https://kubernetes.default.svc \
    --directory-recurse \
    --grpc-web

# Create a Jsonnet app
argocd app create jsonnet-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path jsonnet-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --jsonnet-ext-str replicas=2

# Create a Helm app
argocd app create helm-guestbook --repo https://git.8ops.top/gce/argocd-example-apps.git --path helm-guestbook --dest-namespace kube-app --dest-server https://kubernetes.default.svc --helm-set replicaCount=2 --project argo-example-apps

# Create a Helm app from a Helm repo
argocd app create nginx-ingress --repo https://charts.helm.sh/stable --helm-chart nginx-ingress --revision 1.24.3 --dest-namespace default --dest-server https://kubernetes.default.svc

# Create a Kustomize app
argocd app create kustomize-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path kustomize-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --kustomize-image gcr.io/heptio-images/ks-guestbook-demo:0.1

# Create a app using a custom tool:
argocd app create kasane --repo https://github.com/argoproj/argocd-example-apps.git --path plugins/kasane --dest-namespace default --dest-server https://kubernetes.default.svc --config-management-plugin kasane
```



### 2.4 数据存储

默认基于 kubernetes cluster's ETCD 存储

```bash
# 1，获取资源类型
$ kubectl api-resources | grep argo
applications      app,apps         argoproj.io/v1alpha1  true  Application
applicationsets   appset,appsets   argoproj.io/v1alpha1  true  ApplicationSet
appprojects       appproj,appprojs argoproj.io/v1alpha1  true  AppProject
argocdextensions                   argoproj.io/v1alpha1  true  ArgoCDExtension

# 2，获取资源列表
$ kubectl -n kube-server get applications
NAME             SYNC STATUS   HEALTH STATUS
helm-guestbook   Synced        Healthy

# 3，展开详情
$ kubectl -n kube-server get applications helm-guestbook -o yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  creationTimestamp: "2022-10-11T05:37:49Z"
  generation: 19734
  name: helm-guestbook
  namespace: kube-server
  resourceVersion: "18247691"
  uid: c26e8225-c6cc-4338-a494-525f572cae4a
spec:
  destination:
    namespace: kube-app
    server: https://kubernetes.default.svc
  project: argo-example-apps
  source:
    helm:
      parameters:
      - name: replicaCount
        value: "2"
    path: helm-guestbook
    repoURL: https://git.8ops.top/gce/argocd-example-apps.git
    targetRevision: HEAD
……    
```



## 三、常见问题



### 3.1 加入集群认证问题

1. 白名单
2. 通过 token 走 insecure
3. 通过 kubeconfig 当引用外部 ca 文件时注意引入目录



### 3.2 kubernetes cluster 多套 argocd 

```bash
# helm values
crds:
  install: false
  keep: true
```

当同一命名空间多次部署时，不管是否是同一套 argocd 会自动加载之前的配置信息。
