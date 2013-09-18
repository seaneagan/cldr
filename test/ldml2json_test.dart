// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.ldml2json_test;

import 'dart:io';
import 'package:meta/meta.dart';
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
      outPath = join(tempDir.path, 'out');
      configPath = join(testResources, 'ldml2json_config.txt');
      // Simulate existing output.
      existingFile = new File(join(outPath, 'supplemental', 'old.json'));
      createFileResursiveSync(existingFile);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('convert', () {

      MockRunner mockRunner;
      Ldml2Json unit;
      Directory out;

      setUp(() {
        ProcessResult mockLdml2JsonConverter(Command command) =>
            new MockProcessResult(
                stdout: 'Mock Ldml2JsonConverter stdout.',
                stderr: 'Mock Ldml2JsonConverter stderr.');
        mockRunner = new MockRunner(mockLdml2JsonConverter);

        unit = new Ldml2Json(
            new MockCldrInstallation(cldrPath),
            outPath,
            config: configPath,
            runner: mockRunner);

        out = unit.convert();
      });

      test('Ldml2JsonConverterCommands run for each Cldr subdirectory', () {

        isConvertCommand(String cldrSubdirectory) => predicate((command) {
          if(command is! Ldml2JsonConverterCommand) return false;
          command = command as Ldml2JsonConverterCommand;
          return
              command.cldrSubdirectory == cldrSubdirectory &&
              command.out == outPath &&
              command.config == configPath &&
              command.installation.path == cldrPath;
        }, "Ldml2JsonConverterCommand for '$cldrSubdirectory' "
           "Cldr subdirectory");

        Ldml2JsonConverterCommand.CLDR_SUBDIRECTORIES.forEach(
            (cldrSubdirectory) {
              mockRunner.getLogs(
                  callsTo('runSync', isConvertCommand(cldrSubdirectory)))
                  .verify(happenedOnce);
            });
      });

      test('Correct output directory returned', () {
        expect(out.path, outPath);
      });

      test('Existing output is deleted', () {
        expect(existingFile.existsSync(), isFalse);
      });
    });
  });

  group('Ldml2JsonConverterCommand', () {

    var outPath = 'out';
    var cldrSubdirectory = 'main';
    var config = 'foo.txt';
    Ldml2JsonConverterCommand unit;

    setUp(() {
      unit = new Ldml2JsonConverterCommand(
          new MockCldrInstallation(cldrPath),
          cldrSubdirectory,
          config,
          outPath);
    });

    group('classArguments', () {

      ArgResults results;

      setUp(() {
        // A partial parser to validate certain options are included.
        var parser = new ArgParser();
        var options = {
          'type': 't',
          'destdir': 'd',
          'resolved': 'r',
          'konfig': 'k'
        };
        options.forEach((option, abbr) => parser.addOption(option, abbr: abbr));
        results = parser.parse(unit.classArguments);
      });

      group('has valid option', () {
        test('--type', () =>
            expect(results, hasOption('type', cldrSubdirectory)));
        test('--destdir', () =>
            expect(results,
                hasOption('destdir', join(outPath, cldrSubdirectory))));
        test('--resolved', () =>
            expect(results, hasOption('resolved', 'true')));
        test('--konfig', () =>
            expect(results, hasOption('konfig', config)));
      });
    });
  });
}

/// Match an [ArgResults] containing an [option] matching [matcher].
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
      httpClient: new TestResourcesHttpClient(),
      runner: new MockRunner((command) => new MockProcessResult()));
}

@proxy
class MockCldrInstallation extends Mock implements CldrInstallation {

  MockCldrInstallation(String path)
      : super.spy(new _MockCldrInstallation(path));

  // TODO: Remove once http://dartbug.com/13410 is fixed.
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
