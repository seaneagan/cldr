// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.util;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';

final cldrInstall = join(_packageRoot, 'third_party', 'cldr');

final cldrJson = join(cldrInstall, 'json');

final _packageRoot = join(dirname(new Options().script), '..');

String fullUsage(ArgParser parser, {String description: ''}) {

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

void addHelp(ArgParser parser) {
  parser.addFlag(
      'help',
      help: 'Print this usage information.', negatable: false);
}
