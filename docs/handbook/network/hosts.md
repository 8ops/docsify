# hosts

修改hosts后释放dns污染：

## Windows

```
开始 -> 运行 -> 输入cmd -> 在CMD窗口输入
ipconfig /flushdns
```

## Linux

终端输入

```
sudo rcnscd restart
```

对于systemd发行版，请使用命令

```
sudo systemctl restart NetworkManager
```

如果不懂请都尝试下

## MAC

Mac OS X终端输入

```
sudo killall -HUP mDNSResponder
```

## Android

```
开启飞行模式 -> 关闭飞行模式
```

通用方法

```
拔网线(断网) -> 插网线(重新连接网络)
```