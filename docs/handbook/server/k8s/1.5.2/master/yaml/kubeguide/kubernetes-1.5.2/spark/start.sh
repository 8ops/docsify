#kubectl create -f namespace-spark-cluster.yaml
kubectl create -f spark-master-service.yaml
kubectl create -f spark-master-controller.yaml
kubectl create -f spark-ui-proxy-service.yaml
kubectl create -f spark-ui-proxy-controller.yaml
kubectl create -f spark-worker-controller.yaml
kubectl create -f zeppelin-service.yaml
kubectl create -f zeppelin-controller.yaml
