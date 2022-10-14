# Flutter私有库管理

使用gin框架,基于go语言编写



1.下载 [pub_server_go](https://github.com/jiang111/pub_server/raw/master/pub_server_go/pub_server_go)文件,上传到linux服务器


2.新增 config.json 文件到 pub_server_go 同级目录,配置如下

```
{
    "port":"8008", //端口号
    "webPort":"80", //web端口,没有web端可以不填
    "path": "E:\\flutter_repo",  //私有库存储路径
    "weWorkKey": "", //企业微信机器人推送的key
    "canUpload": true //是否可以上传包
}
```

3. 修改pub_server_go权限

```
chmod 774 pub_server_go
```


4.运行

```
nohup ./pub_server_go > log.log 2>&1 &
```
