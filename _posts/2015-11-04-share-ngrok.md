---
layout: post
title: 另一个国内的 Ngrok 服务器分享
categories: tools
---

ngrok 2.0 开始收费了，国内好几个 ngrok 倒下了，于是搭了一个供大家玩耍，只要还有钱就会给服务器续费的！

### 使用方法

- 去百度云盘下载对应的客户端 <a href="http://pan.baidu.com/s/1bnwROLL" target="_blank">http://pan.baidu.com/s/1bnwROLL</a>
- 创建配置文件 *ngrok.cfg*

```
server_addr: "tunnel.phpor.me:4443"
trust_host_root_certs: false
```

- 运行 `$ ngrok -config ngrok.cfg -subdomain example 8080`

### News

* 2015-12-28

> 20: 54 ~ 21: 27 故障

* 2015-12-24

> 好消息好消息，现在已经使用 DaoCloud + 腾讯云方式来部署了

> 中间遇到了 N 多的坑，来吐槽两个

>> 由于制作 ngrok 服务端的镜像是只有程序，没有可执行文件，需要在启动容器的时候去生成，但是腾讯云又无法连接 Google 和 GitHub，所以只能想办法把安装 Build 到镜像里面了，幸好 DaoCloud 在构建的时候是可以下载的，构建好了也没有报错。

>> 但是线上的容器启动时就是没有可执行的 ngrokd 命令，我在本地拉取镜像，然后发现确实没有这个命令，但是重新执行一下就有这个命令了，于是我在 Dockerfile 里面又写了一遍安装命令，再测试一遍发现还是如此。最后没有办法我就在本地把 ngrokd 这个文件生成好，然后拷贝到镜像里面去，直接执行这个二进制文件就完全正常了。

>> 后来去翻了 tutum/ngrok 的 Dockerfile 源码，才发现原来他把 ngrokd 的这个目录设置成了 VOLUME，导致每次启动容器的时候这个里面的文件就空了。

>> 大家要是想搭建 Docker 版的 Ngrok 服务端可以参考：[ngrokd-docker](https://github.com/dcb9/docker/tree/master/ngrok-server)，直接拷贝过去，把证书替换一下就可以用了。现在的 docker-compose.yml 内容如下：

>> ```yml
>> ngrok:
>>  image: YOUR_IMAGE_URL
>>  net: host
>>  environment:
>>  - DOMAIN=tunnel.phpor.me
>> ```

>> -------------------

>> 不知道大家发现没有，其实证书这样子放在代码库里面太危险了，这种就应该拉出去枪毙，但是呢，我的部署点在 DaoCloud 上面，那里部署就只能用环境变量的形式，需要对容器的网络设置为 host，就只能用应用编排了。其实可以把证书放到环境变量里面，注入进去就好了，这样就不用存在代码库里面了，但是 DaoCloud 这边对应用编排的时候好像有对单行的长度做一定的限制，导致一个环境变量应该是在一行的变成了两行！！！

* 2015-12-17

> Bob 的 Ngrok 服务一直是放在某云上面的，一个月是 90 RMB ，现在是第二个月了，费用还是很贵的。

> 昨天 DaoCloud 上对老用户年终大回馈，可以免费领腾讯的优惠券， Bob 一共抽了 700 块左右的钱（个人帐号+公司组织帐号+兄弟的帐号 一般人只能拿到 200 左右的优惠券吧），已经够用一年的了，从下个月开始服务转移到腾讯云上，部署的方式也会改成 DaoCloud 的方式——容器大法，所以请大家放心使用！

> 最后还是非常感谢 DaoCloud，所有的 V 友建议都是了解一下，对自己百利而有一害（中毒太深）！
