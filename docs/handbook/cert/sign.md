# 证书签发

## 个人签发

方式一

通过openssl生成私钥

```bash
openssl genrsa -out server.key 1024
```

使用私钥生成自签名的cert证书文件

```bash
openssl req -new -x509 -days 3650 -key server.key -out server.crt -subj "/C=CN/ST=OPS/L=OPS/O=OPS/OU=OPS/CN=ops.top/CN=*.8ops.top"
```

方式二

通过openssl生成私钥

```bash
openssl genrsa -out server.key 1024
```

根据私钥生成证书申请文件csr

```bash
openssl req -new -key server.key -out server.csr
```

这里根据命令行向导来进行信息输入

使用私钥对证书申请进行签名从而生成证书

```bash
openssl x509 -req -in server.csr -out server.crt -signkey server.key -days 3650
```

方式三

直接生成证书文件

```bash
openssl req -new -x509 -keyout server.key -out server.crt -config openssl.cnf
```




## 机构签发

```bash
openssl genrsa -out autobestdevops.com.key 2048
```

申请文件

```bash
openssl req -new -key autobestdevops.com.key -out autobestdevops.com.csr
```

## Let's enscript

[acme.sh](<https://github.com/Neilpang/acme.sh>)

By `dnspod`  

```bash
export DP_Id=
export DP_Key=

acme.sh --issue \
-d 8ops.top \
-d *.8ops.top \
-d *.api.8ops.top \
-d *.dev.8ops.top \
-d *.test.8ops.top \
-d *.uat.8ops.top \
-d *.prod.8ops.top \
--dns dns_dp \
--debug 2

acme.sh --install-cert \
-d 8ops.top \
--key-file /data/ca/8ops.top.key \
--fullchain-file /data/8ops.top.crt

acme.sh --renew -d 8ops.top -f
```

