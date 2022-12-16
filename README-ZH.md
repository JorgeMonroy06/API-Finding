# Flutter 私有库管理

### 文件夹结构
|文件夹名|作用|
|--|--|
|flutter_pub_web|私服web端源码|
|pub_publisher|向私服发包源码|
|pub_server_go|私服后端源码,基于go实现,速度更快更稳定|


### 客户端使用

> 0. 在 pubspec.yaml 文件添加: publish_to: http://私服ip:port

> 1. windows用户下载[文件](https://github.com/jiang111/pub_server/raw/master/pub_publisher/bin/publite.exe), Mac 用户下载[文件](https://github.com/jiang111/pub_server/raw/master/pub_publisher/bin/publite), 把 publite 添加到环境变量,在命令行执行这个文件,比如:
 
```
publite E:\coding\my_app //后面是你项目的全路径
```


> 2. 如何查看仓库是否发布成功, 查看部署的web地址,或者调用 http://ip:port/api/getAllPackages 如果能查询到你的仓库和对应的版本则代表发布成功

> 3. 上传成功之后如何依赖:

```
  package_name:
    hosted:
      name: plugin_name
      url: http://ip:port
    version: ^lastedVersion
```
> 5. 常用API:

```
http://ip:port/api/getAllPackages  //获取所有可用库的名称, 以及最新版本

http://ip:port/api/packages/<package-name> //获取 package_name 库所有历史版本, 以及相关信息

http://ip:port/api/packages/<package-name>/versions/<version-name> //获取 package_name 库 version-name 版本的下载地址, 以及相关信息

http://ip:port/packages/<package-name>/versions/<version-name>.tar.gz //下载指定库的指定版本
```

> 6. GUI页面部署参考https://github.com/jiang111/pub_server/tree/master/flutter_pub_web

### 服务端部署

[点我查看](https://github.com/jiang111/pub_server/blob/master/pub_server_go/README.md)

### web端部署

[点我查看]([https://github.com/jiang111/pub_server/blob/master/pub_server_go/README.md](https://github.com/jiang111/pub_server/tree/master/flutter_pub_web)



[![Stargazers over time](https://starchart.cc/jiang111/pub_server.svg)](https://starchart.cc/jiang111/pub_server)

### 注意

>* 没有直接依赖的三方库,不要引用它的代码
>* 不要使用dependency_overrides
>* 文件名长度不能超过100个英文字符,字符长度从项目根目录算起





