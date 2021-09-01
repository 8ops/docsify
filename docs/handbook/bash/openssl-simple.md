# openssl

查看`pem`信息

```bash
openssl x509 -noout -text -in root.pem
```

查看`p12`信息

```bash
openssl pkcs12 -in root.p12  | \
openssl x509 -noout -text
```

查看签发时间

```bash
openssl x509 -noout -enddate -startdate -in root.crt
```

