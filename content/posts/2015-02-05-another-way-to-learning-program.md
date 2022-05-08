---
title: "学习 PHP 程序新东西的另一种方法"
date: 2015-02-05T00:00:00+08:00
draft: false
aliases: [/posts/学习-PHP-程序新东西的另一种方法.html]
description: 昨天在学习 `SplDoublyLinkedList` 的时候发现一个有趣的现象，比如
tags: ["PHP"]
---

昨天在学习 `SplDoublyLinkedList` 的时候发现一个有趣的现象，比如

~~~
$obj = new SplDoublyLinkedList();
$obj->push('string');
~~~

这时候想判断 `$obj` 里面到底有没有值，或是不是一个，并且里面的值为 'string'，我们通常会:

~~~
print_r($obj);
~~~

然后通过肉眼去看打印出来的，确实与我们想的一致，那么我们就会认为是成功的。如果不一致就会认为是失败的。

仔细想想，这种与我们要做的测试程序不是一模一样嘛，只不过测试程序是用来检测我们的代码有没有问题，但现在由于代码是 PHP 官网这种权威组织写的，我们可以认为都是对的，现在要是写测试程序的话，就是另一层函义了，不是测试他们的代码是否有问题，而是代表我们对这个功能的认识。

经常我们会用 `print_r` 来打印，有时候自己会主观的认为是这样是那样，然后看的也不一定很仔细，然后就认为是对的，最后实际使用时发现不是的想的那样（我有亲身经历），写测试就是让程序来判断，我们的想法是不是有问题，哪里出错了，最主要它还可以把当时的思路保持下来，以后再继续回顾。

以下是我在学习 `SplDoublyLinkedList` 时写的一些测试，以后看到这个测试类，就知道了 `SplDoublyLinkedList` 该怎么用了。

~~~php
<?php

class SplDoublyLinkedListTest extends PHPUnit_Framework_TestCase
{
    public function testSplDoublyLinkedListPart1()
    {
        $obj = new SplDoublyLinkedList();
        // Pushes value at the end of the doubly linked list.
        $obj->push(0);
        $obj->push(1);
        $obj->push(2);

        // Prepends value at the beginning of the doubly linked list.
        $obj->unshift(10);
        $obj->unshift(11);

        /*
         * 因为指针还未初始化
         * 所以
         * 1. 当前指针是否有效为 FALSE
         * 2. 直接获取当前指针的值会是 NULL
         */
        $this->assertEquals(FALSE, $obj->valid());
        $this->assertEquals(NULL, $obj->current());

        $obj->rewind();
        // 将指针重置之后，第一个肯定是 11 ，因为它是在最后执行了一个
        // 将 11 插入到链表最前面的一个函数 unshift
        $this->assertEquals(11, $obj->current());

        $obj->next();
        // 11 下面应该是 10
        $this->assertEquals(10, $obj->current());

        // (下一个 下一个 上一个) === (下一个)
        $obj->next(); // 0
        $obj->next(); // 1
        $obj->prev(); // 0
        $this->assertEquals(0, $obj->current());

        $obj->next(); // 1
        $obj->next(); // 2
        $obj->next(); // 已经超过最大的了，使用 valid 判断应该是 false
        $this->assertEquals(false, $obj->valid());
    }

    public function testSplDoublyLinkedListPart2()
    {
        $obj = new SplDoublyLinkedList();
        // Pushes value at the end of the doubly linked list.
        $obj->push(0);
        $obj->push(1);
        $obj->push(2);

        // Prepends value at the beginning of the doubly linked list.
        $obj->unshift(10);
        $obj->unshift(11);

        //  Peeks at the node from the end of the doubly linked list
        //  Return: The value of the last node.
        //  获取最后一个节点的值
        $this->assertEquals(2, $obj->top());

        // Peeks at the node from the beginning of the doubly linked list
        // Return: The value of the first node.
        // 获取第一个节点的值
        $this->assertEquals(11, $obj->bottom());
    }

    public function testIsEmpty(){
        $obj = new SplDoublyLinkedList();

        $this->assertEquals(true, $obj->isEmpty());

        $obj->unshift('string');
        // 这里已经有值了就应该是 false
        $this->assertEquals(false, $obj->isEmpty());

        // 这时再使用 pop 弹出最后一个就应该是 'string'
        $this->assertEquals('string', $obj->pop());

    }

    /**
     * 如果是空的时候试图 pop 弹出最后一个节点的值则会 抛出一个 RuntimeException
     *
     * @expectedException RuntimeException
     */
    public function testRuntimeException(){
        $obj = new SplDoublyLinkedList();
        $obj->pop();
    }

    public function testOffset(){
        $obj = new SplDoublyLinkedList();
        $obj->push('one');
        $obj->push('two');
        $obj->unshift('three');

        // 下标是从0 开始的 所以现在3 应该是不存在的
        $this->assertEquals(false, $obj->offsetExists(3));

        // 下标为2 的应该是存在的
        $this->assertEquals(true, $obj->offsetExists(2));

        $this->assertEquals('two', $obj->offsetGet(2));

        // 删除下标为0 的值
        $obj->offsetUnset(0);
        // 删除为 0 的值之后，后面的都会向前移一位
        // 所以现在的顺序为： one two
        $obj->rewind();
        $this->assertEquals('one', $obj->current());
        $this->assertEquals(0, $obj->key());

        $obj->next();
        $this->assertEquals('two', $obj->current());
        $this->assertEquals(1, $obj->key());
        // 并且总个数为 2
        $this->assertEquals(2, $obj->count());
    }

    public function testAdd(){
        $obj = new SplDoublyLinkedList();
        $obj->push('one');
        $obj->push('two');
        $obj->push('three');
        $obj->unshift('four');
        $obj->add(1, 'five');

        // 这时候的顺序应该是：
        // four five one two three

        $obj->rewind();
        $this->assertEquals('four', $obj->current());
        $obj->next();
        $this->assertEquals('five', $obj->current());
        $obj->next();
        $this->assertEquals('one', $obj->current());
        $obj->next();
        $this->assertEquals('two', $obj->current());
        $obj->next();
        $this->assertEquals('three', $obj->current());
    }
}
~~~
