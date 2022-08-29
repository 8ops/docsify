# 实战 | Rancher 初识

[docs](https://docs.rancher.cn)



## 单体安装

```bash
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  hub.8ops.top/third/rancher:v2.6.7 \
  --no-cacerts
  
# unsuccess  
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  -v /opt/certs/8ops.top.crt:/etc/rancher/ssl/cert.pem \
  -v /opt/certs/8ops.top.key:/etc/rancher/ssl/key.pem \
  -v /opt/certs/8ops.top.pem:/etc/rancher/ssl/cacerts.pem \
  --privileged \
  hub.8ops.top/third/rancher:v2.6.7 \
  --no-cacerts
```



## 基于 Helm 安装



