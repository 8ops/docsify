#!/usr/bin/bash

# kubelet
openssl genrsa -out kubelet_client.key 2048
openssl req -new -key kubelet_client.key -subj "/CN=k8s-node" -out kubelet_client.csr
openssl x509 -req -in kubelet_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -out kubelet_client.crt
