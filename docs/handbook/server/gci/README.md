
1, install influxdb
# for 0.8.x
cd /usr/local/src
wget https://s3.amazonaws.com/influxdb/influxdb-0.8.8-1.x86_64.rpm
yum localinstall influxdb-0.8.8-1.x86_64.rpm

# for 0.9.x
cd /usr/local/src
wget http://influxdb.s3.amazonaws.com/influxdb-0.9.2-1.x86_64.rpm
yum localinstall influxdb-0.9.2-1.x86_64.rpm
/etc/init.d/influxdb start

config: /etc/opt/influxdb/influxdb.conf
...
meta:/var/opt/influxdb/meta
data:/var/opt/influxdb/data

ln -s /usr/share/gocode/src/github.com/influxdb/influxdb/configuration/config.toml /opt/influxdb/config.toml
vim /opt/influxdb/config.toml
...
[input_plugins.collectd]
enabled = true
address = "0.0.0.0" 
port = 25826
database = "collectd"
typesdb = "/usr/share/collectd/collectd.db"


2, install grafana
cd /usr/local/src
wget https://grafanarel.s3.amazonaws.com/builds/grafana-2.1.2.linux-x64.tar.gz
tar xvzf grafana-2.1.2.linux-x64.tar.gz
mv grafana-2.1.2 /usr/local
/usr/local/grafana/bin/grafana-server

vim /etc/supervisord.conf
...
[program:grafana]
command=/usr/local/grafana/bin/grafana-server
autostart=true
autorestart=true
user=root
log_stdout=true
log_stderr=true
logfile=/var/log/supervisor/grafana.log

3, install collectd
yum install collectd.x86_64
#or
#cd /usr/local/src
#wget https://collectd.org/files/collectd-5.5.0.tar.gz
#tar xvzf collectd-5.5.0.tar.gz

config: /etc/collectd.conf
...
LoadPlugin network
...
<Plugin network>
        <Server "10.10.10.62" "25826">
        </Server>
        TimeToLive "128"
        <Listen "10.10.10.62" "25826">
        </Listen>
        MaxPacketSize 1024
        Forward true
        ReportStats false
        CacheFlush 1800
</Plugin>

4, use

# create db
curl -i -G http://10.10.10.62:8086/query --data-urlencode "q=CREATE DATABASE gcidb"
curl -i -XPOST 'http://10.10.10.62:8086/write?db=gcidb' \
--data-binary 'cpu_load_short,host=10.10.10.62,region=gci value=0.64 1440328196000000000'
curl -i -XPOST 'http://10.10.10.62:8086/write?db=gcidb' \
--data-binary 'cpu_load_short,host=10.10.10.61,region=gci value=0.91 1440328160000000000
cpu_load_short,host=10.10.10.62,region=gci value=0.58 1440328180000000000
cpu_load_short,host=10.10.10.63,region=gci value=0.36 1440328190000000000'



