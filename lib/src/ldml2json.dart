// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cldr;

/// A wrapper around Cldr's [Ldml2JsonConverter][converter] tool.
///
/// ## Dependencies:
///
/// * An installation of the [Cldr core and tools][cldr_downloads],
///   use <this_package>/bin/install_cldr.dart to get this.
/// * [java]
///
/// [converter]: http://unicode.org/cldr/trac/browser/tags/latest/tools/java/org/unicode/cldr/json/Ldml2JsonConverter.java
/// [cldr_downloads]: http://unicode.org/Public/cldr/latest
/// [java]: http://java.com
class Ldml2Json {

  var _logger = getLogger('cldr.Ldml2json');

  /// The path to the Cldr core and tools installation.
  final String cldr;

  CldrInstallation _installation;
  CldrInstallation get installation {
    if(_installation == null) _installation = new CldrInstallation(cldr);
    return _installation;
  }

  /// The output directory path.
  final String out;

  /// The Ldml2JsonConverter config file path.
  final String config;

  /// The java class qualified name.
  static final _JAVA_CLASS_QUALIFIED_NAME =
      'org.unicode.cldr.json.$_JAVA_CLASS_SIMPLE_NAME';

  /// The java class qualified name.
  static final _JAVA_CLASS_SIMPLE_NAME = 'Ldml2JsonConverter';

  Ldml2Json(this.cldr, this.out, [this.config]);

  /// Converts Ldml data to Json.
  ///
  /// Returns the output Directory.
  Directory convert() {

    _checkDependencies();

    var outDir = new Directory(out);

    // Remove any existing output.
    cleanDirectorySync(outDir);

    // Run the java class for all relevant cldr subdirectories.
    _cldrSubdirectories.forEach(_runJavaClass);

    return outDir;
  }

  /// Runs the java class.
  _runJavaClass(String cldrSubdirectory) {
    var javaArgs = getJavaArgs(
        _JAVA_CLASS_QUALIFIED_NAME,
        classPath: installation.classPath,
        systemProperties: {'CLDR_DIR' : cldr},
        classArgs: _getJavaClassArgs(cldrSubdirectory));

    _logger.info('''Calling $_JAVA_CLASS_SIMPLE_NAME with command:
java ${javaArgs.join(' ')}''');

    var result = Process.runSync('java', javaArgs);
    if(result.exitCode == 0) {
      _logger.info(result.stdout);
    } else {
      _logger.err(result.stderr);
    }
  }

  /// The args to pass to the java class.
  ///
  /// Description from README in http://unicode.org/Public/cldr/23.1/json.zip:
  ///
  /// Usage: Ldml2JsonConverter [OPTIONS] [FILES]
  /// This program converts CLDR data to the JSON format.
  /// Please refer to the following options.
  ///         example: org.unicode.cldr.json.Ldml2JsonConverter -c xxx -d yyy
  /// Here are the options:
  /// -h (help)       no-arg  Provide the list of possible options
  /// -c (commondir)  .*      Common directory for CLDR files, defaults to CldrUtility.COMMON_DIRECTORY
  /// -d (destdir)    .*      Destination directory for output files, defaults to CldrUtility.GEN_DIRECTORY
  /// -m (match)      .*      Regular expression to define only specific locales or files to be generated
  /// -t (type)       (main|supplemental)     Type of CLDR data being generated, main or supplemental.
  /// -r (resolved)   (true|false)    Whether the output JSON for the main directory should be based on resolved or unresolved data
  /// -s (draftstatus)        (approved|contributed|provisional|unconfirmed)  The minimum draft status of the output data
  /// -l (coverage)   (minimal|basic|moderate|modern|comprehensive|optional)  The maximum coverage level of the output data
  /// -n (fullnumbers)        (true|false)    Whether the output JSON should output data for all numbering systems, even those not used in the locale
  /// -o (other)      (true|false)    Whether to write out the 'other' section, which contains any unmatched paths
  /// -k (konfig)     .*      LDML to JSON configuration file
  List<String> _getJavaClassArgs(String cldrSubdirectory) {
    var args = [
      // The 'supplemental' directory is added automatically.
      '-d', cldrSubdirectory == 'main' ? join(out, cldrSubdirectory) : out,
      '-t', cldrSubdirectory,
      '-r', 'true'
    ];
    if(config != null) {
      args.addAll(['-k', config]);
    }
    return args;
  }

  /// Check dependencies.
  Future _checkDependencies() => new Future(() {
    if(!_dependenciesChecked) {
      installation.assertInstalled();
      assertCommandExists('java');
      _dependenciesChecked = true;
    }
  });

  /// Whether dependencies have been checked yet.
  bool _dependenciesChecked = false;

  /// The Cldr subdirectories from which to run the java class.
  Iterable<String> get _cldrSubdirectories {
    // The default config contains all data.
    var subdirs = ['main', 'supplemental'];

    if(config != null) {
      // Scan custom configs for subdirectory references.
      var configContent = new File(config).readAsStringSync();
      subdirs = subdirs.where((subdir) =>
          configContent.contains('//cldr/$subdir'));
    }
    return subdirs;
  }
}
