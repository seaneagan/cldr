// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.zip_installer_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:cli/cli.dart';
import 'package:cli/testing.dart';
import 'package:cldr/src/zip_installer.dart';
import 'package:cldr/src/util.dart';

main() {

  group('ZipInstaller', () {

    Directory tempDir;
    String zipUri;
    String installDir;
    ZipInstaller unit;
    MockRunner mockRunner;
    TestResourcesHttpClient mockClient;

    setUp(() {
      tempDir = new Directory('').createTempSync();
      zipUri = 'http://example.com/mock.zip';
      installDir = join(tempDir.path, 'out');

      ProcessResult mockLdml2JsonConverter(Command command) =>
          new MockProcessResult();
      mockRunner = new MockRunner(mockLdml2JsonConverter);
      mockClient = new TestResourcesHttpClient();

      unit = new ZipInstaller(
          zipUri,
          installDir,
          httpClient: mockClient,
          runner: mockRunner);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('install', () {

      var mockZip = 'mock.zip';

      test('zip is deleted', () {
        return unit.install().then((_){

          var fileExists =
              predicate((file) => file.existsSync(), 'file exists');

          expect(new File(join(installDir, mockZip)),
              isNot(fileExists));
        });
      });

      test('extraction command is run', () {

        return unit.install().then((_){

          var isExtractionCommand = predicate((command) =>
              command.executable == 'jar' &&
              orderedEquals(['xf', mockZip]).matches(command.arguments, {}),
              'extraction Command for "$mockZip"');

          mockRunner.getLogs(
              callsTo('runSync', isExtractionCommand)).verify(happenedOnce);
        });
      });

      test('bytes are requested', () {
        return unit.install().then((_){
          var isMockZip = predicate((uri) =>
            Uri.parse(zipUri).pathSegments.last == mockZip,
            'uri ending with "$mockZip"');
        mockClient.getLogs(
            callsTo('readBytes', isMockZip)).verify(happenedOnce);
        });
      });
    });
  });
}
