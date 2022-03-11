import 'dart:convert';

import 'package:clay_containers/clay_containers.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pub_web/home_page.dart';
import 'package:flutter_pub_web/loading_dialog.dart';
import 'package:flutter_pub_web/main.dart';
import 'package:flutter_pub_web/web_support.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// @author newtab on 2021/5/7

class DetailPage extends StatefulWidget {
  final String packageName;
  final Color color;

  const DetailPage({
    Key? key,
    this.packageName = "",
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? detailBean;
  Map<String, dynamic>? lastedVersion;
  List<Map<String, dynamic>?> history = [];
  TabController? controller;

  @override
  void initState() {
    controller = TabController(length: 6, vsync: this);
    super.initState();
    getPackageDetail(context, false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.packageName.isEmpty)
      return Container(
        child: Center(
          child: Text("PackageName is null"),
        ),
      );
    return Scaffold(
      backgroundColor: baseColor,
      appBar: AppBar(
        backgroundColor: Color(0xff1c2834),
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          widget.packageName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        actions: [
          InkWell(
            child: Center(
              child: Text(
                "Help",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () async {
              await launch("https://github.com/jiang111/pub_server/blob/master/README.md");
            },
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: getMaxWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Text(
                    "${widget.packageName} ${lastedVersion?["version"] ?? ""}",
                    style: TextStyle(
                      color: Color(0xff4a4a4a),
                      fontSize: 36,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        var deply = """
${widget.packageName}:
    hosted:
      name: ${widget.packageName}
      url: $HOST_API
    version: ^${lastedVersion?["version"]}
""";
                        FlutterClipboard.copy(deply);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("依赖复制成功")));
                      },
                      child: ClayContainer(
                        borderRadius: 20,
                        color: baseColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            CupertinoIcons.doc_on_clipboard,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: SelectableText(
                  lastedVersion?["pubspec"]?["description"] ?? "",
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "最新版本: ",
                    style: TextStyle(
                      color: Color(0xff4a4a4a),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    lastedVersion?["version"] ?? "",
                    style: TextStyle(
                      color: Color(0xff0175c2),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "•",
                    style: TextStyle(
                      color: Color(0xff4a4a4a),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "作者:",
                    style: TextStyle(
                      color: Color(0xff4a4a4a),
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lastedVersion?["pubspec"]?["author"] ?? "",
                      style: TextStyle(
                        color: Color(0xff0175c2),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                color: Color(0xffF5F5F7),
                width: double.infinity,
                margin: EdgeInsets.only(
                  top: 30,
                ),
                padding: EdgeInsets.only(
                  top: 5,
                  left: 10,
                  right: 10,
                ),
                child: TabBar(
                  isScrollable: true,
                  controller: controller,
                  labelColor: Color(0xff0175c2),
                  unselectedLabelColor: Color(0xff4a4a4a),
                  tabs: [
                    Tab(
                      text: "README",
                    ),
                    Tab(
                      text: "更新记录",
                    ),
                    Tab(
                      text: "下载安装",
                    ),
                    Tab(
                      text: "依赖内容",
                    ),
                    Tab(
                      text: "所需环境",
                    ),
                    Tab(
                      text: "源码下载",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Colors.white,
                  child: TabBarView(controller: controller, children: [
                    _buildReadMe(lastedVersion?["readme"] ?? ""),
                    _buildUpdateHistory(),
                    _buildInstall(),
                    _buildDeploy(),
                    _buildEnv(),
                    _buildSource(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getPackageDetail(BuildContext context, bool show) async {
    HideCallback? result;
    if (show) {
      result = showLoading(context);
    }

    var url = Uri.parse(HOST_API + "/api/packages/${widget.packageName}");
    var response = await http.get(url);
    if (result != null) {
      result();
    }

    if (response.statusCode == 200) {
      detailBean = await jsonDecode(utf8.decode(response.bodyBytes));
      lastedVersion = detailBean?["latest"];
      history.clear();
      (detailBean?["versions"] as List).forEach((element) {
        history.add(element);
      });
      history = history.reversed.toList();

      setState(() {});
    }
  }

  Widget _buildUpdateHistory() {
    return ListView.separated(
      separatorBuilder: (context, _) {
        return Divider(
          indent: 15,
          endIndent: 15,
          thickness: 0.5,
          color: Color(0xff4a4a4a),
        );
      },
      itemBuilder: (context, index) {
        int time = history[index]?["time"];
        var format = new DateFormat("yyyy-MM-dd HH:mm");
        var dateString = format.format(DateTime.fromMillisecondsSinceEpoch(time));

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Text(
                dateString,
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 24,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Text(
                history[index]?["pubspec"]?["version"] ?? "",
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 24,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: SelectableText(
                  history[index]?["pubspec"]?["update_note"] ?? "未找到更新日志,在yaml文件中添加update_note字段作为更新日志会被识别",
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: history.length,
    );
  }

  Widget _buildDeploy() {
    return ListView.separated(
      separatorBuilder: (context, _) {
        return Divider(
          indent: 15,
          endIndent: 15,
          thickness: 0.5,
          color: Color(0xff4a4a4a),
        );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Text(
                history[index]?["pubspec"]?["version"] ?? "",
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 24,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: SelectableText(
                  prettyJson(history[index]?["pubspec"]?["dependencies"], indent: 2),
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: history.length,
    );
  }

  Widget _buildEnv() {
    return ListView.separated(
      separatorBuilder: (context, _) {
        return Divider(
          indent: 15,
          endIndent: 15,
          thickness: 0.5,
          color: Color(0xff4a4a4a),
        );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Text(
                history[index]?["pubspec"]?["version"] ?? "",
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 24,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: SelectableText(
                  prettyJson(history[index]?["pubspec"]?["environment"], indent: 2),
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: history.length,
    );
  }

  Widget _buildSource() {
    return ListView.separated(
      separatorBuilder: (context, _) {
        return Divider(
          indent: 15,
          endIndent: 15,
          thickness: 0.5,
          color: Color(0xff4a4a4a),
        );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Text(
                history[index]?["pubspec"]?["version"] ?? "",
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 24,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: SelectableText(
                  history[index]?["archive_url"] ?? "",
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: history.length,
    );
  }

  _buildReadMe(String? data) {
    if (data == null || data.isEmpty) return Container();
    return Container(
      child: LayoutBuilder(builder: (context, cons) {
        return WebView(
          data,
          cons.maxWidth,
          cons.maxHeight,
        );
      }),
    );
  }

  Widget _buildInstall() {
    var deply = """
${widget.packageName}:
    hosted:
      name: ${widget.packageName}
      url: $HOST_API
    version: ^${lastedVersion?["version"]}
""";
    return Container(
      padding: EdgeInsets.all(15),
      color: Colors.white,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
              ),
              child: SelectableText(
                "复制如下内容到你项目中的yaml文件,然后执行 pub get",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              color: Color(0xffF5F5F7),
              child: SelectableText(
                deply,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeWidget extends StatelessWidget {
  final String? info;

  const TeWidget(this.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: SelectableText(
        info!,
        style: TextStyle(
          color: Colors.black.withOpacity(0.8),
          fontSize: 16,
        ),
      ),
    );
  }
}
