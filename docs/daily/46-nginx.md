# Nginx

## 一、ROOT美化

### 1.1 样式一

```bash
# server.conf
server {
    listen 48080;
    root /opt/autoindex;
    charset utf-8;
    autoindex on;
    autoindex_localtime on;
    autoindex_exact_size off;
    add_after_body /autoindex.html;
}
```





### 1.2 样式二

```bash
# server.conf
server {
    listen 48080;
    root /opt/autoindex;
    charset utf-8;
    autoindex on;
    autoindex_localtime on;
    autoindex_exact_size off;
    add_before_body /.autoindex/header.html;
    add_after_body /.autoindex/footer.html;
}    
```



