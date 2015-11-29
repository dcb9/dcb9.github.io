---
layout: post
title: 本地开发——TCP Proxy 解决 API 必须绑定 IP 白名单才能访问的问题
categories: tools
---

本次对接一个票务系统的时候，**他们那边的 API 访问需要在白名单的才可以访问**，当时我就提出了个问题

问：那我在本地怎么调试开发啊？（因为我开发机 IP 是不固定的）

答：测试环境也要加，要不然怎么开发呢？

想了一下跟他们争肯定是争不过的了，那就是如何满足他们，想了一下，我有自己的公网服务器 IP，本地测试环境直接请求这台机器，它再把请求转发给相应的 API，这样我不管在哪里都可以开发了。

API 那边的 Host 还是 IP，即 http://x.x.y.z:port/api-route，这样服务端的那里只需要一个 TCP Proxy 就可以了，Google 了一下 **[tcproxy](https://github.com/dccmx/tcproxy)** 这个小巧的非常入眼。


### 安装及使用

```shell
$ git clone https://github.com/dccmx/tcproxy.git
$ cd tcproxy && make ; echo $?  # 输出 0 代表安装成功
$ nohup ./src/tcproxy "0.0.0.0:19999 -> rr{x.x.y.z:port}" &
```

代码里面的 Host 直接换成我自己的 ip:19999 端口就可以访问了。

使用这个有个注意的点，就是你的代码要有环境之分，不同的环境应可以自定义配置，参考 [12 Factor 的配置](http://12factor.net/zh_cn/config)