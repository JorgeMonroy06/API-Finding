import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// @author NewTab

class Tools {
  String name;
  String url;

  Tools(this.name, this.url);
}

class BottomWidget extends StatelessWidget {
  BottomWidget({Key? key}) : super(key: key);
  final List<Tools> toolLists = [
    Tools("JSON在线转dart", "https://javiercbk.github.io/json_to_dart/"),
    Tools("依赖版本说明", "https://dart.cn/tools/pub/dependencies"),
    Tools("Pub地址", "https://pub.flutter-io.cn/"),
    Tools("API", "https://api.flutter.dev/"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
