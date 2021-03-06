// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.tool.data_set_gen;

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:args/args.dart';
import 'package:codegen/codegen.dart';
import 'package:cldr/src/util.dart';
import '../bin/src/util.dart';

/// Generates the 'data_sets.dart' library.
///
/// Usage:
///
///     dart data_set_gen.dart [options]
///
/// Options:
///
/// --help         Print this usage information.
/// --json_path    The path containing ldml2json output.
///                (defaults to "<this_package>/third_party/cldr/json")
main() {

  // Define args.
  var parser = new ArgParser();
  addHelp(parser);
  parser.addOption(
      'json_path',
      help: '''The path containing ldml2json output.
(defaults to "<this_package>/third_party/cldr/json")''');

  // Process args.
  var results = parser.parse(new Options().arguments);
  if(results['help']) {
    print(getFullUsage(parser,
        description: "Generates the '$_libraryName' library."));
    return;
  }
  var jsonPath = results['json_path'];
  if(jsonPath == null) {
    jsonPath = defaultLdml2JsonOutputPath;
  }

  _generateDataSetsLibrary(jsonPath);
}

/// Generate the DataSets library.
_generateDataSetsLibrary(String jsonPath) {
  var jsonDir = new Directory(jsonPath);
  var code = _getDataSetsCode(jsonDir);

  var package = new PubPackage.containing();

  new Library(
      join(package.lib, _libraryName),
      code,
      [
        new Import(package.getPackageUri('cldr.dart')),
        new Import(package.getPackageUri(
            join('src', 'data_set_impl.dart')))
      ],
      comment: '''$_copyRight

/// Exposes [DataSet]s which can be extracted from Cldr.''')
  .generate();
}

/// The name of the library being generated.
final _libraryName = 'data_sets.dart';

/// Returns the dart code representing the DataSets.
String _getDataSetsCode(Directory directory) {

  isCalendarDataSet(dataSet) => dataSet['type'] == 'Calendar';

  var dataSets = _getDataSets(directory);

  var topLevelDataSets = dataSets.where((dataSet) =>
      !isCalendarDataSet(dataSet));
  var topLevelDataSetCode = topLevelDataSets
      .map(_getTopLevelDataSetDeclaration).join('\n\n');

  var calendarDataSets = dataSets.where(isCalendarDataSet);
  var calendarDataSetCode = _getCalendarSystemsDeclaration(calendarDataSets);

  var calendarSystems = calendarDataSets.map((dataSet) => dataSet['member']);

  var enumDeclaration = _getCalendarSystemEnumDeclaration(calendarSystems);
  return '''
$topLevelDataSetCode

$calendarDataSetCode

$enumDeclaration
''';
}

/// Returns a simple representation of the DataSets found in [directory]
/// sorted by name.
Iterable<Map<String, String>> _getDataSets(Directory directory) {

  var mainDir = new Directory(join(directory.path, 'main', 'root'));
  var supplementalDir = new Directory(join(directory.path, 'supplemental'));

  var dirs = {
    'main': mainDir,
    'supplemental': supplementalDir
  };

  return (dirs.keys.map((dirname) =>
      dirs[dirname].listSync()
      .map((file) => basenameWithoutExtension(file.path))
      .map((basenameWithoutExtension) {

        var calendarPrefix = 'ca-';

        var isCalendar = basenameWithoutExtension.startsWith(calendarPrefix);

        var type = isCalendar ?
            'Calendar' :
            withCapitalization(dirname, true);

        var named = {};

        var mainParentSegments = {
          'dates': 'timeZoneNames',
          'numbers': 'currenties'
        }..addAll(new Map.fromIterable([
          'languages',
          'measurementSystemNames',
          'scripts',
          'territories',
          'transformNames',
          'variants'
        ], value: (_) => 'localeDisplayNames'));

        var supplementalSegments = {
          'characterFallbacks': 'characters',
          'dayPeriods': 'dayPeriodRuleSet'
        };

        if(dirname == 'main' && mainParentSegments.containsKey(basenameWithoutExtension)) {
          named['parentSegments'] = [mainParentSegments[basenameWithoutExtension]];
        }

        if(dirname == 'supplemental' && supplementalSegments.containsKey(basenameWithoutExtension)) {
          named['segment'] = supplementalSegments[basenameWithoutExtension];
        }

        var dataSetName =
            removePrefix(basenameWithoutExtension, calendarPrefix);

        var member = isCalendar ?
            dataSetName.toUpperCase().replaceAll('-', '_') :
            separatorsToCamelCase(basenameWithoutExtension, false);

        return {
          'type': type,
          'positionals': [dataSetName],
          'named': named,
          'member' : member
        };
      }))
      .expand((x) => x)
      .toList()
      ..sort((dataSet1, dataSet2) =>
          dataSet1['member'].compareTo(dataSet2['member'])));
}

/// Returns dart code representing a top-level variable declaration
/// for [dataSet].
String _getTopLevelDataSetDeclaration(Map<String, dynamic> dataSet) {

  var member = dataSet['member'];

  // TODO: Consider converting dataSetVar to ALL_CAPS depending on outcome of
  // http://dartbug.com/12608.
  return "final DataSet $member = ${_getDataSetInstantiation(dataSet)};";
}

String _getCalendarSystemsDeclaration(calendarSystemDataSets) {
  var mapContents = calendarSystemDataSets.map((calendarSystem) =>
      "  CalendarSystem.${calendarSystem['member']}: "
      "${_getDataSetInstantiation(calendarSystem)}").join(''',
''');

  var mapLiteral = '''{
$mapContents
}''';

  return "final Map<CalendarSystem, DataSet> calendarSystems = $mapLiteral;";
}

String _getDataSetInstantiation(Map<String, dynamic> dataSet) {
    var type = dataSet['type'];
    var positionals = dataSet['positionals'].map(JSON.encode).join(', ');
    var named = dataSet['named'].keys.map((name) =>
        '$name: ${JSON.encode(dataSet['named'][name])}').join(', ');
    var args = [positionals, named].where((part) => part != '').join(', ');

    return "new ${type}DataSet($args)";
}

String _getCalendarSystemEnumDeclaration(Iterable<String> calendarSystems) {

  var enumContents = calendarSystems.map((calendarSystem) =>
      "  static const $calendarSystem = "
      "const CalendarSystem._('$calendarSystem');").join('\n\n');

  return '''
/// A [calendar system][wiki] for which Cldr has data.
/// [wiki]: http://en.wikipedia.org/wiki/Calendar#Calendar_systems
class CalendarSystem {
    
  final String _name;

  const CalendarSystem._(this._name);

$enumContents

  String toString() => 'CalendarSystem.\$_name';
}''';
}

/// Converts an underscore separated String to camel case.
/// e.g. "foo_bar" -> "fooBar" or "FooBar" (capitalized == true)
String separatorsToCamelCase(String underscores, bool capitalized) {
  var camel = underscores.splitMapJoin(
      new RegExp(r'[-_]'),
      onMatch: (_) => "",
      onNonMatch: (String segment) => withCapitalization(segment, true));
  return withCapitalization(camel, capitalized);
}

/// Returns a copy of [s] with [prefix] removed.
String removePrefix(String s, String prefix) =>
    s.startsWith(prefix) ? s.substring(prefix.length) : s;

final _copyRight = '''
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.''';


