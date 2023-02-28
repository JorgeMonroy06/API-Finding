import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pub_web/bottom_widget.dart';
import 'package:flutter_pub_web/loading_dialog.dart';
import 'package:flutter_pub_web/main.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:responsive_builder/responsive_builder.dart';



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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllResp(context, false);
    });
  }

  String keyword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBar(
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
                    fontSize: 18,
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
              Container(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBar(
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
                    fontSize: 18,
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
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: getMaxWidth(context) / 1.4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 80,
                      ),
                      CupertinoSearchTextField(
                        onChanged: (v) {
                          setState(() {
                            keyword = v;
                          });
                        },
                        placeholder: "输入 标题,描述,作者 等关键字搜索",
                        itemColor: Colors.white,
                        suffixInsets: EdgeInsets.symmetric(horizontal: 15,),
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
                      SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: getMaxWidth(context),
                margin: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                child: Text(
                  "当前共有 ${list.length} 个packages${getKeyCount()}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff4a4a4a),
                  ),
                ),
              ),
              Container(
                width: getMaxWidth(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 1.5),
                  child: ResponsiveBuilder(builder: (context, sizingInformation) {
                    if (list.isEmpty) {
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey.shade100,
                        enabled: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        " ",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xff0175c2),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      " ",
                                      style: TextStyle(
                                        color: Color(0xff4a4a4a),
                                        fontSize: 16,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          " ",
                                          style: TextStyle(
                                            color: Color(0xff4a4a4a),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          " ",
                                          style: TextStyle(
                                            color: Color(0xff0175c2),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      mainAxisSize: MainAxisSize.min,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: getCrossAxisCount(sizingInformation),
                            childAspectRatio: getChildAspectRatio(sizingInformation),
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        String title = list[index]["title"];
                        String desc = list[index]["yaml"]["description"] ?? "";
                        String author = list[index]["yaml"]["author"] ?? "";

                        if (!title.contains(keyword) && !desc.contains(keyword) && !author.contains(keyword)) {
                          return Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                          );
                        }
                        return Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.of(context).pushNamed("/package/$title");
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: AutoSizeText(
                                        title,
                                        maxLines: 1,
                                        minFontSize: 14,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xff1967d2),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    IgnorePointer(
                                      ignoring: true,
                                      child: SelectableText(
                                        desc,
                                        enableInteractiveSelection: false,
                                        style: TextStyle(
                                          height: 1.2,
                                          color: Color(0xff333333),
                                          fontSize: 16,
                                        ),
                                        minLines: 2,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          "最新版本: ",
                                          style: TextStyle(
                                            height: 1,
                                            color: Color(0xff333333),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          list[index]["lastedVersion"],
                                          style: TextStyle(
                                            height: 1,
                                            color: Color(0xff1967d2),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      mainAxisSize: MainAxisSize.min,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(sizingInformation),
                        childAspectRatio: getChildAspectRatio(sizingInformation),
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              BottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  double getChildAspectRatio(SizingInformation sizingInformation) {
    if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
      return 2;
    }
    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      return 2;
    }

    return 1.3;
  }

  int getCrossAxisCount(SizingInformation sizingInformation) {
    if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
      return 1;
    }
    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      return 2;
    }
    return 4;
  }

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

double getMaxWidth(BuildContext context) {
  if (MediaQuery.of(context).size.width > 1100) {
    return 1100;
  }

  return MediaQuery.of(context).size.width;
}
