// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.bin.ldml2json;

import 'dart:io';
import 'package:args/args.dart';
import 'package:cldr/cldr.dart';
import 'src/util.dart';

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
///                (defaults to "<cldr package>/third_party/cldr")
main() {

  // Define args.
  var parser = new ArgParser();
  addHelp(parser);
  parser.addOption(
      'out',
      help: '''The path in which to output the data.
(defaults to "<this_package>/third_party/cldr/json")''');
  parser.addOption(
      'config',
      help: 'The path to the Ldml2JsonConverter config file.');
  parser.addOption(
      'cldr',
      help: '''The path to the extracted tools.zip and core.zip from Cldr.
(defaults to "<this_package>/third_party/cldr")''');

  // Process args.
  var results = parser.parse(new Options().arguments);
  if(results['help']) {
    print(fullUsage(parser, description: 'Converts Ldml data to Json.'));
    return;
  }
  var out = results['out'];
  if(out == null) {
    out = cldrJson;
  }
  var config = results['config'];
  var cldr = results['cldr'];
  if(cldr == null) {
    cldr = cldrInstall;
  }

  new Ldml2Json(cldr, out, config).convert();
}
