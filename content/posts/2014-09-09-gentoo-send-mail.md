---
title: "How to send E-mail on Gentoo"
date: 2014-09-09T00:00:00+08:00
draft: false
aliases: [/posts/Send-E-mail-on-Gentoo.html]
description: 在我们的服务器上经常可能会出一些预计的错误，当服务器出错的时候，希望机器自动发送邮件给系统管理员，这样我们就能主动发现问题，并解决问题！其实这个需求就非常简单了，服务器只要可以发邮件就行，不需要什么 MTA 邮件传输代理服务器。
tags: ["Gentoo", "Email"]
---

在我们的服务器上经常可能会出一些预计的错误，当服务器出错的时候，希望机器自动发送邮件给系统管理员，这样我们就能主动发现问题，并解决问题！其实这个需求就非常简单了，服务器只要可以发邮件就行，不需要什么 MTA 邮件传输代理服务器。

### 软件安装

~~~bash
$ emerge ssmtp mailx
~~~

### 配置

~~~
$ sudo vim /etc/ssmtp/ssmtp.conf

一般邮箱帐号的配置
root=youremailaccount@somedomain.com
mailhub=smtp.domain.com
rewriteDomain=
hostname=smtp.domain.com
AuthUser=your_user_name
AuthPass=your_password
FromLineOverride=Yes

公司Gmail邮箱的配置
root=duchengbin@jjwxc.com
mailhub=smtp.gmail.com:587
UseSTARTTLS=YES
AuthUser=duchengbin@jjwxc.com
AuthPass=密码
FromLineOverride=YES

配置系统中的用户和对应发件人信息，比如用apache这个用户发邮件它的发件人是谁，用root发邮件它的发件人又是谁。

$ sudo vim /etc/ssmtp/revaliases

一般邮箱帐号

root:youraccount@domain.com:smtp.domain.com
yournormaluser:youraccount@domain.com:smtp.domain.com

公司Gmail邮箱

root:duchengbin@gmail.com:smtp.gmail.com:587
yournormaluser:youraccount@gmail.com:smtp.gmail.com:587
~~~

### 测试发送邮件

~~~
# mailx 接收邮件的地址

主题：

内容，输入完内容按 ctrl+D 你会看到 Cc: 如果你想抄送给谁，就在这里写上他的邮箱，然后按回车就发送了，不填代表不抄送给任何人
~~~

直接使用命令行也可以发送邮件

~~~bash
$ echo "message content" | mailx -s "test subject" 邮件
~~~

以上整理的全部是参考以下链接，原文写的太棒了。[链接](http://ronnybull.com/2011/08/07/gentoo-ssmtp-sending-mail/)

本人的 Gentoo 内核版本为：3.4.9-gentoo
安装的 ssmtp 及 mailx 版本为：
~~~bash
$ emerge -pv ssmtp mailx
[ebuild   R    ] mail-mta/ssmtp-2.64-r2  USE="ipv6 mta ssl -gnutls" 0 kB
[ebuild   R    ] mail-client/mailx-8.1.2.20050715-r6  0 kB
~~~
