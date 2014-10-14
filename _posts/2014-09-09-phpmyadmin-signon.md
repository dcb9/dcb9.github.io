---
title: PHPMyAdmin改造实现单点登录
tags: phpmyadmin php signon
layout: post
---
PHPMyAdmin单点登录的实质就是不要phpmyadmin默认的登录认证方式，而使用自己网站程序的认证系统，这样就实现了单点登录。phpmyadmin里面提供了一种signon的模式来做这件事。

### 修改配置文件

    # file: config.inc.php

    $cfg['Servers'][$i]['auth_type'] = 'signon';  
    $cfg['Servers'][$i]['SignonSession'] = 'SignonSession'; // 为了防止多个session的键的冲突，所以单独设置 个session名称
    $cfg['Servers'][$i]['SignonURL'] = '/signon.php'; // 自定义登录页面
    $cfg['Servers'][$i]['LogoutURL'] = '/signon.php?logout=1'; // 自定义登录页面的退出页面

### 配置登录程序

    # file: /signon.php

    if (isset($_GET['logout'])) {
        session_destroy();
        header('Location: 网站原来的退出url');
        exit;
    }
      
    $userDb = array(
        '单点登录后的用户名或id号' => '给这个人分配的数据库的用户名',
    );
      
    // mysql中添加用户的时候密码为空就行。然后主要就是对于现在系统的用户名和数据库的用户名的一个映射，
    // 也可以就用现在的用户名作为数据库的用户名，不过得保证字符长度不得大于16，
    // 中文的用户名我也没弄过，如果弄中文的可能也会出问题。
      
    $_SESSION['PMA_single_signon_user'] = $userDb[$cookieofmanagername]; // 这个用户名一定要数据库存在并有相应的权限的。
    $_SESSION['PMA_single_signon_password'] = '';
      
    echo "<script>top.location.href='/phpmyadmin/index.php';</script>";
