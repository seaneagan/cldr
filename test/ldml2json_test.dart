// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.ldml2json_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:cldr/cldr.dart';
import '../bin/src/util.dart';

main() {

  group('Ldml2Json', () {

    Directory tempDir;
    String outPath;
    String configPath;
    File existingFile;
    // Cldr must be installed at this default path before running this test!
    final cldrPath = defaultCldrInstallPath;

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
      existingFile.directory.createSync(recursive: true);
      existingFile.createSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('basic', () {

      var unit = new Ldml2Json(cldrPath, outPath, configPath);

      var out = unit.convert();

      void expectOutputFile(File file, String cldrSubdirectory) {
        expect(file, predicate(
            (file) => file.existsSync(),
            "Output files under '$cldrSubdirectory' is created"));
      }

      expect(
          out.path,
          outPath,
          reason: 'Correct output directory is returned');

      expectOutputFile(
          new File(join(outPath, 'main', 'en', 'units.json')),
          'main');

      expectOutputFile(
          new File(join(outPath, 'supplemental', 'plurals.json')),
          'supplemental');

      expect(existingFile, predicate(
          (file) => !file.existsSync(),
          "Existing files are removed"));
    });
  });
}
