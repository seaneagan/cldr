// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:json' as json;
import 'package:path/path.dart';
import 'package:cldr/cldr.dart';

/// A base implementation of [DataSet].
abstract class DataSetBase implements DataSet {
  /// Json file [basename].  The file [extension] is always "json".
  final String _jsonFileBasename;

  /// Cldr top-level directory, either "main" or "supplemental".
  final String _subdirectory;

  /// Whether to include the locale in the path to files and data within files.
  final bool _pathIncludesLocale;

  DataSetBase(
      this._jsonFileBasename,
      this._subdirectory,
      this._pathIncludesLocale);

  /// Returns the json root relative path to the json file for [locale].
  String _getJsonFilePath(String locale) {
    var subSegments = _getFilePathSegments(locale);
    return join(
        joinAll(subSegments.take(subSegments.length - 1)),
        "${subSegments.last}.json");
  }

  /// Returns the json root relative path to the file for [locale].
  List<String> _getFilePathSegments(String locale) =>
      _getDirPathSegments(locale).toList()..add(_jsonFileBasename);

  /// Returns the json root relative path to the dir for [locale].
  List<String> _getDirPathSegments(String locale) {
    var segments = [_subdirectory];
    if(_pathIncludesLocale) segments.add(locale);
    return segments;
  }

  List<String> _getJsonStructureSegments(String locale) =>
      _getFilePathSegments(locale);

  _getOutputStructure(String jsonRoot, [String locale]) {
    var jsonFilePath = join(jsonRoot, _getJsonFilePath(locale));
    var theJson = new File(jsonFilePath).readAsStringSync();
    var jsonStructure = json.parse(theJson);
    return _getJsonSubstructure(jsonStructure, locale);
  }

  /// Returns the relevant substructure of [jsonStructure].
  _getJsonSubstructure(var jsonStructure, String locale) =>
      _getJsonStructureSegments(locale).fold(
          jsonStructure,
          (jsonStructure, segment) => jsonStructure[segment]);
}

class MainDataSet extends DataSetBase {
  MainDataSet(String jsonFileBasename)
      : super(jsonFileBasename, 'main', true);

  Map<String, dynamic> extract(String jsonRoot) {

    var topLevelDir = new Directory(join(jsonRoot, _subdirectory));
    var locales = topLevelDir.listSync().map((fse) => basename(fse.path));

    return locales.fold(new Map<String, dynamic>(), (localeDataMap, locale) {
      localeDataMap[locale] = _getOutputStructure(jsonRoot, locale);
      return localeDataMap;
    });
  }
}

class SupplementalDataSet extends DataSetBase {
  SupplementalDataSet(String jsonFileBasename)
      : super(jsonFileBasename, 'supplemental', false);

  Map<String, dynamic> extract(String jsonRoot) =>
      _getOutputStructure(jsonRoot);
}

class CalendarDataSet extends MainDataSet {

  final String calendarId;

  CalendarDataSet(String calendarId)
      : this.calendarId = calendarId,
        super('ca-$calendarId');

  List<String> _getJsonStructureSegments(String locale) =>
      _getDirPathSegments(locale)
          .toList()
          ..addAll(['dates', 'calendars', calendarId]);
}