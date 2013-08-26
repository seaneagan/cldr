// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.zip_installer_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:cldr/src/zip_installer.dart';
import 'package:http/testing.dart';
import 'package:cldr/src/util.dart';

main() {

  group('ZipInstaller', () {

    Directory tempDir;
    String zipUri;
    String installDir;
    ZipInstaller unit;

    setUp(() {
      tempDir = new Directory('').createTempSync();
      zipUri = 'http://example.com/mock.zip';
      installDir = join(tempDir.path, 'out');
      unit = new ZipInstaller(
          zipUri,
          installDir,
          httpClient: new MockClient(testResourcesHandler));
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('main', () {

      unit.install();

      var fileExists = predicate((file) => file.existsSync(), 'file exists');

      expect(
          new File(join(installDir, 'mock.zip')),
          isNot(fileExists));

      expect(
          new File(join(installDir, 'README')),
          fileExists);
    });
  });
}
