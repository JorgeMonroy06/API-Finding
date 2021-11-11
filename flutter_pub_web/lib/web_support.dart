import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart';


int tempRandomValue = 10;

class WebView extends StatefulWidget {
  final String markdown;
  final double width;
  final double height;

  WebView(this.markdown,this.width,this.height);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> with AutomaticKeepAliveClientMixin{
  String createdViewId = 'kd_webview${tempRandomValue++}';

  @override
  void initState() {
    super.initState();
    String md = markdownToHtml(widget.markdown);
    ui.platformViewRegistry.registerViewFactory(
        createdViewId,
            (int viewId) => html.IFrameElement()
          ..width = widget.width.toString() //'800'
          ..height = widget.height.toString() //'400'
          ..srcdoc = """<!DOCTYPE html><html>
          <head><title></title></head><body>${md}</body></html>"""
          ..style.border = 'none');
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
        child: HtmlElementView(
          viewType: createdViewId,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
