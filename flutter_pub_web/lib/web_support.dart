import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

int tempRandomValue = 10;

class WebView extends StatefulWidget {
  final String markdown;
  final double width;
  final double height;

  WebView(this.markdown, this.width, this.height);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> with AutomaticKeepAliveClientMixin {
  String createdViewId = 'kd_webview${tempRandomValue++}';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 0),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      width: 200,
      height: 200,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Markdown(
          data: widget.markdown,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
