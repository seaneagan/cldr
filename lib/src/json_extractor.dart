// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cldr;

/// Mechanism to extract data from [Ldml2Json] output.
class JsonExtractor {

  static final logger = getLogger("cldr.JsonExtractor");

  /// Path to the root of the [Ldml2Json] output.
  final String jsonRoot;

  JsonExtractor(this.jsonRoot);

  /// Extracts parsed json from [Ldml2Json] output file(s) and returns it.
  Map<String, dynamic> extract(DataSet dataSet) => dataSet.extract(jsonRoot);
}

/// Represents a set of data within Cldr that can be extracted.
abstract class DataSet {
  Map<String, dynamic> extract(String jsonRoot);
}
