---
layout: post
title: Yii2 项目部署流程
categories: 工作 Yii
---

网上现在有许多关于在Yii2下进行开发的文章，但对于如何把程序优雅地部署到线上介绍的还不是很多，下面我就来介绍一下我自己的部署流程。

## 概述

本地修改代码 -> 提交至版本控制仓库 -> master 分支有修改时自动部署到服务器

### 代码托管到 GitHub

原来也用过 coding.net，用了两个月发现它在许多地方表现的不是很如意，所以就迁到 GitHub 了。

## 修改代码

本地修改代码时不要直接修改 master 分支的代码，而是切出一个分支来做这个功能，做好之后把这个分支提交到远端仓库，功能完成之后，发起一个 Pull Request（后面就用 PR 代替），由另一个开发来检查一下代码，如果没有问题就合并到 master 分支。

当你的功能出来之后，需要同步到其它开发者，和线上服务器。你可能修改的代码如下：

* 依赖新的软件包 <sup><a href="#info3">[3]</a></sup>
* 修改环境配置信息 <sup><a href="#info1">[1]</a></sup>
* 创建或修改了数据库结构 <sup><a href="#info2">[2]</a></sup>

另一个开发是不知道要如何部署的，除非你把全部的部署命令告诉他，于是我们创建一个脚本来解决这个问题，让一切自动完成，其它开发并不需要知道你又做了些什么，只需要做两件事：a. 更新代码 b. 运行部署脚本，线上服务器同样也只需要做这两件事，但脚本肯定不同，因为本地环境会安装许多的 debug 软件，而线上不需要，以及环境初始化的参数也不一样。

开发环境的部署脚本：

```shell
#!/bin/bash

#./bin/dev/deploy.sh

composer install # 它来把 composer 所有的依赖安装好
./init  --env=Development --overwrite=y  # 重新初始化环境配置

# 等等 我们还有许多别的，例如： bower install ，因为我们的静态资源是使用的 bower 来管理的 
```

线上部署脚本：

```shell
#!/bin/bash
# file ./bin/prod/deploy.sh

# ... ...  
composer install --prefer-dist --no-dev --no-progress --optimize-autoloader

# 初始化 php 环境变量
./init --env=Production --overwrite=y

# git submodule
git submodule init
git submodule update
```

### 本地有一个测试环境是很重要的

如果本地没有测试环境，那会使开发效率大打折扣，因为每一次都要到线上才能测试，而且很容易会出问题，后果不堪设想，博主现在用的还是 Vagrant， Docker 也挺想尝试，最近赶项目没腾出时间来学习呢。

## 使用 dploy.io 进行自动部署

以前也尝试自己写自动部署的钩子，直到我用了 dploy.io 之后我就不写了，因为 dploy.io 比自己写要好得太多了，它可以监测到哪个项目的哪个分支有改动，然后去做一些什么事情，而且在执行的时候日志都可以完全浏览到，话说它还有回滚功能（虽然没用过），每一次的部署过程都可以回看，让我们了解错在哪里。

只需要两步就能完成

1. 配置好 dploy.io 进入需要部署的服务器的权限
2. 更新的时候需要执行哪些命令

部署命令是：

```shell
cd projectRoot
git pull origin master
./bin/prod/deploy.sh   
# 这个脚本里面包含了许多内容：
# 安装 composer 依赖包，bower 软件包，静态资源发布，项目环境初始化
```

<div style="width: 50%;"> <hr style="width: 100%;"/> </div>

<small id="info1">
  <b>[1]</b> 环境配置位于 environments 目录下 dev 为本地测试环境使用的配置文件， prod 为线上环境使用的配置文件。 
</small>
<br />
<small id="info2">
  <b>[2]</b> 数据库结构版本化，可以阅读：《<a href="http://mp.weixin.qq.com/s?__biz=MjM5MDE0Mjc4MA==&mid=203586893&idx=1&sn=f560a00d3534b1ff77e0d5bc1a30450c&scene=1&key=8ea74966bf01cfb6f31796313044ea7aaef080b27fe0f7f9bcbc28332bca14b473212e9c2cd49cbf581de2528672f09f&ascene=0&uin=MjU0ODIzNzQyMQ%3D%3D&devicetype=iMac+MacBookAir6%2C2+OSX+OSX+10.10.2+build(14C1510)&version=11020012&pass_ticket=lomp%2BysXB6ciWAGA1qBJ7T1kdm7fnHUqeK1FMcRwNX%2BQdQs%2BM9me%2FNqSd1gAJ3kh">重量级发布再见！数据库版本控制完全指南</a>》，Yii2 通过 migrate 来实现，这个还在探索中。
</small>
<br />
<small id="info3">
  <b>[3]</b> 我们做项目，而不是做开源产品的话，需要把 composer.lock 文件也加入到版本库里面。它里面记录了每个安装的软件的版本，这样其它机器在部署时，就会安装相同版本的软件包，这样提高了产品的稳定性。</small>
