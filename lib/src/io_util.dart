// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This library contains things which aren't really specific to this package,
// but don't currently exist in any common libraries, and only work when
// 'dart:io' is available.
library cldr.io_util;

import 'dart:io';

/// Deletes all contents of a Directory synchronously.
void truncateDirectorySync(Directory directory) {
  directory.listSync().forEach(_deleteFileSystemEntitySync);
}

void _deleteFileSystemEntitySync(fse) {
  if(fse is Directory) {
    fse.deleteSync(recursive: true);
  } else if(fse is File || fse is Link) {
    fse.deleteSync();
  }
}
