# Flutter私有库管理

使用gin框架,基于go语言编写

```
{
    "port":"8008", //端口号
    "webPort":"80", //web端口,没有web端可以不填
    "path": "E:\\flutter_repo",  //私有库存储路径
    "weWorkKey": "", //企业微信机器人推送的key
    "canUpload": true //是否可以上传包
}
```

## 运行

```shell
chmod 774 pub_server_go
bash run.sh
```
