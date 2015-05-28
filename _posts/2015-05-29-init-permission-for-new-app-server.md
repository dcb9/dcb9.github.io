---
layout: post
title: 对于一台新服务器权限的配置
categories: 工作
---

作为一个程序员，在网站没有运维的情况下，也要有能够搭建应用的能力，由于不是专业的运维所以考虑的问题可能不够全面，只顾着把应用搭起来，权限管理非常地松，认为只要登陆 `root` 可以运行命令就行了，这样的话会有很多后患的，有的时候只是未爆发出来，当爆发出来就已经晚了。

以下是我对一台新服务器的权限的实例，欢迎大家拍砖。

一、技术人员通过自己的普通用户权限进入系统，然后如果要运行需要 `root` 执行的就用 `sudo` 去执行就好，如果有多人要登录，则每人配一个帐号。

二、服务器上应该禁止密码登录，因为密码登录有一定的漏洞，有的技术人员设的密码跟没搞过计算机一样来个 `123456`，这个密码就相当于是个后门了。

三、由于每个人都有了帐号，那么更理所当然的要把 `root` 用户禁止登录，通过经验得知，如果不禁止，有的人还要登 `root`，原因可能有以下三点

1. 不明白为什么要有普通帐号 
2. 对安全看的太轻，认为每次都要 `sudo` 去运行一个 `root` 权限才执行的命令很麻烦 
用户管理
3. 可能不懂权限，或许听说过，但绝对没用过

四、修改默认 `ssh` 端口

## 添加帐号

```
$ useradd bob
$ mkdir -p /home/bob
$ chown -R bob.bob /home/bob

$ gpasswd -a bob sudo // 给用户有 sudo 的权限
$ passwd bob  设置一个密码，这个是作为当用户想要 sudo 去执行 root 执行的时候使用的
```


## 本地配置免密码登录 

本地 `ssh-keygen` 生成一串密钥

```
本地 $ ssh-keygen
  /Users/bob/.ssh/some-app-server_id_rsa
  本地 $ ssh-copy-id -i .ssh/some-app-server_rsa bob@remote-server-address

```

配置ssh 客户端，方便以后连接服务器。

```
  本地 $ vim ~/.ssh/config
  Host some-app-server
    Hostname remote-server-address
    User bob
    Port 19422    
    IdentityFile ~/.ssh/some-app-server_id_rsa

```

以后连接服务器就可以直接 `$ ssh some-app-server` 就可以用你的权限登录进去了。

## 配置 ssh 服务端

```
$ vi /etc/ssh/sshd_config  
PasswordAuthentication no //禁止使用基于口令认证的方式登陆
PubkeyAuthentication yes //允许使用基于密钥认证的方式登陆
Port 19422 // 把 ssh 端口改成 19422 这个别固定，你可以随便用，本地要连接服务器，本地的端口得保持一致。
PermitRootLogin no // 不允许 root 远程登录

重户服务器 $ reboot 使配置生效
```

本人再推荐一个 `zsh` 和 `oh-my-zsh` 有了这个，命令行就智能了好多，操作起来非常地方便，有兴趣的自己去找找文档。

<p align="right"> —— 会一样东西不是本事，从不会到会的，才是真本事</p>
