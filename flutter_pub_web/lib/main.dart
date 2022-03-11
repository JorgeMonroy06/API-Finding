import 'package:flutter/material.dart';
import 'package:flutter_pub_web/route.dart';


const HOST_API = "http://10.67.9.31:6453";
// const HOST_API = "http://localhost:6453";
const APP_TIELE = "Flutter私有库管理";
Color baseColor = Color(0xffF6F8FA);
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TIELE,
      initialRoute: "/",
      onGenerateRoute: Path.onGenerateRoute,
      onUnknownRoute: (_) {
        return MaterialPageRoute(
          builder: (context) {
            return Container(
              child: Center(
                child: Text("请求的页面不存在"),
              ),
            );
          },
        );
      },
    );
  }
}
