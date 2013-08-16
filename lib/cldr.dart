// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Mechanisms to extract data from [Cldr].
///
/// It is a two step process:
///
/// 1.  Use [Ldml2Json] to convert Ldml data files to Json files.
///   * A convenience script for this is provided at:
///         <this package>/bin/ldml2json.dart
/// 2.  Use [JsonExtractor] to extract data from [Ldml2Json] output files.
///
/// [cldr]: http://cldr.unicode.org
library cldr;

import 'dart:io';
import 'dart:async';
import 'dart:json' as json;
import 'package:path/path.dart';
import 'src/util.dart';

part 'src/ldml2json.dart';
part 'src/json_extractor.dart';
