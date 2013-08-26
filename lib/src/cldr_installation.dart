// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.cldr_installation;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:cldr/src/zip_installer.dart';
import 'package:cldr/src/util.dart';

/// Represents an installation of the [Cldr core and tools][cldr_downloads].
/// [cldr_downloads]: http://unicode.org/Public/cldr/latest
class CldrInstallation {

  static final _logger = getLogger('CldrInstallation');

  /// The path of this Cldr installation.
  final String path;

  /// The path of the java source files.
  String get javaPath => join(path, "tools", "java");

  /// The path of the compiled java classes.
  String get javaClassesPath => join(javaPath, "classes");

  /// The class path to when running java tools.
  String get classPath => getClassPath([
    javaPath,
    javaClassesPath,
    join(javaPath, 'libs', '*')
  ]);

  CldrInstallation(this.path);

  /// Installs the specified [version] of Cldr.
  ///
  /// This requires having [ant][ant] and [jar][jar] on the PATH.
  /// [ant]: http://ant.apache.org
  /// [jar]:
  install([String version = latestVersion]) {

    assertCommandExists('ant');

    /// Remove any existing installation.
    cleanDirectorySync(new Directory(path));

    var zipUris = _zips.map((zip) => _getCldrZipUri(version, zip));
    Future.forEach(zipUris, (zipUri) =>
        new ZipInstaller(zipUri, path).install())
    .then((_) => _runAntBuild());
  }

  /// Assert that Cldr is installed properly at [path].
  assertInstalled() {
    _zips.forEach((topZipDir) {
      if (!new Directory(join(path, topZipDir)).existsSync()) {
        throw new MissingDependencyError(
            'extracted $topZipDir.zip in cldr installation path: $path');
      }
    });

    if(!new Directory(javaClassesPath).existsSync()) {
      throw new MissingDependencyError(
          'Cldr tools ant build output');
    }
  }

  /// Runs the Cldr tools ant build.
  _runAntBuild() {
    _logger.info("Running the Cldr tools ant build");
    Process.runSync(
        'ant',
        ['clean', 'all'],
        workingDirectory: javaPath);
  }

  /// The Cldr zips which must be installed.
  static final _zips = ['core', 'tools'];

  /// The [latest] Cldr version.
  /// [latest]: http://cldr.unicode.org/index/downloads/latest
  static const latestVersion = 'latest';

  /// Returns the download uri of a Cldr [zip] with [version].
  static String _getCldrZipUri(String version, String zip) =>
      '$_cldrDownloadRoot/$version/$zip.zip';

  /// The Cldr download root.
  static final _cldrDownloadRoot = 'http://www.unicode.org/Public/cldr';
}
