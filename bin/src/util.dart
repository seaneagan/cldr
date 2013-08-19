
library cldr.bin.util;

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';

final cldr_install = join(_packageRoot, 'third_party', 'cldr');

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
