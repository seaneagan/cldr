// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains things which aren't really specific to this package,
/// but don't currently exist in any common libraries.
library cldr.util;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';

/// Returns a [Logger] with a preattached [Logger.onRecord] handler.
// TODO: Replace with the resolution of http://dartbug.com/12028.
Logger getLogger(String name) {
  var _logger = new Logger(name);
  _logger.onRecord.listen((record) => print(_logRecordToString(record)));
  return _logger;
}

/// Returns a basic serialization of a [LogRecord].
// TODO: Replace with the resolution of http://dartbug.com/12030.
String _logRecordToString(LogRecord record) =>
    '[${record.level}] ${record.message}';

/// Clean [directory] synchronously, create if it doesn't already exist.
cleanDirectorySync(Directory directory) {
  if(directory.existsSync()) {
    // Clean directory.
    truncateDirectorySync(directory);
  } else {
    // Create directory.
    directory.createSync(recursive: true);
  }
}

/// Deletes all contents of a Directory synchronously.
void truncateDirectorySync(Directory directory) {
  directory.listSync().forEach(_deleteFileSystemEntitySync);
}

void _deleteFileSystemEntitySync(fse) {
  if(fse is Directory) {
    fse.deleteSync(recursive: true);
  } else if(fse is File || fse is Link) {
    fse.deleteSync();
  }
}

/// Uppercase or lowercase the first charater of a String.
String withCapitalization(String s, bool capitalized) {
  var firstLetter = s[0];
  firstLetter = capitalized ?
      firstLetter.toUpperCase() :
      firstLetter.toLowerCase();
  return firstLetter + s.substring(1);
}

/// Assert that a given shell command exists.
assertCommandExists(String command) {
  String commandChecker = Platform.isWindows ? 'where' : 'hash';
  var result = Process.runSync(commandChecker, [command]);
  var exists = result.exitCode == 0;
  if(!exists) {
    throw new MissingDependencyError('"$command" shell command');
  }
}

/// Error thrown when an external dependency is missing.
class MissingDependencyError extends Error {

  final String missingDependency;

  MissingDependencyError(this.missingDependency);

  String toString() => 'Missing dependency: $missingDependency';
}

/// Returns a class path consisting of [paths] using the platform dependent
/// class path separator.
String getClassPath(Iterable<String> paths) => paths.join(_classPathSeparator);

/// The platform dependent separator of items in a java class path.
final String _classPathSeparator = Platform.isWindows ? ";" : ":";

/// Returns args to send to a java process.
List<String> getJavaArgs(
    String javaClass, {
    String classPath,
    List<String> classArgs: const [],
    Map<String, String> systemProperties: const {}}) {

  var args = systemProperties.keys.map((key) =>
      '-D$key=${systemProperties[key]}')
      .toList();
  if(classPath != null) args.addAll(['-cp', classPath]);
  return args..add(javaClass)..addAll(classArgs);
}
