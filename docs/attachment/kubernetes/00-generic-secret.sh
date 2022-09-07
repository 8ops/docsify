
kubectl get ns kube-app || kubectl create ns kube-app
kubectl get ns kube-server || kubectl create ns kube-server

kubectl get secret tls-8ops.top || \
    kubectl create secret tls tls-8ops.top --cert=app/lib/8ops.top.crt --key=app/lib/8ops.top.key
kubectl -n kube-app get secret tls-8ops.top || \
    kubectl -n kube-app create secret tls tls-8ops.top --cert=app/lib/8ops.top.crt --key=app/lib/8ops.top.key
kubectl -n kube-server get secret tls-8ops.top || \
    kubectl -n kube-server create secret tls tls-8ops.top --cert=app/lib/8ops.top.crt --key=app/lib/8ops.top.key

