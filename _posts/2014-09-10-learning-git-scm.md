---
title: Git分布式版本控制系统学习
tags: git 版本控制
layout: default
---
Git是一个分布式的版本控制系统，svn的操作日志等都是存储在服务端，用户如果要查看修改记录等，每次都是需要联网的，我们公司目前就是使用的svn，由于经常上github所以对git有所好感，它没有svn服务器这种单点故障，在对比差异和查看以前修改的版本时无需联网，对于这么牛的东西还是得好好学习一下。

## 第一章 起步
版本控制是很早以前就提出来了，最开始的时候是本地版本控制系统，最流行的叫 rcs，后来进化到集中化版本控制系统，再才过渡到分布式版本控制系统。

Git诞生于2005年，因为BitKeeper与Linux内核开源社区的合作终止。承受后Linus Tovalds不得不开发属于自己的版本控制系统，他们对本次系统的目标有：
* 速度
* 简单的设计
* 对非线性开发模式的强力支持（允许上千个并行开发的分支）
* 完全分布式
* 有能力高效管理类似 Linux 内核一样的超大规模项目（速度和数据量）

Git直接记录快照，而不是差异比较，svn会把每个文或几个文件在这个版本做了什么修改而记录下来，Git则不然，它在每一次提交都是整个项目的快照。Git中绝大多数都可以在本地完成，因为在本地磁盘上就保存了项目的历史版本信息。

#### 文件的三种状态
* 已提交 committed 表示文件已经被安全地保存在本地数据库中了
* 已修改 modified  表示修改了某个文件，但还没有提交保存
* 已暂存 staged    表示把已修改的文件放在下次提交时要保存的清单中。

#### 第一次运行Git的配置
使用Git之前需要配置下自己的 Git 工作环境。配置工作只需一次，以后升级时还会沿用现在的配置。

    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com
    $ git config --global core.editor vim
    $ git config --global merge.tool vimdiff
    $ git config --list
    user.name=Scott Chacon
    user.email=schacon@gmail.com
    color.status=auto
    ...
    $ git config user.name
    Scott Chacon
