# 实战 | ArgoCD 使用



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







