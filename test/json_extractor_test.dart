// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.json_extractor_test;

import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:cldr/cldr.dart';
import 'package:cldr/src/data_set_impl.dart';
import '../bin/src/util.dart';

main() {

  group('JsonExtractor', () {

    JsonExtractor unit;

    // Expect the same dummy data for each type of DataSet for brevity
    // and to demonstrate the abstraction provided.
    void expectExtractionResult(DataSet dataSet) {

      var result = unit.extract(dataSet);

      expect(result, {
        "en": {
          "bar": 1
        },
        "ko": {
          "bar": 2
        }
      });
    }

    setUp(() {
      // Mock data is stored here:
      var mockLdml2JsonOut = join(testResources, 'ldml2json_out');
      unit = new JsonExtractor(mockLdml2JsonOut);
    });

    test('main', () {
      expectExtractionResult(new MainDataSet('foo'));
    });

    test('calendar', () {
      expectExtractionResult(new CalendarDataSet('foo'));
    });

    test('supplemental', () {
      expectExtractionResult(new SupplementalDataSet('foo'));
    });

  });
}
