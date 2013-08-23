
library cldr.zip_installer;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:cldr/src/util.dart';

/// Installs zip files from the network to the local file system.
class ZipInstaller {

  static final logger = getLogger('ZipInstaller');

  /// The Uri of the zip file to install.
  final String zipUri;

  /// The directory path at which to install the zip.
  final String installDir;

  /// The [basename] of the zip file.
  String get _zipBasename {
    if(__zipBasename == null) __zipBasename = basename(zipUri);
    return __zipBasename;
  }
  String __zipBasename;

  String get _zipPath => join(installDir, _zipBasename);

  ZipInstaller(this.zipUri, this.installDir);

  /// Installs [zipUri] to [installDir].
  ///
  /// Downloads, writes, extracts, and deletes the zip.
  Future install() =>
      _download()
      .then(_write)
      .then((_) => _extract())
      .then((_) => _delete());

  Future<List<int>> _download() {
    logger.info("Downloading '$_zipBasename'");
    return http.readBytes(zipUri);
  }

  Future _write(List<int> bytes) {
    logger.info("Writing '$_zipBasename' to '$installDir'");
    var zipFile = new File(_zipPath);
    zipFile.directory.createSync(recursive: true);
    zipFile.writeAsBytesSync(bytes);
  }

  Future _extract() {
    logger.info("Extracting '$_zipBasename' to '$installDir'");
    return Process.run(
        'jar',
        ['xf', _zipBasename],
        workingDirectory: installDir)
        .then((_) => null);
  }

  Future _delete() {
    logger.info("Deleting '$_zipBasename' from '$installDir'");
    new File(_zipPath).deleteSync();
  }

}
