# Flutter 私有库管理

### 文件夹结构
|文件夹名|作用|
|--|--|
|flutter_pub_web|私服web端源码|
|pub_publisher|向私服发包源码|
|pub_server|私服后端源码|
|pub_server_go|私服后端源码,基于go实现,速度更快更稳定|
### 客户端使用

> 0. 在 pubspec.yaml 文件添加: publish_to: http://私服ip:port

> 1. windows用户下载[文件](https://github.com/jiang111/pub_server/raw/master/pub_publisher/bin/publite.exe),把publite添加到环境变量,在命令行执行这个文件,比如:

```
publite E:\coding\my_app
```


> 2. Mac/Linux 用户将这个链接的代码复制到项目中 https://github.com/jiang111/pub_server/blob/master/pub_publisher/lib/pub_publisher.dart 运行这个文件


> 3. 如何查看仓库是否发布成功, 查看部署的web地址,或者调用 http://ip:port/api/getAllPackages 如果能查询到你的仓库和对应的版本则代表发布成功

> 4. 上传成功之后如何依赖:

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

> 0. 注意点: 务必保证服务器编码为utf8 编译前最好对系统依赖库执行一下update

> 1. 下载最新版dart的sdk, 并配置环境变量, 保证在任意目录可以执行dart, 添加大陆地区的镜像源(自行google) 
```shell script
1. https://dart.dev/tools/sdk/archive 选择对应版本
2. wget https://storage.googleapis.com/dart-archive/channels/stable/release/2.13.1/sdk/dartsdk-linux-x64-release.zip
3. unzip dartsdk-linux-x64-release.zip
4. export PATH=$PATH:./dart-sdk/bin
5. export PUB_HOSTED_URL=https://pub.flutter-io.cn

```

> 2. clone 源码, cd 到源码根目录, 执行 pub get

> 3. 修改 ./example/example.dart 中的
```dart

host (修改为自己的私服地址)

webHookKey (企业微信推送需要配置,如果需要修改推送内容,请查看push.dart源码)


更多详细的配置,查看 argsParser() 方法

ArgParser argsParser() {
  var parser = ArgParser();

  //配置私有库存放路径
  parser.addOption('directory', abbr: 'd', defaultsTo: '/opt/flutter_repo');
  //配置host
  parser.addOption('host', abbr: 'h', defaultsTo: host);
  //配置端口
  parser.addOption('port', abbr: 'p', defaultsTo: '6453');
  parser.addFlag('standalone', abbr: 's', defaultsTo: false);
  return parser;
}


```

> 4. terimal执行 ./pub_server_run.sh 即可完成部署

> 5. 运行后日志会保存在当前目录下的log.log文件,可自行查看

### web端部署
查看 https://github.com/jiang111/pub_server/tree/master/flutter_pub_web 导出静态文件,然后部署在web服务器即可, 具体操作参考flutter web相关构建方法


[![Stargazers over time](https://starchart.cc/jiang111/pub_server.svg)](https://starchart.cc/jiang111/pub_server)

### 注意

>* 没有直接依赖的三方库,不要引用它的代码
>* 不要使用dependency_overrides
>* 文件名长度不能超过100个英文字符,字符长度从项目根目录算起





