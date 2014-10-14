---
title: 使用complete来扩展Bash shell自定义脚本的键补全
tags: shell, complete
layout: post
---
我们有许多的服务器需要管理，所以就会使用到一个软件dsh 来批量操作多台机器。默认是这样子的 # dsh 各种参数加选项（但其实我们用的参数和选项的值永远都是那几个，连位置都不变 ） 指定组名  "需要执行的命令"，由于组名是定义在 /etc/dsh/group 目录下面的，所以在默认的bash shell 里面，当我想让它自动补全组名的时候是不可以的。

### 目标
1. 使用DSH 这个命令来控制多台服务器
2. 在使用DSH的时候，组名如果能够自动补全就好了（因为我在/etc/dsh/group/ 下有 groupA groupB groupC）

### 实现思路
1. dsh 使用的远程shell 为 bash shell （其它的shell 没玩过）
2. 在连接机器的时候如果这台机器未在 .ssh/known_hosts里面，希望系统能够自动输入yes 不然太麻烦啦！
3. 通过 Bash shell 的 complete 来实现自定义tab键补全的功能

### 实现步骤
创建一个替代默认的dsh 的脚本，放到 /usr/local/bin/ 目录下

    # file: dsh.sh

    GROUP="$1"
    COMMAND="$2"
    dsh -o '-o StrictHostKeyChecking=no' -c  -M -g "$GROUP""$COMMAND"  # 这些参数我们使用的时候都是不变的

为这个脚本创建<tab>键补全的complete 程序
这个程序也放在 /usr/local/bin/ 目录下，这样方便以后的查看，或另一个人也能明白这个是干嘛的

    # file: dsh.sh-complete 
    # dsh.sh parameter-completion
    _UseDsh.sh ()   #  By convention, the function name
    {                 #+ starts with an underscore.
      local cur
      # Pointer to current completion word.
      # By convention, it's named "cur" but this isn't strictly necessary.
      COMPREPLY=()   # Array variable storing the possible completions.
      cur=${COMP_WORDS[COMP_CWORD]}
      case "$cur" in
        *)
          COMPREPLY=( $( compgen -W '`cd /etc/dsh/group ; ls $cur* 2&gt; /dev/null`' ) );;
      esac
      return 0
    }
    complete -F _UseDsh.sh dsh.sh

在用户登录到这台机器的时候自动source 这一个为dsh.sh 的complete的程序。

    # echo "source /usr/local/bin/dsh.sh-complete">>/etc/bash/bashrc

### 测试

    # dsh.sh<tab><tab> （就能自动补全以下的组）
    number26PhysicalServers number27PhysicalServers
    最终运行的命令为：
    查看这个组下面的机器的内核版本
    # dsh.sh number26PhysicalServers "uname -a"

### 说明
* number26PhysicalServers number27PhysicalServers 这两个组是我事先创建好的。
* 我这个说的是dsh 加上 bash shell complete的应用，如果对这两个不懂需要了解这相关的知识
* 关于bash shell complete的两个文章链接，写的非常简洁易懂，建议需要的话仔细阅读，将会受益匪浅：[《Appendix J. An Introduction to Programmable Completion》](http://tldp.org/LDP/abs/html/tabexpansion.html)、[《An introduction to bash completion》](http://www.debian-administration.org/article/316/An_introduction_to_bash_completion_part_1)
