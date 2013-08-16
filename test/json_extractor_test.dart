// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.test.ldml2json_test;

import 'dart:io';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:cldr/cldr.dart';

main() {

  group('JsonExtractor', () {

    void expectExtractionResult(Map<String, dynamic> result) {
      expect(result, {
        "en": {
          "bar": 1
        },
        "ko": {
          "bar": 2
        }
      });
    }

    Directory tempDir;
    String jsonRoot;

    setUp(() {
      tempDir = new Directory('').createTempSync();
      jsonRoot = join(tempDir.path, 'json');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('main', () {

      _writeFileSync(
          join(jsonRoot, 'main', 'en', 'foo.json'),
          r'''
{
  "main": {
    "en": {
      "identity": {
        "version": {
          "@cldrVersion": "23.1",
          "@number": "$Revision: 5806 $"
        },
        "generation": {
          "@date": "$Date: 2011-05-02 13:42:02 -0500 (Mon, 02 May 2011) $"
        },
        "language": "en"
      },
      "foo": {
        "bar": 1
      }
    }
  }
}
''');

      _writeFileSync(
          join(jsonRoot, 'main', 'ko', 'foo.json'),
          r'''
{
  "main": {
    "ko": {
      "identity": {
        "version": {
          "@cldrVersion": "23.1",
          "@number": "$Revision: 5806 $"
        },
        "generation": {
          "@date": "$Date: 2011-05-02 13:42:02 -0500 (Mon, 02 May 2011) $"
        },
        "language": "ko"
      },
      "foo": {
        "bar": 2
      }
    }
  }
}
''');

      var extractor = new JsonExtractor.main(jsonRoot, 'foo');
      expectExtractionResult(extractor.extract());
    });

    test('supplemental', () {

      _writeFileSync(
          join(jsonRoot, 'supplemental', 'foo.json'),
          r'''
{
  "supplemental": {
    "version": {
      "@cldrVersion": "23.1",
      "@number": "$Revision: 5817 $"
    },
    "generation": {
      "@date": "$Date: 2011-05-03 10:12:08 -0500 (Tue, 03 May 2011) $"
    },
    "foo": {
      "en": {
        "bar": 1
      },
      "ko": {
        "bar": 2
      }
    }
  }
}''');

      var extractor = new JsonExtractor.supplemental(jsonRoot, 'foo');
      expectExtractionResult(extractor.extract());

    });
  });
}

void _writeFileSync(String path, String contents) {
  var file = new File(path);
  file.directory.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
