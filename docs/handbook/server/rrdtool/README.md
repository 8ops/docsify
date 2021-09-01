
rrdtool create /tmp/test01.rrd --step 3 DS:testnumber:COUNTER:5:0:U RRA:AVERAGE:0.5:1:28800 RRA:AVERAGE:0.5:10:2880 RRA:MAX:0.5:10:2880 RRA:LAST:0.5:10:2880

while true
do
N=$((1$(date +%N)%100))
echo $(date) $N
rrdtool update /tmp/test01.rrd N:$N
sleep 3
done

rrdtool fetch -r 3 /tmp/test01.rrd AVERAGE

rrdtool graph test.png -s -3600 -w 700 -h 400 -t "test number" -v "number/y" DEF:test123=/tmp/test01.rrd:testnumber:AVERAGE:step=3 LINE1:test123#FF0000:"number"


================================================================================
rrdtool create /tmp/cpu.rrd --start $(date -d '1 days ago' +%s) --step 15 DS:cpu_user:GAUGE:120:0:NaN DS:cpu_system:GAUGE:120:0:NaN DS:cpu_wio:GAUGE:120:0:NaN DS:cpu_idle:GAUGE:120:0:NaN RRA:AVERAGE:0.5:1:244 RRA:AVERAGE:0.5:24:244 RRA:AVERAGE:0.5:168:244 RRA:AVERAGE:0.5:672:244 RRA:AVERAGE:0.5:5760:374 

while true
do
date
rrdtool updatev /tmp/cpu.rrd $(date +%s):0.733211:0.433261:1.516414:97.317114
sleep 15
done

rrdtool fetch -r 15 /tmp/cpu.rrd AVERAGE

/usr/bin/rrdtool graph /tmp/cpu.png --start '-3600' --end N --width 385 --height 190 --title '过去一小时CPU使用情况' --upper-limit 100 --lower-limit 0 --vertical-label 百分比 --rigid DEF:'cpu_user'='/tmp/cpu.rrd':'cpu_user':AVERAGE AREA:'cpu_user'#FF0000:'用户' VDEF:cpu_user_last=cpu_user,LAST VDEF:cpu_user_avg=cpu_user,AVERAGE GPRINT:'cpu_user_last':' Now\:%5.1lf%s' GPRINT:'cpu_user_avg':' Avg\:%5.1lf%s\j' DEF:'cpu_system'='/tmp/cpu.rrd':'cpu_system':AVERAGE STACK:'cpu_system'#33cc33:'系统' VDEF:cpu_system_last=cpu_system,LAST VDEF:cpu_system_avg=cpu_system,AVERAGE GPRINT:'cpu_system_last':' Now\:%5.1lf%s' GPRINT:'cpu_system_avg':' Avg\:%5.1lf%s\j' DEF:'cpu_wio'='/tmp/cpu.rrd':'cpu_wio':AVERAGE STACK:'cpu_wio'#1C86EE:'等待' VDEF:cpu_wio_last=cpu_wio,LAST VDEF:cpu_wio_avg=cpu_wio,AVERAGE GPRINT:'cpu_wio_last':' Now\:%5.1lf%s' GPRINT:'cpu_wio_avg':' Avg\:%5.1lf%s\j' DEF:'cpu_idle'='/tmp/cpu.rrd':'cpu_idle':AVERAGE STACK:'cpu_idle'#e2e2f2:'空闲' VDEF:cpu_idle_last=cpu_idle,LAST VDEF:cpu_idle_avg=cpu_idle,AVERAGE GPRINT:'cpu_idle_last':' Now\:%5.1lf%s' GPRINT:'cpu_idle_avg':' Avg\:%5.1lf%s\j'






================================================================================


# for ubuntu 
apt-get install -y libxml2-dev libpng12-dev libfreetype6-dev libfreetype6-dev 
apt-get install -y rrdtool python-rrdtool


# for redhat
yum install -y cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel

cat > /etc/profile.d/rrdtool-env.sh <<EOF
export PKG_CONFIG_PATH=/usr/lib/pkgconfig/
export RRDTOOL_PATH=/usr/local/rrdtool
export PATH=\$RRDTOOL_PATH/bin:\$PATH
EOF
. /etc/profile
echo $PATH

cd /usr/local/src
wget http://oss.oetiker.ch/rrdtool/pub/rrdtool-1.5.3.tar.gz
tar xvzf rrdtool-1.5.3.tar.gz
cd rrdtool-1.5.3
./configure --prefix=/usr/local/rrdtool
make && make install







