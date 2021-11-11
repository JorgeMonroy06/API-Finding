import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pub_web/loading_dialog.dart';
import 'package:flutter_pub_web/main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// @author newtab on 2021/5/7

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List list = [];

  @override
  void initState() {
    super.initState();
    getAllResp(context, false);
  }

  String keyword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff1c2834),
        elevation: 0,
        centerTitle: true,
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: FlutterLogo(),
        ),
        title: Text(
          APP_TIELE,
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                height: 150,
                color: Color(0xff132030),
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: getMaxWidth(context) / 1.4,
                  ),
                  child: CupertinoSearchTextField(
                    onChanged: (v) {
                      setState(() {
                        keyword = v;
                      });
                    },
                    placeholder: "输入 标题,描述,作者 等关键字搜索",
                    itemColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    placeholderStyle: TextStyle(
                      color: Color(0xff888888),
                      fontSize: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff35404d),
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                    ),
                    prefixInsets: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 30,
                    ),
                    itemSize: 16,
                  ),
                ),
              ),
              Container(
                width: getMaxWidth(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 1.5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "发布私有库务必在pubspec.yaml文件中注明 author: 作者字段,方便他人使用调试",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "当前共有 ${list.length - 1} 个packages${getKeyCount()}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff4a4a4a),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        String title = list[index]["title"];
                        String desc = list[index]["yaml"]["description"] ?? "";
                        String author = list[index]["yaml"]["author"] ?? "";

                        int time = list[index]["time"];
                        var format = new DateFormat("yyyy-MM-dd HH:mm");
                        var dateString = format.format(DateTime.fromMillisecondsSinceEpoch(time));

                        if (!title.contains(keyword) && !desc.contains(keyword) && !author.contains(keyword)) {
                          return Container();
                        }
                        return Container(
                          margin: EdgeInsets.only(
                            left: 15,
                            top: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed("/package/$title");
                                      },
                                      child: Container(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: Color(0xff0175c2),
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 15,
                                          ),
                                          child: SelectableText(
                                            desc,
                                            style: TextStyle(
                                              color: Color(0xff4a4a4a),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: Wrap(
                                            spacing: 15,
                                            children: [
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
                                                    list[index]["lastedVersion"],
                                                    style: TextStyle(
                                                      color: Color(0xff0175c2),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                mainAxisSize: MainAxisSize.min,
                                              ),
                                              Text(
                                                "•",
                                                style: TextStyle(
                                                  color: Color(0xff4a4a4a),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "最近更新:",
                                                    style: TextStyle(
                                                      color: Color(0xff4a4a4a),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    dateString,
                                                    style: TextStyle(
                                                      color: Color(0xff0175c2),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "•",
                                                style: TextStyle(
                                                  color: Color(0xff4a4a4a),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "作者:",
                                                    style: TextStyle(
                                                      color: Color(0xff4a4a4a),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    author,
                                                    style: TextStyle(
                                                      color: Color(0xff0175c2),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                child: Container(
                                  child: Icon(
                                    CupertinoIcons.doc_on_clipboard,
                                    size: 18,
                                    color: Color(0xff0175c2),
                                  ),
                                ),
                                onTap: () {
                                  var deply = """
$title:
    hosted:
      name: $title
      url: $HOST_API
    version: ^${list[index]["lastedVersion"]}
""";
                                  FlutterClipboard.copy(deply);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("依赖复制成功")));
                                },
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  top: 30,
                ),
                height: 80,
                color: Color(0xff27323A),
                child: Wrap(
                  spacing: 15,
                  children: toolLists.map<Widget>((e) {
                    return Container(
                      child: InkWell(
                        onTap: () async {
                          await launch(e.url);
                        },
                        child: Text(
                          e.name,
                          style: TextStyle(
                            height: 1,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Tools> toolLists = [
    Tools("JSON在线转dart", "https://javiercbk.github.io/json_to_dart/"),
    Tools("依赖版本说明", "https://dart.cn/tools/pub/dependencies"),
    Tools("Pub地址", "https://pub.flutter-io.cn/"),
    Tools("API", "https://api.flutter.dev/"),
  ];

  void getAllResp(BuildContext context, bool show) async {
    HideCallback? result;
    if (show) {
      result = showLoading(context);
    }

    var url = Uri.parse(HOST_API + "/api/getAllPackages");
    var response = await http.get(url);
    if (result != null) {
      result();
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      list.clear();
      list.addAll(json["packages"] as List);

      list.sort((a, b) {
        int time = a['time'];
        int time2 = b['time'];
        return time - time2 > 0 ? 0 : 1;
      });

      list.insert(0, "常用工具");
      setState(() {});
    }
  }

  String getKeyCount() {
    if (keyword.isEmpty) return "";

    var result = list.where((element) {
      if (element is String) {
        return false;
      } else {
        String title = element["title"];
        String desc = element["yaml"]["description"] ?? "";
        String author = element["yaml"]["author"] ?? "";
        if (!title.contains(keyword) && !desc.contains(keyword) && !author.contains(keyword)) {
          return false;
        }
        return true;
      }
    }).toList();

    return " , \"$keyword\"关键字发现了${result.length}个结果";
  }
}

class Tools {
  String name;
  String url;

  Tools(this.name, this.url);
}

double getMaxWidth(BuildContext context) {
  if (MediaQuery.of(context).size.width > 1000) {
    return 1000;
  }

  return MediaQuery.of(context).size.width;
}
