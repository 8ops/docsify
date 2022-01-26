

kubectl -n kube-server port-forward service/quickstart-es-http 9200
kubectl -n kube-server port-forward service/quickstart-kb-http 5601

kubectl -n kube-server get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'

