# nginx



## 主配置

`nginx.conf`

```bash
user  nginx;
worker_processes  auto;

error_log  /data/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    use epoll;
    worker_connections  65535;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format logex '{"timestamp":"$time_iso8601","msec":"$msec","remote_port":"$remote_port","method":"$request_method","server_name":"$host","uri":"$uri","args":"$args","server_protocol":"$server_protocol","http_user_agent":"$http_user_agent","http_referer":"$http_referer","http_cookie":"$http_cookie","request_time":"$request_time","response_time":"$upstream_response_time","remote_addr":"$remote_addr","upstream_http_location":"$upstream_http_location","x_real_ip":"$http_x_real_ip","x_forwarded_for":"$http_x_forwarded_for","upstream_addr":"$upstream_addr","response_code":"$status","upstream_response_code":"$upstream_status","request_length":"$request_length","content_length":"$content_length","bytes_sent":"$bytes_sent","body_bytes_sent":"$body_bytes_sent","scheme":"$scheme"}';

    access_log  /data/log/nginx/access.log  logex;

    # gzip
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 6;
    gzip_types text/plain application/javascript application/x-javascript text/javascript text/xml text/css;
    gzip_disable "MSIE [1-6]\.";
    gzip_vary on;
    underscores_in_headers on;

    sendfile        on;
    tcp_nopush      on;
    keepalive_timeout  60;
    tcp_nodelay     on;
    charset UTF-8;

    # base
    server_tokens off;
    server_names_hash_max_size 1024;
    server_names_hash_bucket_size 128;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    client_max_body_size  50m;
    client_header_timeout 30;
    client_body_timeout   30;
    send_timeout          60;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 1800;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 8 128k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 128k;

    # temp
    client_body_temp_path /dev/shm/client_body_temp;
    fastcgi_temp_path /dev/shm/fastcgi_temp;
    proxy_temp_path /dev/shm/proxy_temp;
    scgi_temp_path /dev/shm/scgi_temp;
    uwsgi_temp_path /dev/shm/uwsgi_temp;

    # proxy
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header CLIENT_IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout 60;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    proxy_headers_hash_max_size 51200;
    proxy_headers_hash_bucket_size 6400;
    proxy_buffer_size 16k;
    proxy_buffers 8 32k;
    proxy_busy_buffers_size 128k;
    proxy_temp_file_write_size 128k;
    proxy_http_version 1.1;
    proxy_next_upstream off;
    server_name_in_redirect off;

    # default 80
    server {
        listen 80 default;
        rewrite ^.*$ https://$host$uri permanent;
    }

    include conf.d/ops/*.conf;
    include conf.d/site/*.conf;
    include conf.d/wiki/*.conf;
}
```



## 证书配置

`ssl/8ops.top`

```bash
listen 443 ssl;
ssl_certificate     ssl/8ops.top.crt;
ssl_certificate_key ssl/8ops.top.key;
ssl_session_timeout 5m;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
```



## 流量管理

`deny/8ops.top`

```bash
allow 8.8.8.8/32;

deny all;
```



## 熔断管理

`return`

```bash
location / {
       default_type text/plain;
       return 403 "Deny";
}
```





## 应用配置

`www.8ops.top.conf`

```bash
server {
    include ssl/8ops.top;
    server_name www.8ops.top;
    access_log /data/log/nginx/www.8ops.top_access.log logex;
    error_log /data/log/nginx/www.8ops.top_error.log;
    location / {
        proxy_pass https://10.0.0.1:8080;
    }
}
```



## 日志切割

`/etc/logrotate.d/nginx`

```bash
/data/log/nginx/*.log
/var/log/nginx/*.log {
        daily
        missingok
        rotate 30
        compress
        delaycompress
        notifempty
        create 644 nginx adm
        sharedscripts
        postrotate
                if [ -f /var/run/nginx.pid ]; then
                        kill -USR1 `cat /var/run/nginx.pid`
                fi
        endscript
}
```



## 文件下载

`attachment`

```bash
location / {
        if ($request_filename ~* ^.*?\.(html|doc|pdf|zip|docx)$) {
            add_header  Content-Disposition attachment;
            add_header  Content-Type application/octet-stream;
        }
}
```

