// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.ldml2json_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:args/args.dart';
import 'package:cli/cli.dart';
import 'package:cli/testing.dart';
import 'package:cldr/cldr.dart';
import 'package:cldr/cldr_installation.dart';
import 'package:cldr/src/ldml2json_converter_command.dart';
import 'package:cldr/src/util.dart';
import '../bin/src/util.dart';

main() {

  final cldrPath = defaultCldrInstallPath;

  group('Ldml2Json', () {

    Directory tempDir;
    String outPath;
    String configPath;
    File existingFile;

    setUp(() {
      tempDir = new Directory('').createTempSync();
      outPath = new Directory(join(tempDir.path, 'out')).path;
      var config = '''
section=units ; path=//cldr/main/en/units/.*
section=plurals ; path=//cldr/supplemental/plurals/.*
''';
      configPath = (new File(join(tempDir.path, 'ldml2json_config.txt'))
          ..writeAsStringSync(config))
          .path;
      existingFile = new File(join(outPath, 'supplemental', 'old.json'));
      createFileResursiveSync(existingFile);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('convert', () {

      ProcessResult mockLdml2JsonConverter(Command command) =>
          new MockProcessResult(
              stdout: 'Mock Ldml2JsonConverter stdout.',
              stderr: 'Mock Ldml2JsonConverter stderr.');
      var mockRunner = new MockRunner(mockLdml2JsonConverter);

      var unit = new Ldml2Json(
          new MockCldrInstallation(cldrPath),
          outPath,
          config: configPath,
          runner: mockRunner);

      var out = unit.convert();

      isConvertCommand(String cldrSubdirectory) => predicate((command) {
        if(command is! Ldml2JsonConverterCommand) return false;
        command = command as Ldml2JsonConverterCommand;
        return command.cldrSubdirectory == cldrSubdirectory &&
               command.out == outPath &&
               command.config == configPath &&
               command.installation.path == cldrPath;
      }, "Ldml2JsonConverterCommand for '$cldrSubdirectory' Cldr subdirectory");

      Ldml2JsonConverterCommand.CLDR_SUBDIRECTORIES.forEach((cldrSubdirectory) {
        mockRunner.getLogs(
            callsTo('runSync', isConvertCommand(cldrSubdirectory)))
                .verify(happenedOnce);
      });

      expect(
          out.path,
          outPath,
          reason: 'Correct output directory is returned.');

    });
  });

  group('Ldml2JsonConverterCommand', () {

    var outPath = 'out';
    var cldrSubdirectory = 'main';
    var config = 'foo.txt';
    Ldml2JsonConverterCommand unit;
    // A partial parser to validate certain options are included.
    ArgParser parser;

    setUp(() {
      parser = new ArgParser();
      var options = {
        'destdir': 'd',
        'type': 't',
        'resolved': 'r',
        'konfig': 'k'
      };
      options.forEach((option, abbr) => parser.addOption(option, abbr: abbr));

      unit = new Ldml2JsonConverterCommand(
          new MockCldrInstallation(cldrPath),
          cldrSubdirectory,
          config,
          outPath);
    });

    group('classArguments', () {

      ArgResults results;

      setUp(() {
        results = parser.parse(unit.classArguments);
      });

      group('main', () {

      });

      test('correct --type option', () =>
          expect(results, hasOption('type', cldrSubdirectory)));
      test('correct --destdir option', () =>
          expect(results, hasOption('destdir', join(outPath, cldrSubdirectory))));
      test('correct --resolved option', () =>
          expect(results, hasOption('resolved', 'true')));
      test('correct --konfig option', () =>
          expect(results, hasOption('konfig', config)));
    });
  });
}

hasOption(String option, var matcher) => new _HasOptionMatcher(option, matcher);

class _HasOptionMatcher extends CustomMatcher {

  final String _option;

  _HasOptionMatcher(String option, matcher)
      : this._option = option,
        super(
            "ArgResults with option '$option' that is",
            "option '$option'",
            matcher);

  featureValueOf(actual) => actual[_option];
}

class _MockCldrInstallation extends CldrInstallation {

  final Iterable<String> missingDependencies = [];

  _MockCldrInstallation(String path)
      : super(path,
      httpClient: testResourcesHttpClient,
      runner: new MockRunner((command) => new MockProcessResult()));
}

class MockCldrInstallation extends Mock implements CldrInstallation {

  MockCldrInstallation(String path)
      : super.spy(new _MockCldrInstallation(path));
}
