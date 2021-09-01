# proxy

`~/.ssh/config`

**ProxyCommand**

```bash
Host jump
    HostName 10.10.10.10
    Port 22
    User root
    IdentityFile ~/.ssh/id_rsa

Host 10.10.10.*
    Port 22
    User root
    IdentityFile ~/.ssh/id_rsa
    ProxyCommand ssh jump -W %h:%p
```

**ProxyJump**

```bash
$ ssh jump
$ ssh 10.10.10.100
```

