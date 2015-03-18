---
layout: post
title: Docer 和虚拟机的一些对比 [翻译]
categories: 工作 docker
---

本文翻译自：《[Docker: Git for deployment -- Scout](http://blog.scoutapp.com/articles/2013/08/28/docker-git-for-deployment)》，个人感觉它的内容和标题不对，所以就没有直译过来，要是我理解错了请帮忙纠正。

我听说了 `Docker` 多么令人惊叹，但是它并没有征服我的心，直到我提出一个实际的问题：【如果 Scout 使用 Docker 来部署，它会让我们的部署变得更顺利吗？】

以下是三个案例：

### 高效地模拟线上环境

<img src="/images/mem_startup_1.png" />

我们线上有 16 台服务器，如果我尝试在本地使用 `VirtualBox` 配置每个实例 512 MB内存，那么它将占用我笔记本的两倍内存（说明他笔记本只有 4G 内存），`VirtualBox` 需要有许多多余的开支来管理每个子操作系统，`Docker` 在这方面是不一样的——容器共享同一个操作系统，更有可能是同样的二进制包文件和库文件，它可以运行在一台 `Docker` 主机上运行好几百个容器。

#### 老方法

我不能在本地完全地模拟线上环境，让我们来看一下通过 `Vagrant` 启动一台机器需要花多久：

```
$ time vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
[default] Importing base box 'squeeze64-ruby193'...
...
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
...

real  1m32.052s
```

启动一个镜像需要一分半钟，如果我需要修改一个配置文件并检测是否能够正常工作，那么需要重启镜像，那又是可怕的一分半钟。

如果你配置的有错，那将是一个残忍的惩罚。（每次修改就需要一分半钟才能看到结果）

使用 `Docker` 后

能想像 `Docker` 有多轻便吗？当你在 `Docker` 容器里面运行程序，你甚至可能不会注意到他们不是直接在主机上运行的，在下面的例子中，我从标记的 "rails" 镜像中启动一个 `Docker` 容器来运行 Rails 应用（Dockerfile）：

```
root@precise64:~# docker run rails
2013-08-26 20:21:14,600 CRIT Supervisor running as root (no user in config file)
2013-08-26 20:21:14,603 WARN Included extra file "/srv/docker-rails/Supervisorfile" during parsing
2013-08-26 20:21:14,736 INFO RPC interface 'supervisor' initialized
2013-08-26 20:21:14,740 CRIT Server 'unix_http_server' running without any HTTP authentication checking
2013-08-26 20:21:14,754 INFO supervisord started with pid 1
2013-08-26 20:21:15,783 INFO spawned: 'rails' with pid 10
2013-08-26 20:21:16,841 INFO success: rails entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

只需要两秒钟就完成了容器的启动和 supervisor 的启动（用来启动 Rails 应用的管理程序）

总之，`Docker` 能够让你在测试机上完全地模拟线上环境，它是如此的简单，让我可以真正地进行全站测试了。

### 更简单快速地创建镜像

<img src="/images/ruby_install_2.png" />

#### 老方法

If you are scripting the process to build a virtual machine image from a base image (example: building the Rails stack on Ubuntu), getting all of the pieces to flow correctly can be a pain if you don't do it frequently. Lets say you install the dependencies for Ruby:

```
$ time apt-get install -y -q ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev
Reading package lists...
Building dependency tree...
The following extra packages will be installed:
....
Setting up libalgorithm-merge-perl (0.08-2) ...
Processing triggers for libc-bin ...
ldconfig deferred processing now taking place

real 1m22.470s
```

Then, you try to install the dependencies for NodeJS, but you forget to add the node apt repository:

```
$apt-get install -y nodejs
...
E: Unable to locate package nodejs
```

After you fix the NodeJS issue, you still want to be confident your script works on a fresh base image. You'd need to re-run the Ruby install, waiting 82 seconds before the Node install even starts. Painful.

The Docker Way
Put the steps to build an image in a Dockerfile. Dockerfiles are easy to read because you don't need to learn a separate DSL - it's basically just running commands as you enter them. Installing Ruby the first time won't be any faster, but lets take a look what happens when we build the image again from the Dockerfile:

```
FROM ubuntu:12.04
RUN apt-get update

## MYSQL
RUN apt-get install -y -q mysql-client libmysqlclient-dev

## RUBY
RUN apt-get install -y -q ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev
```

```
root@precise64:/# time docker build -t="dlite/appserver" .
Uploading context 92160 bytes
Step 1 : FROM ubuntu:12.04
 ---> 8dbd9e392a96
Step 2 : RUN apt-get update
 ---> Using cache
 ---> b55e9ee7b959
Step 3 : RUN apt-get install -y -q mysql-client libmysqlclient-dev
 ---> Using cache
 ---> dc92be6158b0
Step 4 : RUN apt-get install -y -q ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev
 ---> Using cache
 ---> 7038022227c0
Successfully built 7038022227c0

real    0m0.848s
```
Wow - how did installing Ruby take under one second this time around? See those cache keys (ex: dc92be6158b0)? Rather than re-running the line from the Dockerfile, Docker sees that it has already run that command and just retrieves the file system changes from its cache. It can do this magic because Docker uses the AuFS file system, which is a union file system (kind of like applying diffs).

In short, Docker makes it painless to iteratively build an image as you don't need to wait for previously successful steps to complete again. I'm not perfect and Docker doesn't punish me when I make mistakes.



### 部署镜像，不更新基础设施

<img src="/images/deployment_3.png" />

The Old Way
Like many other deployments today, Scout uses long-running virtual machines. We handle infrastructure updates via Puppet, but this is frequently more painful than we'd like:

If we're deploying an update to our stack, Puppet will run and update each of our virtual machines. This takes a long time - even though only a small portion of stack may change, Puppet checks everything.
Problems can happen during a deploy. If we're installing Memcached and there is a network hiccup, apt-get install memcached could fail on some of our servers.
Rolling back major changes often doesn't go as smoothly as we'd like (like updating Ruby versions).
None of these issues are Puppet's fault - a tool like Puppet or Chef is needed when you have long-running VMs that could become inconsistent over time.

The Docker Way
Deploy images - don't modify existing VMs. You'll be 100% sure what runs locally will run on production.

But images are large, right? Not with Docker - remember containers don't run their own guest OS and we're using a union file system. When we make changes to an image, we just need the new layers.

For example, lets say we're installing Memcached onto our app servers. We'll build a new image. I'll tag it as dlite/appserver-memcached, where dlite is my index.docker.io user name. It's based off the dite/appserver image.

```
root@precise64:/# time docker build -t="dlite/appserver-memcached" .
Uploading context 92160 bytes
Step 1 : FROM appserver
 ---> 8dbd9e392a96
Step 2 : RUN apt-get update
 ---> Using cache
 ---> b55e9ee7b959
Step 3 : RUN apt-get install -y -q memcached
 ---> Running in 2a2a689daee3
Reading package lists...
Building dependency tree...
...
Starting memcached: memcached.
Processing triggers for libc-bin ...
ldconfig deferred processing now taking place
 ---> 2a2a689daee3
Successfully built 2a2a689daee3

real    0m13.289s
user    0m0.132s
sys 0m0.376s
```

It took just 13 seconds to install Memcached because prior Dockerfile lines were cached. I love speed.

I'll commit and push this:

```
root@precise64:/# time docker push dlite/appserver-memcached
The push refers to a repository [dlite/appserver-memcached] (len: 1)
Processing checksums
Sending image list
Pushing repository dlite/appserver-memcached (1 tags)
Pushing 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c
Image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c already pushed, skipping
...
Pushing tags for rev [ad8f8a3809afcf0e2cff1af93a8c29275a847609b05b20f7b6d2a5cbd32ff0d8] on {https://registry-1.docker.io/v1/repositories/dlite/appserver-memcached/tags/latest}

real    0m28.710s
```
On the production server, I'll pull this image down:

```
root@prod:/# time docker pull dlite/appserver-memcached
Pulling repository dlite/appserver-memcached
Pulling image ad8f8a3809afcf0e2cff1af93a8c29275a847609b05b20f7b6d2a5cbd32ff0d8 (latest) from dlite/appserver-memcached

real    0m15.749s
```

It took just 15 seconds to grab the dlite/appserver-memached image. Note the image size is just 10 MB as it uses the appserver image as the base:

```
root@precise64:~# docker images
REPOSITORY            TAG                 ID                  CREATED             SIZE
appserver             latest              7038022227c0        3 days ago          78.66 MB (virtual 427.9 MB)
appserver-memcached   latest              77dc850dcccc        16 minutes ago      10.19 MB (virtual 438.1 MB)
```

We didn't need to pull down the entire image with Memcached, just the changes to add Memcached to the dlite/appserver image.

Most of the time, the changes we make are much smaller, so pulling down new images will be even faster.

This has big implications:

It's fast to start new Docker containers
Pushing+pulling new Docker images is lightweight

Rather than messing with existing running virtual machines, we'll just fire up new containers and stop the old containers.

Mind blown! It means we don't need to worry about consistency - we aren't modifying existing VMs, just launching new containers. It means rollbacks are a breeze! Memcached falling down? Stop the containers running dlite/appserver-memcached and start containers with the dlite/appserver image again.

### 不足

Working with short-lived containers introduces a new set of problems - distributed configuration / coordination and service discovery:

How do we update the HAProxy config when new app server containers are started?
How do app servers communicate with the database container when a new database container is started?
How about communicating across Docker hosts?
The upcoming release of Flynn.io, which will use etcd for this, will help. However, these are problems smaller scale deployments didn't have to worry about before.

### Docker 可以使用 Git 去部署

Developers are able to leverage Git's performance and flexibility when building applications. Git encourages experiments and doesn't punish you when things go wrong: start your experiments in a branch, if things fall down, just git rebase or git reset. It's easy to start a branch and fast to push it.

Docker encourages experimentation for operations. Containers start quickly. Building images is a snap. Using another images as a base image is easy. Deploying whole images is fast, and last but not least, it's not painful to rollback.

Fast + flexible = deployments are about to become a lot more enjoyable.
