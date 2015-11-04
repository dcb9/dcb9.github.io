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
