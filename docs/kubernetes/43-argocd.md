# 实战 | ArgoCD 使用



## 一、安装

```bash
helm repo add argoproj https://argoproj.github.io/argo-helm
helm repo update argoproj
helm search repo argo-cd
helm show values argoproj/argo-cd --version 5.13.8 > argocd-configs.yaml-5.13.8-default

# Example
#   https://books.8ops.top/attachment/argo/helm/argocd-configs.yaml-5.13.8
#   https://books.8ops.top/attachment/argo/helm/argocd-configs.yaml-5.4.2
# 

helm upgrade --install argo-cd argoproj/argo-cd \
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
~ $ kubectl -n kube-server get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode

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



### 2.3 存储

相关元信息存储在 kubernetes cluster's etcd 中

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



### 2.4 综合

```bash
argocd login argo-cd.8ops.top --username=admin --password=xx --grpc-web
argocd account update-password --account jesse --current-password xx --new-password jesse2022 --grpc-web

argocd ctx list

argocd cluster list
argocd proj    list
argocd repo    list
argocd app     list

# backup
argocd cluster list -o yaml > 01-argocd-cluster-list.yaml
argocd proj    list -o yaml > 02-argocd-proj-list.yaml
argocd repo    list -o yaml > 03-argocd-repo-list.yaml
argocd app     list -o yaml > 04-argocd-app-list.yaml

kubectl run redis-client --restart='Never' \
  --image hub.8ops.top/bitnami/redis:7.0.4 \
  --namespace kube-app \
  --command -- sleep infinity
```



### 2.5 cluster

```bash
argocd cluster list
argocd cluster rm 11-dev-ofc

# cluster add
argocd cluster add 11-dev-ofc-insecure  --name=11-dev-ofc  --grpc-web
argocd cluster add 12-test-ali-insecure --name=12-test-ali --grpc-web
argocd cluster add 13-stage-sh-insecure --name=13-stage-sh --grpc-web
argocd cluster add 14-prod-sh-insecure  --name=14-prod-sh  --grpc-web
```



### 2.6 proj

```bash
argocd proj list
argocd proj delete argo-example-proj
argocd proj create argo-example-proj --description "argo example proj" 

argocd proj remove-source argo-example-proj  \
    https://git.8ops.top/gce/argocd-example-apps.git
argocd proj add-source argo-example-proj \
    https://git.8ops.top/gce/argocd-example-apps.git

# argocd proj add-destination argo-example-proj in-cluster kube-app --name
argocd proj remove-destination argo-example-proj \
    https://kubernetes.default.svc kube-app
argocd proj add-destination argo-example-proj \
    https://kubernetes.default.svc kube-app 
```



### 2.7 repo

```bash
argocd repo list
argocd repo rm https://git.8ops.top/gce/argocd-example-apps.git
argocd repo add https://git.8ops.top/gce/argocd-example-apps.git \
    --name argo-example-repo \
    --project argo-example-proj \
    --username gatgitlab-read \
    --password jifenpay \
    --insecure-skip-server-verification
```



### 2.8 app

```bash
argocd app list
    
# Create a directory app
argocd app delete guestbook
argocd app create guestbook \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path guestbook \
    --project argo-example-proj \
    --directory-recurse \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm 

# Create a Helm app
argocd app delete helm-guestbook
argocd app create helm-guestbook \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-guestbook \
    --dest-namespace kube-app \
    --project argo-example-proj \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm 

argocd app set helm-guestbook --values values-production.yaml

# Create a Helm app from a Helm repo
argocd app delete helm-repo-redis
argocd app create helm-repo-redis \
    --repo https://charts.bitnami.com/bitnami \
    --helm-chart redis \
    --revision 17.3.14 \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --label author=jesse \
    --label tier=helm \
    --helm-set global.imageRegistry=hub.8ops.top \
    --helm-set image.tag=7.0.5 \
    --helm-set architecture=standalone \
    --helm-set auth.password=jesse \
    --helm-set master.persistence.enabled=false \
    --helm-set metrics.enabled=true \
    --helm-set metrics.image.tag=1.37.0 

argocd app set helm-repo-redis --helm-set master.count=1
argocd app set helm-repo-redis --helm-set replica.persistence.enabled=false

# Create a Helm app from a Helm repo
argocd app delete helm-repo-redis-cluster
argocd app create helm-repo-redis-cluster \
    --repo https://charts.bitnami.com/bitnami \
    --helm-chart redis-cluster \
    --revision 7.5.0 \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --label author=jesse \
    --label tier=helm 
    --values-literal-file cluster-values.yaml

# TODO persistence 未成功移除
argocd app set helm-repo-redis-cluster --helm-set persistence.enabled=false 
argocd app set helm-repo-redis-cluster --helm-set redis.useAOFPersistence=false 
```



### 2.9 app Helm Template

Create a Helm app from a Helm Templates

> sentinel

```bash
helm search repo redis

helm pull bitnami/redis --version 17.3.14 -d /tmp
tar xf /tmp/redis-17.3.14.tgz -C .
mv redis helm-repo-redis-sentinel-tpl

vim helm-repo-redis-sentinel-tpl/values.yaml

helm install --generate-name --dry-run --debug \
  helm-repo-redis-sentinel-tpl \
  -f helm-repo-redis-sentinel-tpl/values.yaml

helm -n kube-app uninstall helm-repo-redis-sentinel-tpl-standalone
helm -n kube-app upgrade --install helm-repo-redis-sentinel-tpl-standalone \
    helm-repo-redis-sentinel-tpl \
    -f helm-repo-redis-sentinel-tpl/sentinel-standalone-values.yaml

helm -n kube-app uninstall helm-repo-redis-sentinel-tpl-replication
helm -n kube-app upgrade --install helm-repo-redis-sentinel-tpl-replication \
    helm-repo-redis-sentinel-tpl \
    -f helm-repo-redis-sentinel-tpl/sentinel-replication-values.yaml

kubectl -n kube-app exec -it redis-client bash
redis-cli -h helm-repo-redis-sentinel-tpl-standalone-headless -a jesse
config get maxmemory

redis-cli -h helm-repo-redis-sentinel-tpl-replication-headless -a jesse info replication
redis-cli -h helm-repo-redis-sentinel-tpl-replication -a jesse info replication
redis-cli -h helm-repo-redis-sentinel-tpl-replication-node-0.helm-repo-redis-sentinel-tpl-replication-headless.kube-app.svc.cluster.local -a jesse info replication

argocd app delete helm-repo-redis-sentinel-tpl-standalone
argocd app create helm-repo-redis-sentinel-tpl-standalone \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-sentinel-tpl \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --values standalone-values.yaml

argocd app delete helm-repo-redis-sentinel-tpl-replication
argocd app create helm-repo-redis-sentinel-tpl-replication \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-sentinel-tpl \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --values replication-values.yaml
```

> cluster

```bash
helm pull bitnami/redis-cluster --version 8.3.1 -d /tmp
tar xf /tmp/redis-cluster-8.3.1.tgz -C .
mv redis-cluster helm-repo-redis-cluster-tpl

vim helm-repo-redis-cluster-tpl/values.yaml

helm install --generate-name --dry-run --debug \
  helm-repo-redis-cluster-tpl \
  -f helm-repo-redis-cluster-tpl/values.yaml
  
helm -n kube-app uninstall helm-repo-redis-cluster-tpl
helm -n kube-app upgrade --install helm-repo-redis-cluster-tpl \
    helm-repo-redis-cluster-tpl \
    -f helm-repo-redis-cluster-tpl/cluster-values.yaml

kubectl -n kube-app rollout restart sts helm-repo-redis-cluster-tpl
kubectl -n kube-app exec -it redis-client bash
redis-cli -h helm-repo-redis-cluster-tpl-headless -a jesse -c
config get maxmemory

argocd app delete helm-repo-redis-cluster-tpl
argocd app create helm-repo-redis-cluster-tpl \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-cluster-tpl \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --values cluster-values.yaml
```



### 2.10 app Helm Dependency

Create a Helm app from a Helm Dependency

> sentinel

```bash
mkdir -p helm-repo-redis-sentinel-dep
cd helm-repo-redis-sentinel-dep

# - name: redis 必须是 bitnami 里面存在的 Charts
cat <<EOF | tee Chart.yaml
apiVersion: v2
name: bitnami-redis
version: "17.3.14"
dependencies:
- name: redis
  version: "17.3.14"
  repository: "https://charts.bitnami.com/bitnami"
EOF

vim sentinel-values.yaml

helm dep build --skip-refresh
helm dep list

helm install --generate-name --dry-run --debug \
  helm-repo-redis-sentinel-dep \
  -f helm-repo-redis-sentinel-dep/standalone-values.yaml
  
helm install --generate-name --dry-run --debug \
  helm-repo-redis-sentinel-dep \
  -f helm-repo-redis-sentinel-dep/replication-values.yaml

argocd app delete helm-repo-redis-sentinel-dep-standalone
argocd app create helm-repo-redis-sentinel-dep-standalone \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-sentinel-dep \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --release-name helm-repo-redis-sentinel-dep-standalone \
    --values standalone-values.yaml
    
argocd app delete helm-repo-redis-sentinel-dep-replication
argocd app create helm-repo-redis-sentinel-dep-replication \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-sentinel-dep \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --release-name helm-repo-redis-sentinel-dep-replication \
    --values replication-values.yaml
```

> cluster

```bash
mkdir -p helm-repo-redis-cluster-dep
cd helm-repo-redis-cluster-dep

# - name: redis-cluster 必须是 bitnami 里面存在的 Charts
cat <<EOF | tee Chart.yaml
apiVersion: v2
name: bitnami-redis
version: "8.3.1"
dependencies:
- name: redis-cluster
  version: "8.3.1"
  repository: "https://charts.bitnami.com/bitnami"
EOF

vim cluster-values.yaml

helm dep build --skip-refresh
helm dep list

helm install --generate-name --dry-run --debug \
  helm-repo-redis-cluster-dep \
  -f helm-repo-redis-cluster-dep/cluster-values.yaml

argocd app delete helm-repo-redis-cluster-dep
argocd app create helm-repo-redis-cluster-dep \
    --repo https://git.8ops.top/gce/argocd-example-apps.git \
    --path helm-repo-redis-cluster-dep \
    --project argo-example-proj \
    --dest-namespace kube-app \
    --dest-server https://kubernetes.default.svc \
    --revision master \
    --sync-policy automated \
    --label author=jesse \
    --label tier=helm \
    --values cluster-values.yaml

# 经验证是非必须的
#    --release-name helm-repo-redis-cluster-dep \ 
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



### 3.3 界面 PARAMETERS 无法识别出 values.yaml

```bash
argocd proj add-source argo-example-proj https://git.8ops.top/gce/argocd-example-apps.git
```

