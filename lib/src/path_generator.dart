
library cldr.path_generator;

import 'package:path/path.dart';

/// Defines a scheme for which paths to store and subsequently retrieve locale
/// data from.
class PathGenerator {

  /// The root path of locale data.
  final String root;

  /// A name for the type of data being output, used to construct
  /// a path relative to [root] to store the output.
  final String dataType;

  /// The filename extension to use for locale files.
  final String extension;

  PathGenerator(this.root, this.dataType, this.extension);

  String get dataTypePath => join(root, dataType);

  String getLocalePath(String locale) => join(dataTypePath, "$locale.$extension");
}
