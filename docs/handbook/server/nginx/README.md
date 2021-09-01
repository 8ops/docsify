


cd /usr/local/src

wget http://192.168.1.22/nginx/nginx-1.4.7.tar.gz 
wget http://192.168.1.22/nginx/nginx-mogilefs-module-1.0.5.tar.gz
wget http://192.168.1.22/nginx/nginx-requestkey-module-1.0.tar.gz
wget http://192.168.1.22/nginx/pcre-8.33.tar.gz

yum install -y zlib.x86_64 zlib-devel.x86_64 gzip.x86_64 pcre.x86_64 pcre-devel.x86_64

useradd -M nginx 
mkdir -p /data/logs/nginx

vim src/core/nginx.h
#define NGINX_VERSION "1.0_1.4.7"
#define NGINX_VER "UPLUS_SERVER/" NGINX_VERSION
#define NGINX_VAR "UPLUS_SERVER"
#define NGX_OLDPID_EXT ".oldbin"

vim src/http/ngx_http_header_filter_module.c
static char ngx_http_server_string[] = "Server: UPLUS_SERVER" CRLF;

./configure \
--prefix=/usr/local/nginx \
--user=nginx \
--group=nginx \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_stub_status_module 

make && make install


=======

yum install -y  binutils make cmake vim gcc gcc-devel
yum install -y pcre-devel.x86_64 pcre.x86_64
yum install -y openssl-devel.x86_64 openssl.x86_64
yum install -y gd-devel.x86_64 gd.x86_64
yum install -y GeoIP-devel.x86_64 GeoIP.x86_64
yum install -y libxml2-devel.x86_64 libxml2.x86_64 libxslt-devel.x86_64 libxslt.x86_64

vim src/core/nginx.h
...
#define nginx_version      1006002
#define NGINX_VERSION      "1.1_1.6.2"
#define NGINX_VER          "UPLUS_SERVER/" NGINX_VERSION

#define NGINX_VAR          "UPLUSE_SERVER"
#define NGX_OLDPID_EXT     ".oldbin"
...

vim src/http/ngx_http_header_filter_module.c
...
static char ngx_http_server_string[] = "Server: UPLUS_SERVER" CRLF;
...

cat > /etc/profile.d/nginx-env.sh <<EOF
export NGINX_HOME=/usr/local/nginx
export PATH=\${NGINX_HOME}/sbin:\$PATH
EOF
. /etc/profile
echo $PATH
which nginx

UPLUS_SERVER/1.1_1.6.2

./configure --prefix=/usr/local/nginx  --user=nginx --group=nginx --conf-path=/usr/local/nginx/conf/nginx.conf --error-log-path=/usr/local/nginx/logs/error.log --http-client-body-temp-path=/usr/local/nginx/body --http-fastcgi-temp-path=/usr/local/nginx/fastcgi --http-log-path=/usr/local/nginx/logs/access.log --http-proxy-temp-path=/usr/local/nginx/proxy --http-scgi-temp-path=/usr/local/nginx/scgi --http-uwsgi-temp-path=/usr/local/nginx/uwsgi --lock-path=/var/run/nginx.lock --pid-path=/var/run/nginx.pid --with-debug --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-sha1=/usr/include/openssl --with-md5=/usr/include/openssl --with-mail --with-mail_ssl_module --with-http_gunzip_module 

make && make install


./configure \
--prefix=/usr/local/nginx \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-http_spdy_module \
--with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector \
--param=ssp-buffer-size=4 -m64 -mtune=generic'

# add-module nginx-rtmp-module
./configure \
--prefix=/usr/local/nginx \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-http_spdy_module \
--with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector \
--param=ssp-buffer-size=4 -m64 -mtune=generic' \
--add-module=../nginx-rtmp-module-1.1.7 \
--with-pcre=../pcre-8.33

================================================================================

./configure  \
--prefix=/usr/local/nginx  \
--user=nginx  \
--group=nginx  \
--with-http_ssl_module  \
--with-http_realip_module  \
--with-http_addition_module  \
--with-http_sub_module  \
--with-http_dav_module  \
--with-http_flv_module  \
--with-http_mp4_module  \
--with-http_gunzip_module  \
--with-http_gzip_static_module  \
--with-http_random_index_module  \
--with-http_secure_link_module  \
--with-http_stub_status_module  \
--with-http_auth_request_module  \
--with-mail  \
--with-mail_ssl_module  \
--with-file-aio  \
--with-ipv6  \
--with-http_spdy_module  \
--with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'  \
--with-http_image_filter_module \
--with-pcre=../pcre-8.36  \
--add-module=../echo-nginx-module-0.58 \
--add-module=../nginx-rtmp-module-1.1.7  \
--add-module=../ngx_cache_purge-2.3 \
--add-module=../ngx_devel_kit-0.2.19 \
--add-module=../lua-nginx-module-0.10.0 \
--add-module=../ngx_pagespeed-release-1.9.32.11-beta  \
--add-module=../redis2-nginx-module-0.12 \
--add-module=../sqlite-http-basic-auth-nginx-module-master 


make && make install

#(未成功)--add-module=../ngx_image_thumb \
#(未成功)--add-module=../nginx-requestkey-module \

wget http://uplus.file.youja.cn/nginx/pcre-8.36.tar.gz

--------------------------

--with-http_image_filter_module # images_filter
yum install gd-devel # gcc automake autoconf m4
apt-get install libgd2-xpm libgd2-xpm-dev # build-essential m4 autoconf automake make libcurl-dev libgd2-dev libpcre-dev 

conf: 
image_filter test; #测试图片合法性
image_filter rotate 90|180|270; #角度旋转
image_filter size; #获取图片的ID3信息宽和高
resize [width] [height]; #指定宽和高
image_filter crop [width] [height]; #最大边缩放图片后裁剪
image_filter_buffer; #限制图片最大读取大小，默认为1M
image_filter_jpeg_quality; #设置jpeg图片的压缩质量比例
image_filter_transparency; #用来禁用gif和palette-based的png图片的透明度，以此来提高图片质量。

--------------------------

--add-module=../ngx_pagespeed-release-1.10.33.1-beta  \ 
# google optimze image
cd /usr/local/src
NPS_VERSION=1.10.33.1
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzvf ${NPS_VERSION}.tar.gz

--------------------------

--add-module=../ngx_image_thumb # ngx_image_thumb，未编译通过
image on/off 是否开启缩略图功能,默认关闭
image_backend on/off 是否开启镜像服务，当开启该功能时，请求目录不存在的图片（判断原图），将自动从镜像服务器地址下载原图
image_backend_server 镜像服务器地址
image_output on/off 是否不生成图片而直接处理后输出 默认off
image_jpeg_quality 75 生成JPEG图片的质量 默认值75
image_water on/off 是否开启水印功能
image_water_type 0/1 水印类型 0:图片水印 1:文字水印
image_water_min 300 300 图片宽度 300 高度 300 的情况才添加水印
image_water_pos 0-9 水印位置 默认值9 0为随机位置,1为顶端居左,2为顶端居中,3为顶端居右,4为中部居左,5为中部居中,6为中部居右,7为底端居左,8为底端居中,9为底端居右
image_water_file 水印文件(jpg/png/gif),绝对路径或者相对路径的水印图片
image_water_transparent 水印透明度,默认20
image_water_text 水印文字 "Power By Vampire"
image_water_font_size 水印大小 默认 5
image_water_font 文字水印字体文件路径
image_water_color 水印文字颜色,默认 #000000

--------------------------

--add-module=../nginx-rtmp-module-1.1.7  \ # rtmp
#RTMP
wget http://uplus.file.youja.cn/nginx/nginx-rtmp-module-1.1.7.tar.gz


--------------------------

--add-module=../ngx_cache_purge
#清除缓存文件
git clone https://github.com/FRiCKLE/ngx_cache_purge.git

proxy_cache_path /dev/shm levels=1:2 keys_zone=jcache:128m inactive=1d max_size=256m;  
server {
    listen      80;

    location ~* ^/purge(/\S+)$ {
        proxy_cache_purge jcache $1;
    }

    location ~* .*\.(jpg|png|gif|css|js)$ {
        proxy_cache jcache;
        proxy_cache_valid 200 302 30m;
        proxy_cache_key $uri;
        proxy_set_header Host "www.baidu.com";
        proxy_pass http://www.baidu.com;
    }

    location / {
        proxy_set_header Host "www.youja.cn";
        proxy_pass http://www.baidu.com;
    }
}

http://domain
http://domain/purge/test.png

--------------------------

--add-module=../nginx-requestkey-module
#key加密验证 （未通过）估计高版本不支持此功能，或module待更新
https://github.com/miyanaga/nginx-requestkey-module.git

（官方貌似没了）下载文件：Nginx-accesskey-2.03.tar.gz 
解压后 修改conf文件，把”$HTTP_ACCESSKEY_MODULE“替换为"ngx_http_accesskey_module",然后编译nginx;
accesskey
语句: accesskey [on|off]
默认: accesskey off
可以用在: main, server, location
开启 access-key 功能。
accesskey_arg
语句: accesskey_arg "字符"
默认: accesskey "key"
可以用在: main, server, location
URL中包含 access key 的GET参数。
accesskey_hashmethod
语句: accesskey_hashmethod [md5|sha1]
默认: accesskey_hashmethod md5（默认用 md5 加密）
可以用在: main, server, location
用 MD5 还是 SHA1 加密 access key。
accesskey_signature
语句: accesskey_signature "字符"
默认: accesskey_signature "$remote_addr"
可用在: main, server, location

location / {
   default_type text/plain; 
   accesskey             on;
   accesskey_hashmethod  md5;
   accesskey_arg         "key";
   accesskey_signature   "jesse$uri";
   return 200 "OK";
}

--------------------------

--add-module=../redis2-nginx-module-0.12
#操作redis
https://github.com/openresty/redis2-nginx-module.git

upstream redis_pool{
    server 127.0.0.1:6379;
}

server {
    listen      80;

    location ~* "^/(\w+)$" {
        redis2_query $1;
        redis2_pass redis_pool;
    }

    location ~* "^/(\w+)/(\w+)$" {
        redis2_query $1 $2;
        redis2_pass redis_pool;
    }

    location ~* "^/(\w+)/(\w+)/(\w+)$" {
        redis2_query $1 $2 $3;
        redis2_pass redis_pool;
    }

    location ~* "^/(\w+)/(\w+)/(\w+)/(\w+)$" {
        redis2_query $1 $2 $3 $4;
        redis2_pass redis_pool;
    }
    location ~* "^/(\w+)/(\w+)/(\w+)/(\w+)/(\w+)$" {
        redis2_query $1 $2 $3 $4 $5;
        redis2_pass redis_pool;
    }

    location / {
        default_type text/plain;
        return 200 "Not found $uri";
    }
}

curl http://domain/set/one/first
curl http://domain/get/one

--------------------------

--add-module=../sqlite-http-basic-auth-nginx-module-master
https://github.com/kunal/sqlite-http-basic-auth-nginx-module.git
#sqlite使用
location / {
        auth_sqlite_basic "Restricted Sqlite";
        auth_sqlite_basic_database_file  /dev/shm/sqlite3.db; # Sqlite DB file
        auth_sqlite_basic_database_table  auth_table; # Sqlite DB table
        auth_sqlite_basic_table_user_column  user; # User column
        auth_sqlite_basic_table_passwd_column  password; # Password column
   }

--------------------------


Nginx + Lua

wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar xvzf LuaJIT-2.0.4.tar.gz
cd LuaJIT-2.0.4
make && make install

cat > /etc/profile.d/lua-env.sh << EOF
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0

EOF

wget -O lua-nginx-module-0.10.0.tar.gz https://codeload.github.com/openresty/lua-nginx-module/tar.gz/v0.10.0
wget -O ngx_devel_kit-0.2.19.tar.gz https://codeload.github.com/simpl/ngx_devel_kit/tar.gz/v0.2.19

tar xvzf lua-nginx-module-0.10.0.tar.gz
tar xvzf ngx_devel_kit-0.2.19.tar.gz 

--add-module=../ngx_devel_kit-0.2.19 \
--add-module=../lua-nginx-module-0.10.0

cannot open shared object file: No such file or directory  解决方法

ldd /usr/local/nginx/sbin/nginx

echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf

location /lua {
    set $test "hello, world.";
    content_by_lua '
        ngx.header.content_type = "text/plain";
        ngx.say(ngx.var.test);
    ';
}

--------------------------

echo-nginx-module

--add-module=../echo-nginx-module-0.58

wget -O echo-nginx-module-0.58.tar.gz https://codeload.github.com/openresty/echo-nginx-module/tar.gz/v0.58

location /echo {
    default_type text/plain;
    echo "Hello, jesse";

}

--------------------------

-- 2016-04-26 1.10.0 support stream

./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-pcre=../pcre-8.38 --with-http_image_filter_module --add-module=../nginx-rtmp-module-1.1.7 --add-module=../ngx_cache_purge --with-stream


stream {
    upstream test_tcp {
        server 127.0.0.1:11111 weight=5;
        server 127.0.0.1:11112 max_fails=3 fail_timeout=30s;
    }

    upstream test_udp {
        server 127.0.0.1:11111 weight=5;
        server 127.0.0.1:11112 max_fails=3 fail_timeout=30s;
    }

    server {
       listen 12345;
       proxy_connect_timeout 1s;
       proxy_timeout 3s;
       proxy_responses 1;
       proxy_pass test_tcp;
   }

    server {
       listen 12345 udp;
       proxy_connect_timeout 1s;
       proxy_timeout 3s;
       proxy_responses 1;
       proxy_pass test_tcp;
    }
}

-- 2016-08-30 lua


cat > /etc/profile.d/openresty-env.sh <<EOF
export OPENRESTY_HOME=/usr/local/openresty
export PATH=\${OPENRESTY_HOME}/bin:\${OPENRESTY_HOME}/luajit/bin:\$PATH
EOF


https://openresty.org/download/ngx_openresty-1.9.7.2.tar.gz

https://openresty.org/download/openresty-1.11.2.1.tar.gz





