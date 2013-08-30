// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains things which aren't really specific to this package,
/// but don't currently exist in any common libraries.
library cldr.util;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:codegen/codegen.dart';
import 'package:cli/cli.dart';
import 'package:unittest/mock.dart';

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

/// Creates a File and all of its parent directories synchronously.
// TODO: Replace with the resolution of http://dartbug.com/12462
createFileResursiveSync(File file) {
  file.directory.createSync(recursive: true);
  file.createSync();
}

/// Deletes all contents of a Directory synchronously.
void truncateDirectorySync(Directory directory) {

  void deleteFileSystemEntitySync(fse) {
    if(fse is Directory) {
      fse.deleteSync(recursive: true);
    } else if(fse is File || fse is Link) {
      fse.deleteSync();
    }
  }

  directory.listSync().forEach(deleteFileSystemEntitySync);
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
assertCommandExists(String testCommand, {Runner runner}) {
  if(runner == null) runner = new Runner();
  String commandChecker = Platform.isWindows ? 'where' : 'hash';
  var command = new Command(commandChecker, [testCommand]);
  var result = runner.runSync(command);
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

/// The root of the package in which the currently executing script exists.
final packageRoot = new PubPackage.containing(new Options().script).path;

/// The path to the test resources.
final testResources = join(packageRoot, 'test', 'resources');

/// An http client redirects requests to [testResources].
final testResourcesHttpClient = new TestResourcesHttpClient();
class TestResourcesHttpClient extends Mock implements Client {
  TestResourcesHttpClient() : super.spy(new MockClient(_testResourcesHandler));
}
MockClientHandler _testResourcesHandler = (Request request) => new Future(() {
  return new Response.bytes(
      new File(join(testResources, request.url.pathSegments.last))
          .readAsBytesSync(),
      200,
      request: request);
});
