// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.install_cldr;

import 'dart:io';
import 'package:args/args.dart';
import 'src/util.dart';
import 'package:cldr/cldr_installation.dart';
import 'package:cldr/cldr.dart';

/// Installs Cldr core and tools needed by [Ldml2Json].
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
      defaultsTo: CldrInstallation.latestVersion);

  // Process args.
  var results = parser.parse(new Options().arguments);
  if(results['help']) {
    print(getFullUsage(parser, description:
        'Installs Cldr zips needed by Ldml2Json.'));
    return;
  }
  var path = results['path'];
  if(path == null) path = defaultCldrInstallPath;
  var version = results['version'];

  new CldrInstallation(path).install(version);
}
