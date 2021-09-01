kubectl create -f heapster-service.yaml
kubectl create -f influxdb-service.yaml
kubectl create -f grafana-service.yaml
kubectl create -f influxdb-grafana-controller.yaml
kubectl create -f heapster-controller.yaml
