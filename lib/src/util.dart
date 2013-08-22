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

// Uppercase or lowercase the first charater of a String.
String withCapitalization(String s, bool capitalized) {
  var firstLetter = s[0];
  firstLetter = capitalized ?
      firstLetter.toUpperCase() :
      firstLetter.toLowerCase();
  return firstLetter + s.substring(1);
}

// Convert a camel case String to underscore separated.
// e.g. "fooBar" -> "foo_bar" or "FOO_BAR" (capitalized == true)
//String camelCaseToUnderscores(String camelCase, bool capitalized) {
//  var camel = withCapitalization(camelCase, true).splitMapJoin(
//      new Regexp(r'[A-Z]([a-z]+|[A-Z]+)?'),
//      onMatch: (_) => "",
//      onNonMatch: (String segment) => withCapitalization(segment, true));
//  return withCapitalization(camel, capitalized);
//}
