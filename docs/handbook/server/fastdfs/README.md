
yum install -y binutils tree rsync vim gcc gcc-c++ zlib-devel openssl-devel 

１，安装 libevent
cd /usr/local/src
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xvzf libevent-2.0.21-stable.tar.gz
./configure --prefix=/usr/local/libevent
make 
make install

ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /lib/
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /lib64/
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /usr/lib/
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /usr/lib64/
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /usr/local/lib/
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /usr/local/lib64/

２，安装 fastdfs
wget https://fastdfs.googlecode.com/files/fastdfs-nginx-module_v1.15.tar.gz
wget https://fastdfs.googlecode.com/files/fdfs_client-py-1.2.6.tar.gz
wget https://fastdfs.googlecode.com/files/fastdfs_client_java_v1.24.tar.gz
wget https://fastdfs.googlecode.com/files/fastdfs_client_v1.24.jar; [FastDFS Client API 1.24 for Java (Compiled by JDK 1.6)]

cd /usr/local/src
wget https://fastdfs.googlecode.com/files/FastDFS_v4.06.tar.gz
tar xvzf FastDFS_v4.06.tar.gz
vim make.sh
TARGET_PREFIX=/usr/local/fastdfs
TARGET_CONF_PATH=/usr/local/fastdfs/conf
WITH_HTTPD=1 
WITH_LINUX_SERVICE=1

……
if [ "$1" = "install" ]; then
  cd ..
  cp -f restart.sh $TARGET_PREFIX/bin
  cp -f stop.sh $TARGET_PREFIX/bin

  if [ "$uname" = "Linux" ]; then
    if [ "$WITH_LINUX_SERVICE" = "1" ]; then
      if [ ! -d $TARGET_CONF_PATH ]; then
        mkdir -p $TARGET_CONF_PATH
        cp -f conf/tracker.conf $TARGET_CONF_PATH/
        cp -f conf/storage.conf $TARGET_CONF_PATH/
        cp -f conf/client.conf  $TARGET_CONF_PATH/
        cp -f conf/http.conf    $TARGET_CONF_PATH/
        cp -f conf/mime.types   $TARGET_CONF_PATH/
        cp -f conf/storage_ids.conf $TARGET_CONF_PATH/
        cp -f conf/anti-steal.jpg $TARGET_CONF_PATH/
      fi

      cp -f init.d/fdfs_trackerd /etc/rc.d/init.d/
      cp -f init.d/fdfs_storaged /etc/rc.d/init.d/
      /sbin/chkconfig --add fdfs_trackerd
      /sbin/chkconfig --add fdfs_storaged
    fi
  fi
fi

make.sh C_INCLUDE_PATH=/usr/local/libevent/include LIBRARY_PATH=/usr/local/libevent/lib 
make.sh install

３，配置启动
echo '/usr/local/libevent/include/' >> /etc/ld.so.conf
echo '/usr/local/libevent/lib/' >> /etc/ld.so.conf
ldconfig

vim /etc/profile.d/fdfs-evn.sh
export FASTDFS_HOME=/usr/local/fastdfs
export PATH=$FASTDFS_HOME/bin:$PATH

rm -rf /data/fdfs;mkdir -p /data/fdfs/store{0..1}

vim /usr/local/fastdfs/conf/tracker.conf 
disabled=false 
bind_addr=192.168.1.219
port=22122 
connect_timeout=30 
network_timeout=60 
base_path=/data/fdsf
max_connections=256 
work_threads=4 
store_lookup=2 
store_group=group2 
store_server=0 
store_path=0 
download_server=0 
reserved_storage_space = 1GB 
log_level=info 
run_by_group=
run_by_user=
allow_hosts=*
sync_log_buff_interval = 10 
check_active_interval = 120 
thread_stack_size = 64KB 
storage_ip_changed_auto_adjust = true 
storage_sync_file_max_delay = 86400 
storage_sync_file_max_time = 300 
use_trunk_file = false
slot_min_size = 256 
slot_max_size = 16MB 
trunk_file_size = 64MB 
http.disabled=false 
http.server_port=80 
http.check_alive_interval=30 
http.check_alive_type=tcp
http.check_alive_uri=/status.html
http.need_find_content_type=true 
include /usr/local/fastdfs/conf/http.conf

vim /usr/local/fastdfs/conf/storage_ids.conf 
100001   group1  192.168.1.219 

vim /usr/local/fastdfs/conf/http.conf
http.default_content_type = application/octet-stream  
http.mime_types_filename=/usr/local/fastdfs/conf/mime.types  
http.anti_steal.check_token=false 
http.anti_steal.token_ttl=900 
http.anti_steal.secret_key=FastDFS1234567890 
http.anti_steal.token_check_fail=/usr/local/fastdfs/conf/anti-steal.jpg

/usr/local/fastdfs/bin/fdfs_trackerd /usr/local/fastdfs/conf/tracker.conf

vim /usr/local/fastdfs/conf/storage.conf
disabled=false 
group_name=group1 
bind_addr=192.168.1.219
client_bind=true 
port=23000 
connect_timeout=30 
network_timeout=60 
heart_beat_interval=30 
stat_report_interval=60 
base_path=/data/fdfs
max_connections=256 
buff_size = 256KB 
work_threads=4 
disk_rw_separated = true 
disk_rw_direct = false 
disk_reader_threads = 1 
disk_writer_threads = 1 
sync_wait_msec=50 
sync_interval=0 
sync_start_time=00:00
sync_end_time=23:59
write_mark_file_freq=500 
store_path_count=2 
store_path0=/data/fdfs/store0
store_path1=/data/fdfs/store1
subdir_count_per_path=256 
tracker_server=192.168.1.219:22122
log_level=info 
run_by_group=
run_by_user=
allow_hosts=*
file_distribute_path_mode=0 
file_distribute_rotate_count=100 
fsync_after_written_bytes=0 
sync_log_buff_interval=10 
sync_binlog_buff_interval=10 
sync_stat_file_interval=300 
thread_stack_size=512KB 
upload_priority=10 
if_alias_prefix=
check_file_duplicate=0
key_namespace=FastDFS 
keep_alive=0 
http.disabled=false 
http.domain_name=
http.server_port=80 
http.trunk_size=256KB 
http.need_find_content_type=true 
#include /usr/local/fastdfs/conf/http.conf

vim /usr/local/fastdfs/conf/client.conf
connect_timeout=30 
network_timeout=60 
base_path=/data/fdfs
tracker_server=192.168.1.219:22122
log_level=info 
http.tracker_server_port=80
#include /usr/local/fastdfs/conf/http.conf

/usr/local/fastdfs/bin/fdfs_storaged /usr/local/fastdfs/conf/storage.conf

/usr/local/fastdfs/bin/fdfs_test /usr/local/fastdfs/conf/client.conf upload /etc/passwd

４，测试使用
netstat -nutlp

rm -rf /data/fdfs;mkdir -p /data/fdfs/store{0..1}
/usr/local/fastdfs/bin/stop.sh /usr/local/fastdfs/conf/tracker.conf
/usr/local/fastdfs/bin/fdfs_trackerd /usr/local/fastdfs/conf/tracker.conf
/usr/local/fastdfs/bin/stop.sh /usr/local/fastdfs/conf/storage.conf
/usr/local/fastdfs/bin/fdfs_storaged /usr/local/fastdfs/conf/storage.conf

/etc/init.d/fdfs_trackerd restart
/etc/init.d/fdfs_storaged restart

/usr/local/fastdfs/bin/fdfs_test /usr/local/fastdfs/conf/client.conf upload /etc/passwd
/usr/local/fastdfs/bin/fdfs_upload_file /usr/local/fastdfs/conf/client.conf /etc/passwd

５，Nginx 安装

http://192.168.1.22/nginx/pcre-8.33.tar.gz
http://192.168.1.22/nginx/nginx-1.4.7.tar.gz

useradd --uid=616 nginx

cd /usr/local/src
tar xvzf fastdfs-nginx-module_v1.15.tar.gz
tar xvzf pcre-8.33.tar.gz
mv pcre-8.33 /usr/local/pcre
tar xzvf nginx-1.4.7.tar.gz
cd nginx-1.4.7

vim src/core/nginx.h
#define NGINX_VERSION "1.1_1.4.7"
#define NGINX_VER "UPLUS_SERVER/" NGINX_VERSION
#define NGINX_VAR "UPLUS_SERVER"
#define NGX_OLDPID_EXT ".oldbin"

vim src/http/ngx_http_header_filter_module.c
static char ngx_http_server_string[] = "Server: UPLUS_SERVER" CRLF;

./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_gzip_static_module --with-http_stub_status_module --with-pcre=/usr/local/src/pcre-8.33 --add-module=/usr/local/src/fastdfs-nginx-module/src
make
make install

vim /etc/profile.d/nginx-env.sh
export NGINX_HOME=/usr/local/nginx
export PATH=$NGINX_HOME/sbin:$PATH

cp /usr/local/src/fastdfs-nginx-module/src/mod_fastdfs.conf /usr/local/fastdfs/conf/mod_fastdfs.conf











