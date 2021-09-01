

################################# 自建直播 ######################################
./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx-rtmp \
--with-pcre=/usr/local/src/pcre2-10.10 \
--add-module=/usr/local/src/nginx-rtmp-module-1.1.7 \
--add-module=/usr/local/src/nginx-rtmp-module-1.1.7/hls \
--add-module=/usr/local/src/nginx-rtmp-module-1.1.7/dash 

./configure \
--prefix=/usr/local/nginx-rtmp \
--add-module=../nginx-rtmp-module-1.1.7 \
--with-http_ssl_module \
--with-pcre=/usr/local/src/pcre-8.33

./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx-rtmp \
--add-module=/usr/local/src/nginx-rtmp-module-1.1.7 \
--with-http_ssl_module \
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
--with-file-aio \
--with-ipv6 \
--with-http_spdy_module \
--with-pcre=/usr/local/src/pcre-8.33 \
--with-debug 

http://192.168.1.6:8080/record.html
http://192.168.1.6:8080/index.html

http://192.168.1.6:8080/rtmp-publisher/publisher.html
http://192.168.1.6:8080/rtmp-publisher/player.html

http://server.com/control/record/start|stop?srv=SRV&app=APP&name=NAME&rec=REC
curl -i "http://192.168.1.6:8080/control/record/start?app=myapp&name=mystream&rec=rec1"
curl -i "http://192.168.1.6:8080/control/record/stop?app=myapp&name=mystream&rec=rec1"

http://server.com/control/drop/publisher|subscriber|client?srv=SRV&app=APP&name=NAME&addr=ADDR&clientid=CLIENTID
curl -i "http://192.168.1.6:8080/control/drop/publisher?app=myapp&name=mystream"
curl -i "http://192.168.1.6:8080/control/drop/client?app=myapp&name=mystream"
curl -i "http://192.168.1.6:8080/control/drop/client?app=myapp&name=mystream&addr=192.168.0.1"
curl -i "http://192.168.1.6:8080/control/drop/client?app=myapp&name=mystream&clientid=1"

http://server.com/control/redirect/publisher|subscriber|client?srv=SRV&app=APP&name=NAME&addr=ADDR&clientid=CLIENTID&newname=NEWNAME


Accept-Encoding:gzip,deflate,sdch
Content-Encoding:gzip

################################# 七牛直播 ######################################
https://portal.qiniu.com
带SDK直播工具
http://77fycs.com2.z0.glb.qiniucdn.com/pili-guide-v1.pdf

1，operate@youja.cn
2，youja
3，*.qn.live.youja.cn


| 加速域名                                 | IN QINIU CNAME                        
|-----------------------------------------|----------------------------------------
| pili-publish.qn.live.youja.cn           | 1000033.publish.z1.pili.qiniudns.com
| pili-live-rtmp.qn.live.youja.cn         | 1000033.live-rtmp.z1.pili.qiniudns.com
| pili-live-hdl.qn.live.youja.cn          | 1000033.live-hdl.z1.pili.qiniudns.com
| pili-live-hls.qn.live.youja.cn          | 1000033.live-hls.z1.pili.qiniudns.com
| pili-playback.qn.live.youja.cn          | 1000033.playback.z1.pili.qiniudns.com
| pili-media.qn.live.youja.cn             | 1000033.media.z1.pili.qiniudns.com    
| pili-vod.qn.live.youja.cn               | 1000033.vod.z1.pili.qiniudns.com      
| pili-static.qn.live.youja.cn            | 1000033.static.z1.pili.qiniudns.com


https://github.com/pili-engineering/pili-sdk-java
https://github.com/pili-engineering/pili-sdk-python


1, Create a new Stream
2, To JSON string

{
publishSecurity: "static",
hub: "youja",
title: "564aa509eb6f925e92000b0d",
publishKey: "5d6757f0b0c46a72",
disabled: false,
hosts: {
live: {
http: "pili-live-hls.qn.live.youja.cn",
hdl: "pili-live-hdl.qn.live.youja.cn",
hls: "pili-live-hls.qn.live.youja.cn",
rtmp: "pili-live-rtmp.qn.live.youja.cn"
},
playback: {
http: "pili-playback.qn.live.youja.cn",
hls: "pili-playback.qn.live.youja.cn"
},
play: {
http: "pili-live-hls.qn.live.youja.cn",
rtmp: "pili-live-rtmp.qn.live.youja.cn"
},
publish: {
rtmp: "pili-publish.qn.live.youja.cn"
}
},
updatedAt: "2015-11-17T11:54:49.495+08:00",
id: "z1.youja.564aa509eb6f925e92000b0d",
createdAt: "2015-11-17T11:54:49.495+08:00"
}

rtmp://pili-publish.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d?key=5d6757f0b0c46a72

https://obsproject.com/ #### OBS

https://dl.youja.cn/camera/PLCameraStreamingKit-Example.ipa

{
u'url': u'http://pili-static.qn.live.youja.cn/recordings/z1.youja.564aa509eb6f925e92000b0d/camera.m3u8', 
u'persistentId': u'z1.564add36f51b826f470167c8', 
u'targetUrl': u'http://pili-media.qn.live.youja.cn/recordings/z1.youja.564aa509eb6f925e92000b0d/camera.mp4'
}
http://pili-media.qn.live.youja.cn/recordings/z1.youja.564aa509eb6f925e92000b0d/camera.mp4?v=123

{"publishSecurity": "static", "hub": "youja", "title": "564aa509eb6f925e92000b0d", "publishKey": "5d6757f0b0c46a72", "disabled": false, "hosts": {"live": {"http": "pili-live-hls.qn.live.youja.cn", "hdl": "pili-live-hdl.qn.live.youja.cn", "hls": "pili-live-hls.qn.live.youja.cn", "rtmp": "pili-live-rtmp.qn.live.youja.cn"}, "playback": {"http": "pili-playback.qn.live.youja.cn", "hls": "pili-playback.qn.live.youja.cn"}, "play": {"http": "pili-live-hls.qn.live.youja.cn", "rtmp": "pili-live-rtmp.qn.live.youja.cn"}, "publish": {"rtmp": "pili-publish.qn.live.youja.cn"}}, "updatedAt": "2015-11-17T11:54:49.495+08:00", "id": "z1.youja.564aa509eb6f925e92000b0d", "createdAt": "2015-11-17T11:54:49.495+08:00"}


http://192.168.1.6:8080/live/get/publish/stream/z1.youja.564aa509eb6f925e92000b0d (在用)

http://192.168.1.6:8080/live/get/play/rtmp/z1.youja.564aa509eb6f925e92000b0d (在用)
http://192.168.1.6:8080/live/get/play/http/z1.youja.564aa509eb6f925e92000b0d (在用)
http://192.168.1.6:8080/live/get/play/mp4/z1.youja.564aa509eb6f925e92000b0d
http://192.168.1.6:8080/live/get/play/flv/z1.youja.564aa509eb6f925e92000b0d
http://192.168.1.6:8080/live/get/play/jpg/z1.youja.564aa509eb6f925e92000b0d

http://192.168.1.6:8080/live/get/connect/status/z1.youja.564aa509eb6f925e92000b0d

http://192.168.1.6:8080/live/set/play/status/disable/z1.youja.564aa509eb6f925e92000b0d
http://192.168.1.6:8080/live/set/play/status/enable/z1.youja.564aa509eb6f925e92000b0d

{u'duration': 311, u'start': 1447744434, u'segments': [{u'start': 1447744434, u'end': 1447744493}, {u'start': 1447747634, u'end': 1447747666}, {u'start': 1447747700, u'end': 1447747717}, {u'start': 1447747996, u'end': 1447748019}, {u'start': 1447748105, u'end': 1447748114}, {u'start': 1447748131, u'end': 1447748134}, {u'start': 1447748221, u'end': 1447748232}, {u'start': 1447748270, u'end': 1447748273}, {u'start': 1447749625, u'end': 1447749638}, {u'start': 1447749644, u'end': 1447749673}, {u'start': 1447749724, u'end': 1447749724}, {u'start': 1447750367, u'end': 1447750368}, {u'start': 1447750444, u'end': 1447750555}], u'end': 1447750555}

rtmp://pili-publish.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d?key=5d6757f0b0c46a72
{'ORIGIN': u'rtmp://pili-live-rtmp.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d'}
{'ORIGIN': u'http://pili-live-hls.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d.m3u8'}
{'ORIGIN': u'http://pili-live-hdl.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d.flv'}
{'ORIGIN': u'http://pili-playback.qn.live.youja.cn/youja/564aa509eb6f925e92000b0d.m3u8?start=0&end=1447912481'}

http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8
http://ztest.qiniudn.com/sintel.m3u8


################################# 万象直播 ######################################
http://www.qcloud.com/product/LVB.html



http://zijian.aliyun.com/
http://www.alibench.com/


==> ffmpeg version 2.8.2
cd /home/jesse/workspace/links/Downloads

Streaming without conversion (given test.mp4 codecs are compatible with RTMP)
ffmpeg -re -i shield.mp4 -c copy -f flv rtmp://live.api.youja.cn/myapp/mystream

Streaming and encoding audio (AAC) and video (H264), need libx264 and libfaac
ffmpeg -re -i shield.mp4 -c:v libx264 -c:a libfaac -ar 44100 -ac 1 -f flv rtmp://live.api.youja.cn/myapp/mystream
ffmpeg -re -i shield.mp4 -ar 44100 -ac 1 -f flv rtmp://live.api.youja.cn/myapp/mystream

Streaming and encoding audio (MP3) and video (H264), need libx264 and libmp3lame
ffmpeg -re -i shield.mp4 -c:v libx264 -c:a libmp3lame -ar 44100 -ac 1 -f flv rtmp://live.api.youja.cn/myapp/mystream
ffmpeg -re -i shield.mp4 -ar 44100 -ac 1 -f flv rtmp://live.api.youja.cn/myapp/mystream

Streaming and encoding audio (Nellymoser) and video (Sorenson H263)
ffmpeg -re -i shield.mp4 -c:v flv -c:a nellymoser -ar 44100 -ac 1 -f flv rtmp://live.api.youja.cn/myapp/mystream

Publishing video from webcam
sudo apt-get install -y libx264-120 libx264-dev
ffmpeg -f video4linux2 -i /dev/video0 -c:v libx264 -an -f flv rtmp://live.api.youja.cn/myapp/mystream
ffmpeg -f video4linux2 -i /dev/video0 -an -f flv rtmp://live.api.youja.cn/myapp/mystream

Playing with ffplay
ffplay rtmp://localhost/myapp/mystream

Stream your X screen through RTMP
ffmpeg -f x11grab -follow_mouse centered -r 25 -s cif -i :0.0 -f flv rtmp://live.api.youja.cn/myapp/screen

================================= Control ======================================

curl -i "http://live.api.youja.cn/control/record/start?app=myapp&name=mystream&rec=rec1"
curl -i "http://live.api.youja.cn/control/record/stop?app=myapp&name=mystream&rec=rec1"

curl -i "http://live.api.youja.cn/control/drop/publisher?app=myapp&name=mystream"
curl -i "http://live.api.youja.cn/control/drop/client?app=myapp&name=mystream"
curl -i "http://live.api.youja.cn/control/drop/client?app=myapp&name=mystream&addr=192.168.1.102"
curl -i "http://live.api.youja.cn/control/drop/client?app=myapp&name=mystream&clientid=1"



