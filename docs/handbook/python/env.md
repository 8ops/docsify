# env

常用方式

1. 编译安装
2. virtual
3. [pyenv](https://github.com/pyenv/pyenv)



## pyenv

cache 

提前下载`Python-xx.tar.xz`至`~/.pyenv/cache/`



openssl 版本过低

```bash
Installing Python-3.8.4...
ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?
```

安装openssl

```bash
# 1.下贼openssl
wget https://www.openssl.org/source/openssl-1.1.1a.tar.gz
tar -zxvf openssl-1.1.1a.tar.gz
cd openssl-1.1.1a
# 2.编译安装
./config --prefix=/usr/local/openssl no-zlib #不需要zlib
make
make install
# 3.备份原配置
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl/ /usr/include/openssl.bak
# 4.新版配置
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
# 5.修改系统配置
## 写入openssl库文件的搜索路径
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf.d/openssl-x86_64.conf
## 使修改后的/etc/ld.so.conf生效 
ldconfig -v
# 6.查看openssl版本
openssl version
```

编译安装

```bash
./configure --prefix=/usr/local/python-3.8.4 --enable-optimizations --with-openssl=/usr/local/openssl
make && make install
```

重新pyenv安装 

```bash
LD_RUN_PATH="/usr/local/openssl/lib" \
LDFLAGS="-L/usr/local/openssl/lib" \
CPPFLAGS="-I/usr/local/openssl/include" \
CFLAGS="-I/usr/local/openssl/include" \
CONFIGURE_OPTS="--with-openssl=/usr/local/openssl" \
pyenv install 3.8.4

```

提示优化

```bash
MAKE_OPTS="-j8" \
  CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-computed-gotos" \
  CFLAGS="-march=native -O2 -pipe" \
  pyenv install -v 3.8.4
```

