// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.cldr_installation_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:cli/cli.dart';
import 'package:cli/testing.dart';
import 'package:cldr/src/util.dart';
import 'package:cldr/cldr_installation.dart';

main() {

  group('CldrInstallation', () {

    Directory tempDir;
    String installDir;
    TestResourcesHttpClient mockClient;
    MockRunner mockRunner;
    CldrInstallation unit;

    setUp(() {
      tempDir = new Directory('').createTempSync();
      installDir = join(tempDir.path, 'cldr');
      mockClient = new TestResourcesHttpClient();
      mockRunner = new MockRunner((Command command) =>
          new MockProcessResult());
      unit = new CldrInstallation(
          installDir,
          httpClient: mockClient,
          runner: mockRunner);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('initially not installed', () => expect(unit, isNot(cldrIsInstalled)));

    group('install', () {

      test('requests bytes of each required zip', () {
        return unit.install().then((_){
          CldrInstallation.requiredZips.forEach((requiredZip) {
            var zip = "$requiredZip.zip";
            var isRequiredZip = predicate((zipUri) =>
                Uri.parse(zipUri).pathSegments.last == zip,
                'uri ending with "$zip"');
            mockClient.getLogs(
                callsTo('readBytes', isRequiredZip)).verify(happenedOnce);
          });
        });
      });

      test('runs ant build', () {
        return unit.install().then((_){
          CldrInstallation.requiredZips.forEach((requiredZip) {
            var zip = "$requiredZip.zip";
            var isAntCommand = predicate((command) =>
                command.executable == 'ant' &&
                orderedEquals(['clean', 'all']).matches(command.arguments, {}),
                'Cldr tools ant command');
            mockRunner.getLogs(
                callsTo('runSync', isAntCommand)).verify(happenedOnce);
          });
        });
      });
    });
  });
}

final cldrIsInstalled = new _CldrInstalledMatcher();
class _CldrInstalledMatcher extends Matcher {

  bool matches(item, Map matchState) => item.isInstalled;

  Description describe(Description description) =>
    description.add('Cldr is fully installed');

  Description describeMismatch(
      item,
      Description mismatchDescription,
      Map matchState,
      bool verbose) {
    var missingDependencies = item.missingDependencies;
    var depList = missingDependencies.map((dep) => '<$dep>').join(', ');
    mismatchDescription.add('Is missing dependencies: $depList');
    missingDependencies.forEach((dependency) {
      mismatchDescription.add('<$dependency>');
    });
    return mismatchDescription;
  }
}
