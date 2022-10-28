# 实战 | 使用Docker

## 一、常用技巧

### 1.1 docker基础镜像

- Alpine,-
- Slim
- Stretch
- Buster
- Jessie
- Bullseye
- windowsservercore



### 1.2  容器随机启动

```bash
# 1，容器启动时
docker run --restart=
  no           默认策略，在容器退出时不重启容器
  on-failure   在窗口非正常退出时（退出状态非0），才会重启容器
  on-failure:3 在容器非正常退出时重启容器，最多重启3次
  always       在容器退出时总是重启容器

# 2，容器运行中
docker update --restart=always <container id>

```



