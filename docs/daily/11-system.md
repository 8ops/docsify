# 系统管理

 

## 一、常用操作

```bash
# 获取 linux 操作系统的位数 
getconf LONG_BIT

```





## 二、用户

```bash
# 添加用户
useradd jesse

# 添加到sudoer
# user01	ALL=(ALL) 	ALL # sudo -s 需要密码切换
# user02   ALL=(ALL)       NOPASSWD:ALL # 免密切换
jesse	ALL=(ALL) 	ALL


```



## 三、SSH

```bash
ssh -i hostname -l username
Unable to negotiate with 10.101.11.200 port 222: no matching host key type found. Their offer: ssh-rsa,ssh-dss

ssh -V
OpenSSH_9.0p1, LibreSSL 3.3.6

# 需要降级加密算法
~/.ssh/config
HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa
```



## 四、VIM

### 4.1 语法高亮

```bash
# 查看colorscheme
ls /usr/share/vim/vim*/colors/ ~/.vim/colors
/usr/share/vim/vim90/colors:
README.txt     default.vim    elflord.vim darkblue.vim

~/.vim/colors:
solarized.vim

# vim /usr/share/vim/vimrc 
vim ~/.vimrc
syntax enable
set background=dark
colorscheme darkblue
set ruler
```

