import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';

/// @author newtab on 2021/5/7
class LoadingDialogWidget extends StatelessWidget {
  const LoadingDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widget = Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(17, 17, 17, 0.7),
              borderRadius: BorderRadius.circular(5)),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.7,
            minWidth: 122,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 22.0),
                constraints: BoxConstraints(minHeight: 55.0),
                child: IconTheme(
                    data: IconThemeData(color: Colors.white, size: 55.0),
                    child: LoadingIcon()),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  child: Text("加载中..."),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return IgnorePointer(
      ignoring: false,
      child: widget,
    );
  }
}

class LoadingIcon extends StatefulWidget {
  final double size;

  LoadingIcon({this.size = 50.0});

  @override
  State<StatefulWidget> createState() => LoadingIconState();
}

class LoadingIconState extends State<LoadingIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _doubleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000))
      ..repeat();
    _doubleAnimation = Tween(begin: 0.0, end: 360.0).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: _doubleAnimation!.value ~/ 30 * 30.0 * 0.0174533,
        child: Image.asset("assets/loading.png",
            width: widget.size, height: widget.size));
  }
}

typedef HideCallback = Future Function();

int backButtonIndex = 2;

HideCallback showLoading(BuildContext context) {
  Completer<VoidCallback> result = Completer<VoidCallback>();
  var backButtonName = 'KD_Toast$backButtonIndex';
  BackButtonInterceptor.add((stopDefaultButtonEvent, _) {
    result.future.then((hide) {
      hide();
    });
    return true;
  }, zIndex: backButtonIndex, name: backButtonName);
  backButtonIndex++;

  OverlayEntry? overlay = OverlayEntry(
      maintainState: true,
      builder: (_) => WillPopScope(
            onWillPop: () async {
              var hide = await result.future;
              hide();
              return false;
            },
            child: LoadingDialogWidget(),
          ));
  result.complete(() {
    if (overlay == null) {
      return;
    }
    overlay?.remove();
    overlay = null;
    BackButtonInterceptor.removeByName(backButtonName);
  });
  if (overlay != null) {
    Overlay.of(context)?.insert(overlay!);
  }

  return () async {
    var hide = await result.future;
    hide();
  };
}
