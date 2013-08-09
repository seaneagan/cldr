// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cldr.cldr_json;

import 'dart:io';
import 'dart:json' as json;
import 'package:unittest/matcher.dart';
import 'package:cldr/src/util.dart';
import 'package:cldr/src/io_util.dart';
import 'package:cldr/src/path_generator.dart';
import 'package:cldr/src/json_extractor.dart';

/// Transforms data for a given locale as necessary.  The default
/// implementation just passes the data through without transformation.
typedef CldrJsonTransformer(String locale, var jsonStructure);

class JsonProcessor {

  static var logger = getLogger("cldr.JsonProcessor");

  final JsonExtractor extractor;

  final CldrJsonTransformer transformer;

  final PathGenerator pathGenerator;

  JsonProcessor(
      this.extractor,
      this.pathGenerator,
      [this.transformer = _transformPassthrough]);

  /// Extracts, transforms, and stores locale data.
  process() {
    logger.info('=== Build ${pathGenerator.dataType} data ===');
    var extracted = new LogStep(logger, "extract locale data from CLDR")
        .execute(extractor.extract);
    var transformed = new LogStep(logger, "transform locale data")
        .execute(() => _transform(extracted));
    new LogStep(logger, "store locale data")
        .execute(() => _store(transformed));
  }

  /// Performs [transformJson] for each supported locale, and returns a
  /// Map of transformed locale data.
  _transform(Map<String, dynamic> localeJsonMap) {
    var transformedData = localeJsonMap.keys.fold({}, (map, locale) {
      var transformedJson = transformer(locale, localeJsonMap[locale]);
      logger.fine("""transformed locale data for '$locale' was:
$transformedJson""");
      map[locale] = transformedJson;
      return map;
    });

    // Remove any subtags which have identical data as their base tag.
    //
    // This minimizes the amount of data that needs to be loaded
    // when supporting multiple (or all) locales.  This is necessary since
    // our Ldml2JsonConverter output, uses the default -r (resolved) option,
    // which introduces duplication between tag and subtag.  Ldml2JsonConverter
    // also supports unresolved data (-r false), but it's much easier to
    // implement de-duplication here, than subtag data resolution.
    transformedData = transformedData.keys.fold({}, (map, String locale) {
      var localeData = transformedData[locale];
      var baseTag = baseLocale(locale);
      var keepData = true;
      if(baseTag != locale) {
        var baseTagData = transformedData[baseTag];
        var matcher = equals(baseTagData);
        var matchState = {};
        if(matcher.matches(localeData, matchState)) {
          logger.info("Removing data for '$locale' as it's identical to "
              "that of it's base tag '$baseTag'");
          keepData = false;
        } else {
          var description = matcher.describeMismatch(
              localeData, new StringDescription(), matchState, true);
          logger.info("Retaining data for '$locale' as it's different than "
              """that of it's base tag '$baseTag' as follows:
$description""");
        }
      }
      if(keepData) {
        map[locale] = localeData;
      }
      return map;
    });

    // Stringify remaining data.
    transformedData.forEach((locale, data) {
      transformedData[locale] = json.stringify(data);
    });

    return transformedData;
  }

  /// Store the transformed data into the local file system for later usage.
  void _store(Map<String, String> localeJsonMap) {

    // Delete existing files.
    truncateDirectorySync(new Directory(pathGenerator.dataTypePath));

    // Store new files.
    localeJsonMap.forEach((locale, json){
      var localePath = pathGenerator.getLocalePath(locale);
      var dataFile = new File(localePath);
      logger.fine("storing data for locale '$locale' in '$localePath'");
      dataFile.writeAsStringSync(json);
    });
  }

  static _transformPassthrough(String locale, var jsonObject) => jsonObject;
}
