
# git clone https://github.com/maxmind/libmaxminddb.git

cd /usr/local/src
git clone --recursive https://github.com/maxmind/libmaxminddb
cd libmaxminddb
./bootstrap
./configure --prefix=/usr/local/maxminddb
make
make install

sh -c "echo /usr/local/maxminddb/lib  >> /etc/ld.so.conf.d/maxminddb.conf"
ldconfig

cat > /etc/profile.d/maxminddb-env.sh <<EOF
export MAXMINDDB_HOME=/usr/local/maxminddb
export PATH=\${MAXMINDDB_HOME}/bin:\$PATH
EOF

use demo:

mmdblookup --file pay/GeoIP2-City.mmdb --ip 8.8.8.8
mmdblookup --file pay/GeoIP2-City.mmdb --ip 8.8.8.8 country names en
mmdblookup --file pay/GeoIP2-City.mmdb --ip 8.8.8.8 city names en
mmdblookup --file pay/GeoIP2-City.mmdb --ip 8.8.8.8 location



# https://github.com/leev/ngx_http_geoip2_module.git

cd /usr/local/src
git clone --recursive https://github.com/leev/ngx_http_geoip2_module
# for nginx
--add-module=../ngx_http_geoip2_module \


./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_spdy_module --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-http_image_filter_module --with-pcre=../pcre-8.36 --add-module=../echo-nginx-module-0.58 --add-module=../nginx-rtmp-module-1.1.7 --add-module=../ngx_cache_purge-2.3 --add-module=../ngx_devel_kit-0.2.19 --add-module=../ngx_pagespeed-release-1.9.32.11-beta --add-module=../redis2-nginx-module-0.12 \
--with-http_geoip_module





http://m.jb51.net/article/86850.htm



