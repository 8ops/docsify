# Python

`2.x.x`注定被时代淘汰，`3.x.x`大势所趋

> 常用方式

- 编译安装
- virtual
- [pyenv](https://github.com/pyenv/pyenv)



> <optional>安装openssl

```bash
# openssl 版本过低
# Installing Python-3.10.2...
# ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?

# 1.下贼openssl
OPENSSL_VERSION=1.1.1o
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar -zxvf openssl-${OPENSSL_VERSION}.tar.gz
cd openssl-${OPENSSL_VERSION}

# 2.编译安装
./config --prefix=/usr/local/openssl no-zlib #不需要zlib
make && make install

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

# 7.环境加载lib
LD_RUN_PATH="/usr/local/openssl/lib" \
LDFLAGS="-L/usr/local/openssl/lib" \
CPPFLAGS="-I/usr/local/openssl/include" \
CFLAGS="-I/usr/local/openssl/include" \
CONFIGURE_OPTS="--with-openssl=/usr/local/openssl" 
```



## 编译安装

```bash
./configure --prefix=/usr/local/python-3.8.4 --enable-optimizations --with-openssl=/usr/local/openssl
make && make install
```



## pyenv

<optoinal>`cache `提前下载`Python-xx.tar.xz`至`~/.pyenv/cache/`

> [pyenv](https://github.com/pyenv/pyenv)

```bash
# 1.下载pyenv
rm -rf ~/.pyenv
PYENV_VERSION=2.2.4-1
curl -s -o /tmp/pyenv-${PYENV_VERSION}.tar.gz https://m.8ops.top/python/pyenv-${PYENV_VERSION}.tar.gz
tar xzf /tmp/pyenv-${PYENV_VERSION}.tar.gz
mv pyenv-${PYENV_VERSION} ~/.pyenv

# 2.初始pyenv环境
grep -q PYENV_ROOT ~/.profile | cat >> ~/.profile <<EOF
export PYENV_ROOT="~/.pyenv"
export PATH="\${PYENV_ROOT}/bin:\$PATH"
eval "\$(pyenv init --path)"
EOF

grep -q PYENV_ROOT ~/.bashrc | cat >> ~/.bashrc <<EOF
export PYENV_ROOT="~/.pyenv"
export PATH="\${PYENV_ROOT}/bin:\$PATH"
eval "\$(pyenv init --path)"
EOF

. ~/.bashrc

# validate
pyenv --version
```



> [python](https://www.python.org/downloads/source/)

```bash

mkdir -p ~/.pyenv/cache
curl -s -o ~/.pyenv/cache/Python-3.10.2.tar.xz https://m.8ops.top/python/Python-3.10.2.tar.xz

# ubuntu's install require package
apt install -y gcc make binutils build-essential zlib1g-dev \
    libffi-dev libbz2-dev  libsqlite3-dev \
    libreadline-dev lib64readline-dev libncurses5-dev libncursesw5-dev libssl-dev 

## centos's install require package
# yum install gcc gcc-c++ autoconf automake binutils make cmake wget openssl-devel libsqlite3x libffi-devel httpd-devel libsqlite3x-devel ncurses-devel bzip2-devel bzip2-libs bzip2 readline-devel readline mod-wsgi

pyenv install 3.10.2

# 提示建议优化，重新安装即可
MAKE_OPTS="-j8" \
  CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-computed-gotos" \
  CFLAGS="-march=native -O2 -pipe" \
  pyenv install -v 3.10.2
  
# 可以安装多个版本在一个系统中，选择指定版本为使用状态
pyenv global 3.10.2

mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF

pip install --upgrade pip
```



> MacBook Pro

```bash
mkdir -p ~/.pyenv/cache

wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tar.xz \
    -O ~/.pyenv/cache/Python-3.11.2.tar.xz 

env \
  PATH="$(brew --prefix tcl-tk)/bin:$PATH" \
  LDFLAGS="-L$(brew --prefix tcl-tk)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" \
  CPPFLAGS="-I$(brew --prefix tcl-tk)/include -L$(brew --prefix zlib)/include -L$(brew --prefix bzip2)/include" \
  PKG_CONFIG_PATH="$(brew --prefix tcl-tk)/lib/pkgconfig" \
  CFLAGS="-I$(brew --prefix tcl-tk)/include -I$(brew --prefix openssl)/include -I$(brew --prefix bzip2)/include -I$(brew --prefix zlib)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include" \
  LDFLAGS="-I$(brew --prefix tcl-tk)/lib -L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" \
  MAKE_OPTS="-j8" \
  CC=gcc pyenv install -v 3.11.2

```

## 片外

[常用模块](https://docs.python.org/3/py-modindex.html)

```bash
python -m http.server 8000
```

