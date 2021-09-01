import 'dart:convert';

/// @author newtab on 2021/5/7

class DirectMessage {
  String title;
  String lastedVersion;
  dynamic yaml;
  num time;

  DirectMessage(
    this.lastedVersion,
    this.title,
    this.yaml,
    this.time,
  );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'lastedVersion': lastedVersion,
      'yaml': yaml,
      'time': time,
    };
  }
}
