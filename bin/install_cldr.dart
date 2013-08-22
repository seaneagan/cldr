// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.install_cldr;

import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'src/util.dart';
import 'src/zip_installer.dart';

/// Installs Cldr zips needed by Ldml2Json.
///
/// Usage:
///
///     dart install_cldr.dart [options]
///
/// Options:
///
/// --help       Print this usage information.
/// --path       The path at which to install Cldr.
///              (defaults to "<cldr package>/third_party/cldr")

/// --version    The Cldr version to install.
///              (defaults to "latest")
main() {

  // Define args.
  var parser = new ArgParser();
  addHelp(parser);
  parser.addOption(
      'path',
      help: '''The path at which to install Cldr.
(defaults to "<this_package>/third_party/cldr")''');
  parser.addOption(
      'version',
      help: 'The Cldr version to install.',
      defaultsTo: _cldrLatest);

  // Process args.
  var results = parser.parse(new Options().arguments);
  if(results['help']) {
    print(fullUsage(parser, description:
        'Installs Cldr zips needed by Ldml2Json.'));
    return;
  }
  var path = results['path'];
  if(path == null) path = cldrInstall;
  var version = results['version'];

  _installCldr(version, path);
}

_installCldr(String version, String path) {
  var zips = ['core', 'tools'].map((zip) => _getCldrZipUri(version, zip));
  Future.forEach(zips, (zip) => new ZipInstaller(zip, path).install());
}

// TODO: Use correct method to concat Uri pieces.
String _getCldrZipUri(String version, String zip) => _cldrDownloadRoot + version + '/' + '$zip.zip';

/// The [latest][cldr_latest] Cldr version.
/// [cldr_latest]: http://cldr.unicode.org/index/downloads/latest
String _cldrLatest = 'latest';

/// The Cldr download root.
final String _cldrDownloadRoot = 'http://www.unicode.org/Public/cldr/';
