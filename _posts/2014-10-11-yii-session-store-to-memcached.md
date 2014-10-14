---
layout: post
title: Yii在Web分布式下将Session存储到Memcached
tags: yii, memcached, session
---

 当网站的访问越来越大的时候一台机器无法支持迸发，或都是为了做到去单点，都需要在后端搭建一个集群来处理用户的请求，由于传统的PHP Session是文件级的存储，那么如果一个用户在第一次登录的时候这个Session文件存在 A 服务器上，而第二次的时候被分到了B 服务器上，则又认为他没有登录了（当然配置好负载均衡的是可以让同一个用户永远在同一台机器上的，这个的可以略过。。。），所以我们需要将它存在一个别的地方，我选的是Memcached，存在这里面，当然后期可能会选择Redis因为它在取值方面可以更精确，省内网带宽。

在Yii里面我想达到将Session信息存储到Memcached里面只需要稍做配置即可，我当前的Yii版本为yii-1.1.13.e9e4a0

### 修改componets配置文件
    'session' => array(
        'class' => 'CCacheHttpSession',
        'autoStart' => true,
        'cacheID' => 'sessionCache', // we only use the sessionCache to store the session
        'cookieMode' => 'only',
        'timeout' => 1400,
    ),
    'sessionCache' => array(
        'class' => 'system.caching.CMemCache',
        'servers' => array(
            array( 'host' => '192.168.10.193', 'port' => 11211, 'weight' => 6),
            array( 'host' => '192.168.10.226', 'port' => 11211, 'weight' => 3),
            array( 'host' => '192.168.10.228', 'port' => 11211, 'weight' => 2),
        ),
    ),

测试一下登录没有问题，然后非常好奇，它真的就存入到Memcached里面了吗？我们如何来验证一下呢？
为了省去新建一个Controller所以我就直接写一个action到SiteController里面去了。

    public function actionTestSessionWithMemcached(){
         
        /*
         * 得到sessionID号
         * 计算出来存在memcached的key值是多少.
         */
        $sessionId = Yii::app()->session->sessionID;
        echo "key:", $key = CCacheHttpSession::CACHE_KEY_PREFIX.$sessionId;
         
        /**
         * 这相当于是直接使用Memcached 连接，和session没有任何挂钩，
         * 我们来看一下session的数据是否真的就存在了memcached里边。
         * 通过计算出来的key直接用 get命令获取然后将数据打印出来就能看到值了。
         * 测试的时候先登录噢，别不登录就开始测试估计会获取不到值，以为有问题呢！
         */
        $mem =  Yii::app()->sessionCache;
        $data =$mem->get($key);
        var_dump($data);
    }
