// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:pub_server/directmessage.dart';
import 'package:pub_server/repository.dart';
import 'package:yaml/yaml.dart';

import 'push.dart';

final Logger _logger = Logger('pub_server.file_repository');

/// Implements the [PackageRepository] by storing pub packages on a file system.
class FileRepository extends PackageRepository {
  @override
  final String baseDir;

  FileRepository(this.baseDir) : super(baseDir: baseDir);

  @override
  Stream<PackageVersion> versions(String package) {
    var directory = Directory(p.join(baseDir, package));
    if (directory.existsSync()) {
      return directory.list(recursive: false).where((fse) => fse is Directory).map((dir) {
        var version = p.basename(dir.path);
        var pubspecFile = File(pubspecFilePath(package, version));
        var tarballFile = File(packageTarballPath(package, version));
        if (pubspecFile.existsSync() && tarballFile.existsSync()) {
          var pubspec = pubspecFile.readAsStringSync();
          return PackageVersion(package, version, pubspec, pubspecFile.statSync().modified.millisecondsSinceEpoch);
        }
        return null;
      }).where((e) => e != null);
    }

    return Stream.fromIterable([]);
  }

  // TODO: Could be optimized by searching for the exact package/version
  // combination instead of enumerating all.
  @override
  Future<PackageVersion> lookupVersion(String package, String version) {
    return versions(package).where((pv) => pv.versionString == version).toList().then((List<PackageVersion> versions) {
      if (versions.isNotEmpty) return versions.first;
      return null;
    });
  }

  @override
  bool get supportsUpload => true;

  @override
  Future<PackageVersion> upload(Stream<List<int>> data) async {
    _logger.info('Start uploading package.');
    var bb = await data.fold(BytesBuilder(), (BytesBuilder byteBuilder, d) => byteBuilder..add(d));
    var tarballBytes = bb.takeBytes();
    var tarBytes = GZipDecoder().decodeBytes(tarballBytes);
    var archive = TarDecoder().decodeBytes(tarBytes);
    ArchiveFile pubspecArchiveFile;
    ArchiveFile readMeFile;
    for (var file in archive.files) {
      if (file.name == 'pubspec.yaml') {
        pubspecArchiveFile = file;
      }
      if (file.name.toLowerCase() == 'README.md'.toLowerCase()) {
        readMeFile = file;
      }
      if (pubspecArchiveFile != null && readMeFile != null) break;
    }

    if (pubspecArchiveFile == null) {
      throw 'Did not find any pubspec.yaml file in upload. Aborting.';
    }
    if (pubspecArchiveFile == null) {
      throw 'Did not find any REAME.md file in upload. please add README.md in your package. Aborting.';
    }

    // TODO: Error handling.
    var pubspec = loadYaml(convert.utf8.decode(_getBytes(pubspecArchiveFile)));

    var package = pubspec['name'] as String;
    var version = pubspec['version'] as String;

    try {
      final startVersion = RegExp(r'^' // Start at beginning.
          r'(\d+).(\d+).(\d+)' // Version number.
          r'(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?' // Pre-release.
          r'(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'); // Build.

      final completeVersion = RegExp('${startVersion.pattern}\$');
      final match = completeVersion.firstMatch(version);
      if (match == null) {
        throw StateError('版本号存在问题,只支持x.x.x或者更短的格式');
      }
    } catch (e) {
      throw StateError('`$package` ${e.toString()}');
    }

    var packageVersionDir = Directory(p.join(baseDir, package, version));

    if (!packageVersionDir.existsSync()) {
      packageVersionDir.createSync(recursive: true);
    }

    var pubspecFile = File(pubspecFilePath(package, version));
    if (pubspecFile.existsSync()) {
      throw StateError('`$package` already exists at version `$version`.');
    }

    var pubspecContent = convert.utf8.decode(_getBytes(pubspecArchiveFile));
    pubspecFile.writeAsStringSync(pubspecContent);

    if (readMeFile != null) {
      var readMeTargetFile = File(readMeFilePath(package, version));
      var readMeContent = convert.utf8.decode(_getBytes(readMeFile));
      readMeTargetFile.writeAsStringSync(readMeContent);
    }
    File(packageTarballPath(package, version)).writeAsBytesSync(tarballBytes);

    _logger.info('Uploaded new $package/$version');

    return PackageVersion(package, version, pubspecContent, pubspecArchiveFile.lastModTime);
  }

  @override
  bool get supportsDownloadUrl => false;

  @override
  Future<Stream<List<int>>> download(String package, String version) async {
    var pubspecFile = File(pubspecFilePath(package, version));
    var tarballFile = File(packageTarballPath(package, version));

    if (pubspecFile.existsSync() && tarballFile.existsSync()) {
      return tarballFile.openRead();
    } else {
      throw 'package cannot be downloaded, because it does not exist';
    }
  }

  String pubspecFilePath(String package, String version) => p.join(baseDir, package, version, 'pubspec.yaml');

  String readMeFilePath(String package, String version) => p.join(baseDir, package, version, 'README.md');

  String packageTarballPath(String package, String version) => p.join(baseDir, package, version, 'package.tar.gz');

  @override
  Future<List<String>> getAllPackages() {
    var directory = Directory(baseDir);
    if (directory.existsSync()) {
      return directory
          .list(recursive: false)
          .where((event) => event.statSync().type == FileSystemEntityType.directory)
          .map((event) => event.path.split(p.separator).last)
          .toList();
    } else {
      return null;
    }
  }
}

// Since pkg/archive v1.0.31, content is `dynamic` although in our use case
// it's always `List<int>`
List<int> _getBytes(ArchiveFile file) => file.content as List<int>;
