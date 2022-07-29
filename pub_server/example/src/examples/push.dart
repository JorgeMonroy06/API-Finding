import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../example.dart';

/// @author NewTab

class Push {
  //企业微信推送

  void _push(String content) async {
    var url = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=$webHookKey';

    var data = {
      'msgtype': 'text',
      'text': {'content': content}
    };
    var body = json.encode(data);

    await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
  }

  void push(
    String packageName,
    String version,
    String author,
    String updateContent,
  ) async {
    var content = 'Flutter私有库上新\n\n';

    content += ' 名称: $packageName\n';
    content += ' 版本: $version\n';
    content += ' 更新内容: $updateContent\n';
    if (author != null && author.isNotEmpty && author != 'null') {
      content += ' 作者: $author\n';
    }
    content += ' 地址: http://$host:6454/#/package/$packageName';

    _push(content);
  }

  void error(String packageName, String errorInfo) {
    _push(
      'Flutter私有库提醒: \n\n  该库 $packageName $errorInfo',
    );
  }
}
