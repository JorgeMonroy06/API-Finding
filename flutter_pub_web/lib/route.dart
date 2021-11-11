import 'package:flutter/material.dart';

import 'detail_page.dart';
import 'home_page.dart';

/// @author newtab on 2021/9/10

class Path {
  const Path(this.pattern, this.builder);

  final String pattern;
  final Widget Function(BuildContext, String?) builder;

  static List<Path> paths = [
    Path(
      r'^/package/([\w-]+)$',
      (context, match) {
        return DetailPage(
          packageName: match ?? "",
          color: Colors.white,
        );
      },
    ),
    Path(
      r'^/',
      (context, match) => HomePage(),
    ),
  ];

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    for (Path path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (settings.name == null) {
        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, ""),
          settings: settings,
        );
      }
      if (regExpPattern.hasMatch(settings.name!)) {
        final firstMatch = regExpPattern.firstMatch(settings.name!);
        final match = (firstMatch?.groupCount == 1) ? firstMatch?.group(1) : null;
        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, match),
          settings: settings,
        );
      }
    }
    return null;
  }
}
