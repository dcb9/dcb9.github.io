---
title: "Plasma MVP 为什么需要发送交易后再生成 confirmation signature？"
date: 2018-09-06T00:00:00+08:00
draft: false
aliases: [/posts/Plasma-MVP-为什么需要发送交易后再生成-confirmation-signature.html]
description: 以下内容翻译自 Ethereum Research ”[Why do/don’t we need two phase sends plus confirmation](https://ethresear.ch/t/why-do-dont-we-need-two-phase-sends-plus-confirmation/1866/14)” 的回复。 Generally, there are two major reasons why it’s necessary to have the two-phase send + conf in Plasma.  Plasma MVP 为什么有必要使用 send + confirm，主要有两个原因
tags: ["翻译", "Ethereum"]
---

以下内容翻译自 Ethereum Research ”[Why do/don’t we need two phase sends plus confirmation](https://ethresear.ch/t/why-do-dont-we-need-two-phase-sends-plus-confirmation/1866/14)” 的回复。

Generally, there are two major reasons why it’s necessary to have the two-phase send + conf in Plasma.

Plasma MVP 为什么有必要使用 send + confirm，主要有两个原因：



The first reason is specific to Plasma MVP and arises because Plasma MVP allows for fungible coins/tokens. Basically, if we don’t have confirmations, then an operator can place a user’s valid transactions after the operator’s invalid transactions in a block. This is a problem because exits in Plasma MVP are processed in time order. I published a brief write-up on why this time-order processing is necessary [here 8](https://github.com/omisego/research/blob/master/plasma/plasma-mvp/explore/priority.md).

原因一、 因为 Plasma MVP 规范允许 fungible（同质）coins/tokens。从根本上讲，如果没有 confirmations, 那侧链管理员就可以在打包块的时，将用户有效的交易放到管理员的交易的后面。这样就会有问题了，因为 Plasma MVP 退出是按时间顺序来处理的，作者发了一篇短文章来说明为什么按时间顺序的处理是必须的。[exit priority](https://github.com/omisego/research/blob/master/plasma/plasma-mvp/explore/priority.md)


Let’s illustrate this first problem with a scenario where the operator steals funds. Assume the contract only holds 10 ETH in total.

让我们来举例说明这个问题，假设合约里面现在有 10 ETH，管理员想把这笔钱偷走。

1. Alice broadcasts a transaction spending 10 ETH to Bob.
2. The operator creates an invalid transaction creating 10 ETH for themselves “out of nowhere” and places it at the first index in a block (“transaction #0”).
3. The operator places Alice’s transaction at the second index in the block (“transaction #1”).
4. The operator publishes this block.
5. Bob sees the invalid transaction and submits his exit.
6. The operator submits an exit for the invalid transaction.
7. The operator’s exit processes before Bob’s exit, so the contract is now empty.
8. Bob’s exit cannot be processed because the contract has no funds remaining.

--

1. A 广播了个交易，A 转给 B 10 个 ETH
2. 管理员创建一个无效的交易将 10 个 ETH转给他自己，并把这笔交易放到块的第一个 (“transaction #0”)
3. 管理员将 A 的交易放到块的第二个 (“transaction #1)
4. 管理员将块递交到主链
5. B 看了无效的交易并申请退出
6. 此时管理员也申请退出他刚才的无效交易
7. 管理员的退出程序会在 B 退出之前完成，所以合约里面就没有钱了
8. B 的退出将能处理，因为合约里面已经没有钱了


Now, let’s see what happens when we require confirmations:

让我们来看看如果我们加上 confirmations 之后会发生什么：


1. Alice broadcasts a transaction spending 10 ETH to Bob.
2. The operator creates an invalid transaction creating 10 ETH for themselves “out of nowhere” and places it at the first index in a block (“transaction #0”).
3. The operator places Alice’s transaction at the second index in the block (“transaction #1”).
4. The operator publishes this block.
5. Alice sees the invalid transaction and refuses to sign a confirmation on her transaction to Bob.
6. The operator submits an exit for the invalid transaction.
7. Alice exits from her (still technically unspent) 10 ETH UTXO which existed before the operator’s invalid UTXO.
8. The operator’s exit cannot be processed because the contract has no funds remaining.

--

1. A 广播了个交易，A 转给 B 10 个 ETH
2. 管理员创建一个无效的交易将 10 个 ETH转给他自己，并把这笔交易放到块的第一个 (“transaction #0”)
3. 管理员将 A 的交易放到块的第二个 (“transaction #1)
4. 管理员将块递交到主链
5. A 看到了这个无效的交易，并且拒绝给他的交易生成 confirmation
6. 管理员申请退出他刚才生成的无效交易
7. A 申请退出他之前的 10 个未花费的 UTXO（也就是转给 B 之前的 10 个 ETH，这笔交易从技术的角度上讲还没完成，因为他并没有为刚才的交易生成 confirmation ），这个将会在管理员的无效 UTXO 之前处理
8. 管理员的退出不能被处理因为合约里面已经没有余额了


Note that this situation is not a problem in Plasma Cash because coins are unique and non-fungible - the operator can’t just create valid UTXOs “out of nowhere” like they can in Plasma MVP. The operator could create a transaction that appears to give them ownership of a specific coin, but that doesn’t impact the ability for the owners of any other coin to exit.

提示该情况不会成为 Plasma Cash 的一个问题，因为币是独一无二和非同质的，管理员无法像在 Plasma MVP 一样创建无效的 UTXO。管理员可以创建一笔交易，好像是给他们某个币的所有权，但是那不能影响，币的所有权人退出的能力。

Now let’s talk about the other potential scenario. This is basically what I mentioned in my reply to Dan above, and it’s less of an attack vector than an annoyance:

现在让我们来谈谈另一个潜在的情景，基本就是我在上面回复 Dan 提到的。它的攻击性比麻烦要少（我感觉主要是因为，没有哪个侧链的管理员为了获得一点挑战的资金，而冒不诚信的风险）。


1. Alice broadcasts a transaction spending 10 ETH to Bob.
2. The operator places Alice’s transaction somewhere in the block.
3. The operator publishes the root of this block to the root chain but withholds the actual block information.
4. Alice doesn’t know if her transaction to Bob was actually included in the block or not. Bob doesn’t have enough information to exit because he doesn’t know the index of the transaction in the block.
5. Alice must attempt to exit from her old UTXO.
6. The operator knows that Alice’s old UTXO is spent, so they challenge Alice’s exit with her transaction to Bob (revealing the index).
7. Bob now knows the transaction index, so Bob can exit.

--

1. A 广播了个交易，A 转给 B 10 个 ETH
2. 管理员将 A 的交易放到块中
3. 管理员递交该块到主链，但是隐瞒了块的真实信息
4. A 不知道她的转给 B 的这笔交易有没有被打包到块里面，B 也没有足够的信息申请退出，因为他不知道该笔交易的在块中的位置
5. A 尝试退出她旧的 UTXO
6. 管理员知道 A 的这个旧 UTXO 已经花出去了，他使用 A 向 B 转帐的这笔交易向 A 的退出发起挑战
7. B 知道这个交易的位置，他可以申请退出了


This doesn’t change anything security-wise, but it’s not particularly convenient to have this exit-challenge-exit process. Additionally, Alice will always lose her bond for her original exit. Here’s how it plays out with confirmations:

这不会改变安全性，但是这个 退出( A 的退出) - 挑战(管理员的挑战）- 退出（B 的退出） 流程并不是特别方便。 此外，A 永远会失去他的退出奖金。 以下是使用 confirmations 的方式：

1. Alice broadcasts a transaction spending 10 ETH to Bob.
2. The operator places Alice’s transaction somewhere in the block.
3. The operator publishes the root of this block to the root chain but withholds the actual block information.
4. Alice doesn’t know if her transaction to Bob was actually included in the block or not. Alice doesn’t broadcast a confirmation signature.
5. Alice exits from her old UTXO.
6. The operator cannot challenge with Alice’s spend to Bob because the operator doesn’t have the required confirmation signature.



1. A 广播了个交易，A 转给 B 10 个 ETH
2. 管理员将 A 的交易放到块中
3. 管理员递交该块到主链，但是隐瞒了块的真实信息
4. A 不知道她的转给 B 的这笔交易有没有被打包到块里面，A 不广播确认的签名
5. A 退出之前的旧 UTXO
6. 管理员不能使用 A 转给 B 的这笔交易来挑战 A，因为管理员没有 confirmation signature
