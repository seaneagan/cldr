// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exposes [DataSet]s which can be extracted from Cldr.
library cldr.data_sets;

import 'package:cldr/cldr.dart';
import 'package:cldr/src/data_set_impl.dart';

final DataSet caBuddhist = new CalendarDataSet('buddhist');

final DataSet caChinese = new CalendarDataSet('chinese');

final DataSet caCoptic = new CalendarDataSet('coptic');

final DataSet caEthiopic = new CalendarDataSet('ethiopic');

final DataSet caEthiopicAmeteAlem = new CalendarDataSet('ethiopic-amete-alem');

final DataSet caGregorian = new CalendarDataSet('gregorian');

final DataSet caHebrew = new CalendarDataSet('hebrew');

final DataSet caIndian = new CalendarDataSet('indian');

final DataSet caIslamic = new CalendarDataSet('islamic');

final DataSet caIslamicCivil = new CalendarDataSet('islamic-civil');

final DataSet caJapanese = new CalendarDataSet('japanese');

final DataSet caPersian = new CalendarDataSet('persian');

final DataSet caRoc = new CalendarDataSet('roc');

final DataSet calendarData = new SupplementalDataSet('calendarData');

final DataSet calendarPreferenceData = new SupplementalDataSet('calendarPreferenceData');

final DataSet characterFallbacks = new SupplementalDataSet('characterFallbacks');

final DataSet characters = new MainDataSet('characters');

final DataSet codeMappings = new SupplementalDataSet('codeMappings');

final DataSet currencies = new MainDataSet('currencies');

final DataSet currencyData = new SupplementalDataSet('currencyData');

final DataSet dayPeriods = new SupplementalDataSet('dayPeriods');

final DataSet delimiters = new MainDataSet('delimiters');

final DataSet languageData = new SupplementalDataSet('languageData');

final DataSet languageMatching = new SupplementalDataSet('languageMatching');

final DataSet languages = new MainDataSet('languages');

final DataSet layout = new MainDataSet('layout');

final DataSet likelySubtags = new SupplementalDataSet('likelySubtags');

final DataSet listPatterns = new MainDataSet('listPatterns');

final DataSet localeDisplayNames = new MainDataSet('localeDisplayNames');

final DataSet measurementData = new SupplementalDataSet('measurementData');

final DataSet measurementSystemNames = new MainDataSet('measurementSystemNames');

final DataSet metaZones = new SupplementalDataSet('metaZones');

final DataSet numberingSystems = new SupplementalDataSet('numberingSystems');

final DataSet numbers = new MainDataSet('numbers');

final DataSet parentLocales = new SupplementalDataSet('parentLocales');

final DataSet plurals = new SupplementalDataSet('plurals');

final DataSet posix = new MainDataSet('posix');

final DataSet postalCodeData = new SupplementalDataSet('postalCodeData');

final DataSet references = new SupplementalDataSet('references');

final DataSet scripts = new MainDataSet('scripts');

final DataSet telephoneCodeData = new SupplementalDataSet('telephoneCodeData');

final DataSet territories = new MainDataSet('territories');

final DataSet territoryContainment = new SupplementalDataSet('territoryContainment');

final DataSet territoryInfo = new SupplementalDataSet('territoryInfo');

final DataSet timeZoneNames = new MainDataSet('timeZoneNames');

final DataSet units = new MainDataSet('units');

final DataSet variants = new MainDataSet('variants');

final DataSet weekData = new SupplementalDataSet('weekData');

final DataSet windowsZones = new SupplementalDataSet('windowsZones');
