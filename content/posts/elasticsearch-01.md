---
title: "Elasticsearch 01: 研究学习环境搭建"
date: 2023-02-17T01:01:49+08:00
draft: true
---

使用单机机多个项目启动多个单节点的方式，这也是 StackOverflow 及马士兵教育推荐的方式。

Elasticsearch 版本为 7.10.0

1. 从官网下载安装包，安装包内包含以下目录及文件

https://www.elastic.co/guide/en/elastic-stack/index.html

~~~
2023/02/13  09:41    <DIR>          bin
2023/02/16  23:57    <DIR>          config
2023/02/17  00:43    <DIR>          data
2023/02/13  09:41    <DIR>          jdk
2023/02/13  09:41    <DIR>          lib
2023/02/13  09:34             3,860 LICENSE.txt
2023/02/17  00:02    <DIR>          logs
2023/02/13  09:41    <DIR>          modules
2023/02/13  09:36         2,237,168 NOTICE.txt
2023/02/13  09:36    <DIR>          plugins
2023/02/13  09:34             8,106 README.asciidoc
~~~

2. 将整个包复制多份，形成如下目录结构

~~~
es_cluster/node1
es_cluster/node2
...
~~~

3. 修改 node1, node2 配置文件 elasticsearch.yml

~~~
node.name: node-N
http.port: 920N
~~~

3. 创建启动文件 es_cluster/start.bat

~~~bat
# 使用 ES 提供的 Java 版本，忽略系统的 Java 开发环境，防止兼容性问题。
set JAVA_HOME=

start es_cluster\node1\bin\elasticsearch.bat
start es_cluster\node2\bin\elasticsearch.bat
~~~

4. 测试

访问机器的 localhost:920N，如果能得到数据，或在 terminal 能看到相应的网络请求，则证明搭建正确。

~~~json
{
  "name" : "node-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "LxeEFIddRN6WcTdae9UJCQ",
  "version" : {
    "number" : "7.10.0",
    "build_flavor" : "default",
    "build_type" : "zip",
    "build_hash" : "51e9d6f22758d0374a0f3f5c6e8f3a7997850f96",
    "build_date" : "2020-11-09T21:30:33.964949Z",
    "build_snapshot" : false,
    "lucene_version" : "8.7.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
~~~
