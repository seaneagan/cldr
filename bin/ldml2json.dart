
import 'dart:io';
import 'package:args/args.dart';
import 'package:cldr/src/ldml2json.dart';

/// A wrapper around the Ldml2JsonConverter tool.
///
/// Usage:
///
///     dart ldml2json.dart --cldr [cldr] --out [out]
///     dart ldml2json.dart --cldr [cldr] --out [out] --config [config]
///
/// cldr -
/// out - []
/// config - [Ldml2JsonConverter config path]
///
///
///
/// This depends on [Ldml2JsonConverter][1] which further depends on [java][2] and [ant][3].
/// WARNING: This script will delete all existing files in --out.
///
main() {

  // Define args.
  var parser = new ArgParser();
  parser.addOption(
      'cldr',
      help: 'The path to the extracted tools.zip and core.zip from Cldr');
  parser.addOption(
      'out',
      help: 'The path in which to output the data');
  parser.addOption(
      'config',
      help: 'The path to the Ldml2JsonConverter config file');

  // Process args.
  var results = parser.parse(new Options().arguments);
  var cldr = results['cldr'];
  var out = results['out'];
  var config = results['config'];

  new Ldml2Json(cldr, out, config).convert();
}
