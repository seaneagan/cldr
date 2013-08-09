
library cldr.json_extractor;

import 'dart:io';
import 'dart:json' as json;
import 'package:path/path.dart';
import 'package:cldr/src/util.dart';

/// Mechanism to extract data from [Ldml2Json] output.
abstract class JsonExtractor {

  static var logger = getLogger("cldr.JsonExtractor");

  /// Path to the root of the [Ldml2Json] output.
  final String jsonRoot;

  /// Json file [basename].  The [extension] is always "json".
  final String jsonFileBasename;

  /// Cldr top-level directory, either "main" or "supplemental".
  final String _cldrTopLevelDir;

  /// Whether to include the locale in the path to files and data within files.
  final bool _pathIncludesLocale;

  JsonExtractor._(
      this.jsonRoot,
      this.jsonFileBasename,
      this._cldrTopLevelDir,
      this._pathIncludesLocale);

  factory JsonExtractor.main(
      String jsonRoot, String jsonFileBasename) =
      _MainJsonExtractor;

  factory JsonExtractor.supplemental(
      String jsonRoot, String jsonFileBasename) =
      _SupplementalJsonExtractor;

  /// Extracts parsed json from [Ldml2Json] output file(s) and returns it.
  Map<String, dynamic> extract();

  /// Returns the relative path from [jsonRoot] of the json file for
  /// [locale].
  String _getJsonFilePath(String locale) {
    var subSegments = _getJsonStructureSegments(locale);
    return join(
        jsonRoot,
        joinAll(subSegments.take(subSegments.length - 1)),
        "${subSegments.last}.json");
  }

  List<String> _getJsonStructureSegments(String locale) {
    var segments = [_cldrTopLevelDir];
    if(_pathIncludesLocale) segments.add(locale);
    segments.add(jsonFileBasename);
    return segments;
  }

  _getOutputStructure([String locale]) {
    var jsonFilePath = _getJsonFilePath(locale);
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

class _MainJsonExtractor extends JsonExtractor {

  _MainJsonExtractor(
      String cldrJsonPath, String cldrFileBasename)
      : super._(cldrJsonPath, cldrFileBasename, "main", true);

  Map<String, dynamic> extract() {

    var topLevelDir = new Directory(join(jsonRoot, _cldrTopLevelDir));
    var locales = topLevelDir.listSync().map((fse) => basename(fse.path));

    return locales.fold(new Map<String, dynamic>(), (localeDataMap, locale) {
      localeDataMap[locale] = _getOutputStructure(locale);
      return localeDataMap;
    });
  }
}

class _SupplementalJsonExtractor extends JsonExtractor {

  _SupplementalJsonExtractor(
    String cldrJsonPath, String cldrFileBasename)
    : super._(cldrJsonPath, cldrFileBasename, "supplemental", false);

  Map<String, dynamic> extract() => _getOutputStructure();
}

