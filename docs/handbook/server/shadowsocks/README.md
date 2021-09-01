shadowsocks
shadowvpn

==
https://github.com/shadowsocks/shadowsocks/wiki

{
    "server":"my_server_ip",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}

ssserver -vv --pid-file /tmp/s.pid --log-file=/tmp/s.log -c t1.json -d start
or
ssserver -p 443 -k password -m aes-256-cfb --user nobody -d start


==
https://github.com/clowwindy/ShadowVPN/wiki

git clone https://github.com/langlichuan123/ShadowVPN.git
yum install -y -q autoconf268.noarch # > V2.6.8
sed -i 's/autoconf/autoconf268/g' autogen.sh
git submodule update --init
./autogen.sh
./configure --enable-static --sysconfdir=/etc
make && sudo make install





