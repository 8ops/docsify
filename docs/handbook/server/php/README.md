
yum install -y gcc gcc-c++ autoconf automake zlib* fiex* libxml* ncurses-devel libmcrypt* libtool-ltdl-devel* make cmake
yum install -y libxml2.x86_64 libxml2-devel.x86_64 bzip2-devel.x86_64 bzip2-libs.x86_64 bzip2.x86_64 php-fpm.x86_64
yum install -y libcurl-devel.x86_64 libcurl.x86_64
yum install -y libevent.x86_64 libevent-devel.x86_64
yum install -y gd.x86_64 gd-devel.x86_64 
yum install -y libpng.x86_64 libpng-devel.x86_64

cd /usr/local/src
wget http://cn2.php.net/distributions/php-5.6.10.tar.gz
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.5.0.1.tar.gz
wget http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.14/libpng-1.6.14.tar.gz
wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz
wget http://jaist.dl.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.gz
wget http://superb-dca2.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
wget http://curl.haxx.se/download/curl-7.39.0.tar.gz

#xxxxxx
cd /usr/local/src
tar -zxvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure --prefix=/usr/local/libevent --disable-shared
make && make install

cd /usr/local/src
tar -xzvf freetype-2.5.0.1.tar.gz
cd freetype-2.5.0.1
./configure --prefix=/usr/local/freetype
make && make install

#xxxxxx
cd /usr/local/src
tar -zxvf libpng-1.6.14.tar.gz
cd libpng-1.6.14
./configure --prefix=/usr/local/libpng
make && make install

cd /usr/local/src
tar -zxvf jpegsrc.v9a.tar.gz
cd jpeg-9a
./configure --prefix=/usr/local/libjpeg --enable-shared
make && make install

cd /usr/local/src
tar -zxvf pcre-8.36.tar.gz
cd pcre-8.36
./configure --prefix=/usr/local/pcre --enable-jit --enable-utf8 --enable-unicode-properties
make && make install

cd /usr/local/src
tar -zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=/usr/local/libmcrypt
make && make install

cd /usr/local/src
tar -zxvf curl-7.39.0.tar.gz
cd curl-7.39.0
./configure --prefix=/usr/local/curl --enable-threaded-resolver --enable-ipv6
make && make install

cd /usr/local/src
tar -zxvf php-5.6.10.tar.gz
cd php-5.6.10
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc  --with-curl=/usr/local/curl --with-jpeg-dir=/usr/local/libjpeg --with-png-dir --with-freetype-dir=/usr/local/freetype --with-mcrypt=/usr/local/libmcrypt --with-pcre=/usr/local/pcre --with-openssl --with-gd --enable-bcmath --with-zlib --with-bz2 --enable-mbstring --enable-pcntl --enable-sockets --enable-ftp --with-pear --with-gettext  --enable-fastcgi --enable-fpm --disable-debug --disable-pdo --enable-pic --disable-rpath --enable-inline-optimization --with-xml --enable-sysvsem --enable-sysvshm --enable-mbregex --with-mhash --enable-xslt --enable-memcache --enable-zip --with-pcre-regex --with-mysql
make && make install

yum install -y php-fpm.x86_64 php-mysql.x86_64

location ~ \.php$ {   
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}

cat > /etc/profile.d/php-env.sh <<EOF
export PHP_HOME=/usr/local/php
export PATH=\$PHP_HOME/bin:\$PATH
EOF
. /etc/profile
echo $PATH
which php


