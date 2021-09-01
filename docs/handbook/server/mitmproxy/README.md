
ubuntu 

升级 python 版本 （参考python readme）


源更新 cat /etc/apt/sources.list

deb http://archive.ubuntu.com/ubuntu precise main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu precise main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ precise-security restricted main multiverse universe
deb http://archive.ubuntu.com/ubuntu precise-updates restricted main multiverse universe

apt-get install -y build-essential python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev

pip install mitmproxy

Successfully installed Pillow-2.8.1 backports.ssl-match-hostname-3.4.0.2 certifi-14.5.14 cffi-0.9.2 configargparse-0.9.3 cryptography-0.8.2 enum34-1.0.4 lxml-3.4.2 mitmproxy-0.11.3 netlib-0.11.2 passlib-1.6.2 pyOpenSSL-0.14 pyasn1-0.1.7 pycparser-2.10 six-1.9.0 tornado-4.1 urwid-1.3.0

====

centos

升级 python 版本 （参考python readme）

git clone https://github.com/mitmproxy/mitmproxy.git
git clone https://github.com/mitmproxy/netlib.git
git clone https://github.com/mitmproxy/pathod.git
cd mitmproxy
./dev

================================================================================
試過幾次失敗後，最終都能成功安裝在 CentOS 6。問題是出在 Python 2.6 及 Python 3.4。原來「mitmproxy」在 Python 2.7 才能順利安裝。要是使用 CentOS 7 的話，隨機附送的就是 Python 2.7。安裝「mitmproxy」的步驟如下：

1. 下載 Python 的 PIP 工具
wget https://bootstrap.pypa.io/get-pip.py

2. 安裝 Python 2.7 的 PIP
python get-pip.py

3. 下載 Python 的 EZ Setup
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py

4. 安裝 Python 2.7 的 EZ Setup
python ez_setup.py

5. 安裝需要的封包
yum install -y python-pyasn1 python-flask python-urwid python-setuptools python-pip python27-pip newt-python python-devel python27-devel python-pyasn1
yum install -y readline-devel gdbm-devel bzip2-devel ncurses-devel sqlite-devel tk-devel gcc  pyOpenSSL gcc libxml2-devel libxslt-devel libffi-devel openssl-devel
pip install pyOpenSSL netlib

6. 安裝 pyOpenSSL 0.14
easy_install http://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.12.tar.gz

7. 啟動 IP 地址及接口轉發
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8080

8. 生成自簽的 CA 證書給 SSL 監聽之用
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt

9. 執行 mitmproxy
mitmproxy --cert=ca.pem -T --host




