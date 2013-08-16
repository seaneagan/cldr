// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cldr;

/// A wrapper around Cldr's [Ldml2JsonConverter][converter] tool.
///
/// Dependencies:
///
/// 1. [Cldr {tools,core}.zip][1] extracted to a single directory
/// 2. [java][2]
/// 3. [ant][3]
///
/// [converter]: http://cldr.unicode.org/index/downloads/cldr-23-1
/// [1]: http://unicode.org/Public/cldr/23.1
/// [2]: http://java.com
/// [3]: http://ant.apache.org
// TODO: Run processes synchronously when http://dartbug.com/1707 is fixed.
class Ldml2Json {

  var logger = getLogger('cldr.ldml2json');

  /// The path to the extracted {core,tools.zip} from Cldr.
  final String cldr;

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
  /// The returned Future completes with the output Directory.
  Future<Directory> convert() {
    return _checkDependencies().then((_) {

      // Normalize output directory to exist and be empty.
      var outDir = new Directory(out);
      if(outDir.existsSync()) {
        // Clean output directory.
        truncateDirectorySync(outDir);
      } else {
        // Create output directory.
        outDir.createSync(recursive: true);
      }

      return _runCldrToolsAntBuild().then((_) {
        // Run the java class for all relevant cldr subdirectories.
        return Future.forEach(_cldrSubdirectories, _runJavaClass)
            // Complete with the output directory.
            .then((_) => outDir);
      });
    });
  }

  /// Runs the Cldr tools ant build if necessary.
  Future _runCldrToolsAntBuild() => new Future(() {
    if(!new Directory(_javaClassesPath).existsSync()) {
      logger.info("Running the Cldr tools ant build");
      return Process.run(
            'ant',
            ['clean', 'all'],
            workingDirectory: _cldrJavaPath).then((_) => null);
    } else {
      return null;
    }
  });

  /// Runs the java class.
  _runJavaClass(String cldrSubdirectory) {
    var javaArgs = _getJavaArgs(
        _JAVA_CLASS_QUALIFIED_NAME,
        classPath: _classPath,
        systemProperties: {'CLDR_DIR' : cldr},
        classArgs: _getJavaClassArgs(cldrSubdirectory));

    logger.info('''Calling $_JAVA_CLASS_SIMPLE_NAME with command:
java ${javaArgs.join(' ')}''');

    return Process.run('java', javaArgs).then((ProcessResult result) {
      if(result.exitCode == 0) {
        logger.info(result.stdout);
      } else {
        logger.err(result.stderr);
      }
    });
  }

  /// The Cldr java path.
  String get _cldrJavaPath => join(cldr, "tools", "java");

  /// The Cldr java compiled classes path.
  String get _javaClassesPath => join(_cldrJavaPath, "classes");

  /// The java class path to use.
  String get _classPath => _getClassPath([
    _cldrJavaPath,
    _javaClassesPath,
    join(_cldrJavaPath, 'libs', '*')
  ]);

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
      // 1.
      ["tools", "common"].forEach((topZipDir) {
        if (!new Directory(join(cldr, topZipDir)).existsSync()) {
          var zip = topZipDir == "tools" ? "tools" : "core";
          throw new _MissingDependencyError(
              'extracted $zip.zip in --cldr dir: $cldr');
        }
      });
      return Future.forEach(
          [/* 2. */ 'java', /* 3. */ 'ant'], _assertCommandExists)
              ..then((_) => _dependenciesChecked = true);
    }
    return null;
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

/// Returns a class path consisting of [paths] using the platform dependent
/// class path separator.
String _getClassPath(Iterable<String> paths) => paths.join(_classPathSeparator);

/// The platform dependent separator of items in a java class path.
final String _classPathSeparator = Platform.isWindows ? ";" : ":";

/// Asynchronously assert that a given shell command exists.
Future _assertCommandExists(String command) {
  String commandChecker = Platform.isWindows ? 'where' : 'hash';
  return Process.run(commandChecker, [command]).then((ProcessResult result) {
    var exists = result.exitCode == 0;
    if(!exists) {
      throw new _MissingDependencyError('"$command" shell command');
    }
  });
}

/// Returns args to send to a java process.
List<String> _getJavaArgs(
    String javaClass, {
    String classPath,
    List<String> classArgs: const [],
    Map<String, String> systemProperties: const {}}) {

  var args = systemProperties.keys.map((key) =>
      '-D$key=${systemProperties[key]}')
      .toList();
  if(classPath != null) args.addAll(['-cp', classPath]);
  return args..add(javaClass)..addAll(classArgs);
}

/// Error thrown when an external dependency is missing.
class _MissingDependencyError extends Error {

  final String missingDependency;

  _MissingDependencyError(this.missingDependency);

  String toString() => 'Missing dependency: $missingDependency';
}
