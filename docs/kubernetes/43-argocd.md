# 实战 | ArgoCD 使用



```bash

helm repo add argo https://argoproj.github.io/argo-helm

helm search repo argo-cd
helm show values argo/argo-cd > argocd-configs.yaml-5.4.2-default
helm install -n kube-server \
    argo-cd argo/argo-cd \
    -f argocd-configs.yaml-5.4.2 \
    --version 5.4.2

helm upgrade --install -n kube-server \
    argo-cd argo/argo-cd \
    -f argocd-configs.yaml-5.4.2 \
    --version 5.4.2
     
    
kubectl -n kube-server get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```







