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







