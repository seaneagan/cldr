// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.ldml2json;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:cldr/cldr.dart';

/// Converts Ldml data to Json.
///
/// Usage:
///
///     dart ldml2json.dart [options]
///
/// Options:
///
/// --help         Print this usage information.
/// --out          The path in which to output the data.
/// --config       The path to the Ldml2JsonConverter config file.
/// --cldr         The path to the extracted tools.zip and core.zip from Cldr.
///                Defaults to <cldr package>/third_party/cldr.
main() {

  var options = new Options();

  // Define args.
  var parser = new ArgParser();
  parser.addFlag(
      'help',
      help: 'Print this usage information.', negatable: false);
  parser.addOption(
      'out',
      help: 'The path in which to output the data.');
  parser.addOption(
      'config',
      help: 'The path to the Ldml2JsonConverter config file.');
  parser.addOption(
      'cldr',
      help: '''The path to the extracted tools.zip and core.zip from Cldr.
Defaults to <cldr package>/third_party/cldr.''');

  // Process args.
  var results = parser.parse(options.arguments);

  if(results['help']) {
    _usage(parser);
    return;
  }

  var out = results['out'];
  var config = results['config'];
  var cldr = results['cldr'];
  if(cldr == null) {
    cldr = join(dirname(options.script), '..', 'third_party', 'cldr');
  }

  new Ldml2Json(cldr, out, config).convert();
}

void _usage(ArgParser parser) {
  print('''

Converts Ldml data to Json.

Usage:

  dart ldml2json.dart [options]

Options:

${parser.getUsage()}''');
}
