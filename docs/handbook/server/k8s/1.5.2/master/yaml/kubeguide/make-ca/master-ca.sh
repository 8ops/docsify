#!/usr/bin/bash

# apiserver
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=kingdee.com" -days 5000 -out ca.crt

openssl genrsa -out server.key 2048
openssl req -new -key server.key -subj "/CN=k8s-master" -config master_ssl.cnf -out server.csr

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -extensions v3_req -extfile master_ssl.cnf -out server.crt

# kube-controller-manager
openssl genrsa -out cs_client.key 2048
openssl req -new -key cs_client.key -subj "/CN=k8s-kcm" -out cs_client.csr
openssl x509 -req -in cs_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -out cs_client.crt
