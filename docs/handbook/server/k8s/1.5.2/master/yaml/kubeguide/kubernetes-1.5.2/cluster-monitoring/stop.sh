kubectl delete -f heapster-service.yaml
kubectl delete -f influxdb-service.yaml
kubectl delete -f grafana-service.yaml
kubectl delete -f influxdb-grafana-controller.yaml
kubectl delete -f heapster-controller.yaml
