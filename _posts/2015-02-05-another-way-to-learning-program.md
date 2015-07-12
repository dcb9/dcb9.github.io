---
layout: post
title: 学习 PHP 程序新东西的另一种方法
tags: php,phpunit,SplDoublyLinkedList
---
昨天在学习 `SplDoublyLinkedList` 的时候发现一个有趣的现象，比如

```
$obj = new SplDoublyLinkedList();
$obj->push('string');
```

这时候想判断 `$obj` 里面到底有没有值，或是不是一个，并且里面的值为 'string'，我们通常会:

```
print_r($obj);
```

然后通过肉眼去看打印出来的，确实与我们想的一致，那么我们就会认为是成功的。如果不一致就会认为是失败的。

仔细想想，这种与我们要做的测试程序不是一模一样嘛，只不过测试程序是用来检测我们的代码有没有问题，但现在由于代码是 PHP 官网这种权威组织写的，我们可以认为都是对的，现在要是写测试程序的话，就是另一层函义了，不是测试他们的代码是否有问题，而是代表我们对这个功能的认识。

经常我们会用 `print_r` 来打印，有时候自己会主观的认为是这样是那样，然后看的也不一定很仔细，然后就认为是对的，最后实际使用时发现不是的想的那样（我有亲身经历），写测试就是让程序来判断，我们的想法是不是有问题，哪里出错了，最主要它还可以把当时的思路保持下来，以后再继续回顾。

以下是我在学习 `SplDoublyLinkedList` 时写的一些测试，以后看到这个测试类，就知道了 `SplDoublyLinkedList` 该怎么用了。

<script src="https://gist.github.com/dcb9/06dcab3f3da1ac226f74.js"></script>
