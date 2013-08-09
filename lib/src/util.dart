// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This library contains things which aren't really specific to this package,
// but don't currently exist in any common libraries.
library intl.util;

import 'dart:async';
import 'package:logging/logging.dart';

// TODO: Replace this with the resolution of http://dartbug.com/1236.
// TODO: Change fallback to a callback for lazy evaluation.
ifNull(value, fallback) => value == null ? fallback : value;

/// Converts first character of [s] to uppercase if [capitalized] is true, or
/// otherwise lowercase.
String withCapitalization(String s, bool capitalized) {
  var firstLetter = s[0];
  firstLetter = capitalized ?
      firstLetter.toUpperCase() :
      firstLetter.toLowerCase();
  return firstLetter + s.substring(1);
}

/// Converts an underscore separated String, [underscores], to camel case.
/// e.g. "foo_bar" -> "fooBar" or "FooBar" (capitalized == true)
String underscoresToCamelCase(String underscores, bool capitalized) {
  var camel = underscores.splitMapJoin(
      "_",
      onMatch: (_) => "",
      onNonMatch: (String segment) => withCapitalization(segment, true));
  return withCapitalization(camel, capitalized);
}

/// Returns the first segment of [locale] (up to the first "_" or "-").
// TODO: Replace this and Intl.shortLocale with an implementation of:
// http://tools.ietf.org/html/rfc4647#section-3.4
String baseLocale(String locale) {
  if (locale.length < 2) return locale;
  final upToFirstSeparator = new RegExp(r'[^_-]*');
  return upToFirstSeparator.stringMatch(locale.toLowerCase());
}

/// Allows one to log the start and end of a logical step in a DRY manner.
class LogStep {
  final Logger _logger;
  final String _description;
  final Level _level;
  LogStep(this._logger, this._description, {Level level: Level.INFO})
      : _level = level;

  /// Logs the start of the step.
  start() => _logBoundary("START");

  /// Logs the end of the step.
  end() => _logBoundary("END  ");

  /// The step as defined by [f] is [start]ed, executed, and then [end]ed,
  /// which if [f] returns a [Future], will not occur until its completion.
  execute(f()) {
    start();
    var ret = f();
    if(ret is Future) return ret.then((v) {
      end();
      return v;
    }, onError: (e) {_logger.severe("FAIL STEP: $_description");});
    end();
    return ret;
  }

  _logBoundary(String boundary) =>
      _logger.log(_level, "$boundary STEP: $_description");
}

/// Returns a [Logger] with a preattached [Logger.onRecord] handler.
// TODO: Replace with the resolution of http://dartbug.com/12028.
Logger getLogger(String name) {
  var _logger = new Logger("${package.name}.$name");
  _logger.onRecord.listen((record) => print(_logRecordToString(record)));
  return _logger;
}

/// Returns a basic serialization of a [LogRecord].
// TODO: Replace with the resolution of http://dartbug.com/12030.
String _logRecordToString(LogRecord record) =>
    '[${record.level}] ${record.message}';
