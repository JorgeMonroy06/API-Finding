import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:http/http.dart' show ByteStream;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:tar/tar.dart';
import 'package:yaml/yaml.dart';

/// @author newtab on 2021/11/10

/// 使用前先看完注释
/// 发包方式:
/// 1. 下载https://github.com/jiang111/pub_server/blob/master/pub_publisher/bin/publite.exe这个文件,命令行执行 publite.exe E:\coding\myProject发包
/// 1.1 把下载的publite文件目录添加到环境变量,命令行运行 publite E:\coding\myProject发包
/// 2. 下载本源码,在dev_dependencies下添加下面的依赖,pub get,运行下面的main方法就可以发包了
/// 需要如下依赖
/// yaml: ^3.1.0
/// http: ^0.13.3
/// tar: ^0.5.1
/// 本文件只能放在2级目录,最好不要放在 test 和 lib 目录下,可以新建个 pub 文件夹放进去
///代码同步更新地址: https://github.com/jiang111/pub_server/edit/master/pub_publisher/lib/pub_publisher.dart

void main(List<String> args) {
  String rootDir = '';
  if (args.length > 0) {
    rootDir = args.first;
  }
  PubPublisher(rootDir).run();
}

class PubPublisher {
  static const maxSize = 100 * 1024 * 1024;
  final Git git = Git();
  final pubApiHeaders = {'Accept': 'application/vnd.pub.v2+json'};

  late String publishTo;
  String rootDir = '';

  PubPublisher(this.rootDir);

  String getYamlContent() {
    final String path = Path.join(baseDir(), 'pubspec.yaml');
    return File(path).readAsStringSync();
  }

  String baseDir() {
    if (rootDir != '') {
      return rootDir;
    }

    Path.Context context;
    if (Platform.isWindows) {
      context = Path.Context(style: Path.Style.windows);
    } else {
      context = Path.Context(style: Path.Style.posix);
    }
    final String baseDir = Path.dirname(Platform.script.toFilePath());
    final String path = context.join(baseDir, './../');
    return path;
  }

  ///被git忽略的文件不上传,如果文件过大,上传失败,可以查看build文件是不是没忽略
  List<String> checkGit() {
    print('\n正在检查git环境');
    final checkedIntoGit = git.runSync(['ls-files', '--cached', '--exclude-standard', '--recurse-submodules'], workingDir: baseDir());
    print('git环境正常');

    print('开始检查文件是否有异常:');

    checkedIntoGit.removeWhere((element) {
      bool exist = File(Path.join(baseDir(), element)).existsSync();
      if (!exist) {
        print('$element该文件不存在,建议执行git commit之后再发布私有库');
      }
      return !exist;
    });
    print('检查完毕');

    return checkedIntoGit;
  }

  ///检测yaml文件合法性
  bool checkYaml() {
    try {
      llog('\n正在检查pubspec.yaml文件');
      final Map content = loadYaml(getYamlContent());

      final containers = ['name', 'description', 'version', 'homepage', 'publish_to', 'environment', 'update_note'];

      for (var value in containers) {
        if (!content.containsKey(value) || content[value] == null) {
          llog('yaml文件必须包含 $value ,并且 $value 值不能为空');
          return false;
        }
      }

      publishTo = content['publish_to'];

      const notContainer = 'dependency_overrides';

      if (content.containsKey(notContainer)) {
        llog('发布三方库时,yaml文件不可以使用 $notContainer 字段');
        return false;
      }

      ///依赖的文件不能是本地路径

      Map dep = content['dependencies'];

      for (String key in dep.keys) {
        dynamic temp = dep[key];
        if (temp is! Map) continue;

        final Map value = dep[key];
        if (value.containsKey('path')) {
          llog('$key 库不能依赖本地路径,只能依赖远程地址');
          return false;
        }
      }
      llog('pubspec.yaml文件检查完毕');
      return true;
    } catch (e) {
      llog(e.toString());
      return false;
    }
  }

  ///验证打包的文件大小不能超过100M
  Future<bool> _validate(Future<int> packageSize) async {
    return packageSize.then((size) {
      if (size <= maxSize) return true;
      final sizeInMb = (size / math.pow(2, 20)).toStringAsPrecision(4);

      llog('当前文件为 $sizeInMb MB. 最大只支持上传100M的文件');
      return false;
    });
  }

  ///打包源码
  Future<Uint8List?> tarFiles(List<String> uploaders) async {
    llog('\n开始打包文件');
    final packageBytesFuture = IO.createTarGz(uploaders, baseDir: baseDir()).toBytes();

    final isValid = await _validate(packageBytesFuture.then((bytes) => bytes.length));

    if (isValid) {
      llog('打包完成');
      return packageBytesFuture;
    } else {
      llog('打包失败');
      return null;
    }
  }

  void run() async {
    llog('--------------------------------------------------------------------------------------------------------');
    llog('仅用于发布私有库,去掉了pub中大量的验证,不需要上传的文件请添加到.gitignore中,暂不支持.pubignore,项目必须启用git');
    final now = DateTime.now();
    llog('${now.hour}:${now.minute}:${now.second} 开始');
    if (!checkYaml()) {
      return;
    }
    final List<String> uploaders = checkGit();
    final Uint8List? data = await tarFiles(uploaders);
    if (data == null) return;
    await upload(data);
    final after = DateTime.now();
    llog('\n${after.hour}:${after.minute}:${after.second} 结束');

    final differ = after.difference(now);
    String time;

    if (differ.inSeconds == 0) {
      time = '${differ.inMilliseconds} 毫秒';
    } else {
      time = '${differ.inSeconds} 秒';
    }
    llog('本次上传共耗时: $time');
    llog('--------------------------------------------------------------------------------------------------------');
    exit(0);
  }

  ///开始上传
  Future<void> upload(Uint8List data) async {
    try {
      llog('\n开始上传package.tar.gz');
      final client = http.Client();
      final String newUrl = publishTo + '/api/packages/versions/new';
      final response = await client.get(Uri.parse(newUrl), headers: pubApiHeaders);
      if (response.statusCode != 200) {
        llog('请求失败: code: ${response.statusCode} , ${response.reasonPhrase}');
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      final String uploadUrl = json['url'];

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      request.followRedirects = false;
      request.files.add(http.MultipartFile.fromBytes('file', data, filename: 'package.tar.gz'));
      final postResponse = await http.Response.fromStream(await client.send(request));
      final location = postResponse.headers['location'];
      if (location == null) throw Exception(postResponse);
      final queryResponse = await client.get(Uri.parse(location), headers: pubApiHeaders);

      if (queryResponse.statusCode != 200) {
        llog('文件上传失败:${queryResponse.statusCode} ,${queryResponse.reasonPhrase} ,${queryResponse.body}');
      } else {
        final Map parsed = jsonDecode(queryResponse.body);
        if (parsed['success'] is! Map || !parsed['success'].containsKey('message') || parsed['success']['message'] is! String) {
          llog('文件上传失败:${queryResponse.statusCode} ,${queryResponse.reasonPhrase} ,${queryResponse.body}');
        }
        llog('文件上传成功');
      }
    } catch (e) {
      llog('上传出现异常');
      llog(e.toString());
    }
  }
}

class Git {
  bool get isInstalled => command != null;

  List<String> runSync(List<String> args, {String? workingDir, Map<String, String>? environment}) {
    if (!isInstalled) {
      llog('无法找到git命令,确保你的电脑已经安装了git');
    }

    final result = runProcessSync(command!, args, workingDir: workingDir, environment: environment);
    if (!result.success) {
      throw Exception(args.toString() + result.stdout.join('\n') + result.stderr.join('\n') + result.exitCode.toString());
    }

    return result.stdout;
  }

  String? get command {
    if (_commandCache != null) return _commandCache;

    if (_tryGitCommand('git')) {
      _commandCache = 'git';
    } else if (_tryGitCommand('git.cmd')) {
      _commandCache = 'git.cmd';
    } else {
      return null;
    }
    return _commandCache;
  }

  String? _commandCache;

  String? repoRoot(String dir) {
    if (isInstalled) {
      try {
        return Path.normalize(
          runSync(['rev-parse', '--show-toplevel'], workingDir: dir).first,
        );
      } on Exception {
        return null;
      }
    }
    return null;
  }

  bool _tryGitCommand(String command) {
    try {
      final result = runProcessSync(command, ['--version']);
      final regexp = RegExp('^git version');
      return result.stdout.length == 1 && regexp.hasMatch(result.stdout.single);
    } on Exception catch (err) {
      llog('Git command is not $command: $err');
      return false;
    }
  }

  PubProcessResult runProcessSync(
    String executable,
    List<String> args, {
    String? workingDir,
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    ArgumentError.checkNotNull(executable, 'executable');
    ProcessResult result;
    try {
      result = _doProcess(Process.runSync, executable, args, workingDir: workingDir, environment: environment, runInShell: runInShell);
    } on IOException catch (e) {
      throw Exception('Pub 运行失败 `$executable`: $e');
    }
    final pubResult = PubProcessResult(result.stdout, result.stderr, result.exitCode);
    return pubResult;
  }

  T _doProcess<T>(
    T Function(
      String,
      List<String>, {
      String? workingDirectory,
      Map<String, String>? environment,
      bool runInShell,
    })
        fn,
    String executable,
    List<String> args, {
    String? workingDir,
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    if (Platform.isWindows && !executable.contains('\\')) {
      args = ['/c', executable, ...args];
      executable = 'cmd';
    }

    return fn(executable, args, workingDirectory: workingDir, environment: environment, runInShell: runInShell);
  }
}

class PubProcessResult {
  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;
  static final _trailingCR = RegExp(r'\r$');

  static List<String> splitLines(String text) => text.split('\n').map((line) => line.replaceFirst(_trailingCR, '')).toList();

  PubProcessResult(String stdout, String stderr, this.exitCode)
      : stdout = _toLines(stdout),
        stderr = _toLines(stderr);

  static List<String> _toLines(String output) {
    final lines = splitLines(output);
    if (lines.isNotEmpty && lines.last == '') lines.removeLast();
    return lines;
  }

  bool get success => exitCode == 0;
}

class IO {
  static ByteStream createTarGz(
    List<String> contents, {
    required String baseDir,
  }) {
    ArgumentError.checkNotNull(baseDir, 'baseDir');
    baseDir = Path.absolute(baseDir);

    final tarContents = Stream.fromIterable(contents.map((entry) {
      entry = Path.absolute(baseDir, entry);
      if (!Path.isWithin(baseDir, entry)) {
        throw ArgumentError('Entry $entry is not inside $baseDir.');
      }

      final relative = Path.relative(entry, from: baseDir);
      // On Windows, we can't open some files without normalizing them
      final file = File(Path.normalize(entry));
      final stat = file.statSync();

      if (stat.type == FileSystemEntityType.link) {
        llog('$entry is a link locally, but will be uploaded as a '
            'duplicate file.');
      }

      return TarEntry(
        TarHeader(
          // Ensure paths in tar files use forward slashes
          name: Path.url.joinAll(Path.split(relative)),
          // We want to keep executable bits, but otherwise use the default
          // file mode
          mode: 420 | (stat.mode & 0x49),
          size: stat.size,
          modified: stat.changed,
          userName: 'pub',
          groupName: 'pub',
        ),
        file.openRead(),
      );
    }));

    return ByteStream(tarContents.transform(tarWriterWith(format: OutputFormat.gnuLongName)).transform(gzip.encoder));
  }
}

void llog(String msg) {
  print(msg);
}
