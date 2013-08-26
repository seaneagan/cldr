// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.util;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:cldr/src/util.dart';

/// The default path in which to install Cldr core and tools.
///
/// This path is .gitignore'd so that The Cldr installation doesn't get
/// committed to source control.
final defaultCldrInstallPath = join(packageRoot, 'third_party', 'cldr');

/// The default Ldml2Json output path.
final defaultLdml2JsonOutputPath = join(defaultCldrInstallPath, 'json');

/// Returns full usage text for the current dart script,
/// including a [description].
String getFullUsage(ArgParser parser, {String description: ''}) {

  if(description.isNotEmpty) {
    description = '''$description
''';
  }

  return '''

$description
Usage:

    dart ${basename(new Options().script)} [options]

Options:

${parser.getUsage()}''';
}

/// Adds a standard help option to [parser].
void addHelp(ArgParser parser) {
  parser.addFlag(
      'help',
      help: 'Print this usage information.', negatable: false);
}
