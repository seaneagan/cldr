
library cldr.bin.zip_installer;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:cldr/src/util.dart';

class ZipInstaller {

  static final logger = getLogger('ZipInstaller');

  final String zipUri;
  final String installDir;

  String get zipBasename {
    if(_zipBasename == null) _zipBasename = basename(zipUri);
    return _zipBasename;
  }
  String _zipBasename;

  String get targetUri {
    if(_targetUri == null) _targetUri = dirname(zipUri);
    return _targetUri;
  }
  String _targetUri;


  String get zipPath => join(installDir, zipBasename);

  ZipInstaller(this.zipUri, this.installDir);

  /// Install the zip file.
  ///
  /// Downloads, writes, extracts, and deletes the file.
  Future install() => _download()
        .then(_write)
        .then((_) => _extract())
        .then((_) => _delete());

  Future<List<int>> _download() {
    logger.info("Downloading '$zipBasename'");
    return http.readBytes(zipUri);
  }

  Future _write(List<int> bytes) {
    logger.info("Writing '$zipBasename' to '$installDir'");
    var zipFile = new File(zipPath);
    zipFile.directory.createSync(recursive: true);
    zipFile.writeAsBytesSync(bytes);
  }

  Future _extract() {
    logger.info("Extracting '$zipBasename' to '$installDir'");
    return Process.run(
        'jar',
        ['xf', zipBasename],
        workingDirectory: installDir)
        .then((_) => null);
  }

  Future _delete() {
    logger.info("Deleting '$zipBasename' from '$installDir'");
    new File(zipPath).deleteSync();
  }

}
