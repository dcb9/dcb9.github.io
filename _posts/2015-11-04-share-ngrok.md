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

* 2015-12-17

> Bob 的 Ngrok 服务一直是放在某云上面的，一个月是 90 RMB ，现在是第二个月了，费用还是很贵的。

> 昨天 DaoCloud 上对老用户年终大回馈，可以免费领腾讯的优惠券， Bob 一共抽了 700 块左右的钱（个人帐号+公司组织帐号+兄弟的帐号 一般人只能拿到 200 左右的优惠券吧），已经够用一年的了，从下个月开始服务转移到腾讯云上，部署的方式也会改成 DaoCloud 的方式——容器大法，所以请大家放心使用！

> 最后还是非常感谢 DaoCloud，所有的 V 友建议都是了解一下，对自己百利而有一害（中毒太深）！
