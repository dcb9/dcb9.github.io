---
title: "Apple Push Services .cer to .pem"
date: 2017-03-09T00:00:00+08:00
draft: false
aliases: [/posts/Apple-Push-Services-cer-to-pem.html]
description: Download certificates file, and install into your KeyChain **`login`** group (if you install into `system` group that you can't export p12).
tags: ["工作"]
---

Download certificates file, and install into your KeyChain **`login`** group (if you install into `system` group that you can't export p12).

#### Convert p12 to pem:

~~~shell
$ openssl pkcs12 -in Certificates.p12 -out Certificates.pem -nodes
~~~

#### Check validity

~~~shell
$ openssl x509 -in Certificates.pem -noout -dates
~~~

#### Test pem

##### Dev

~~~shell
$ openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert Certificates.pem -key Certificates.pem
~~~

##### Prod

~~~shell
$ openssl s_client -connect gateway.push.apple.com:2195 -cert Certificates.pem -key Certificates.pem
~~~
