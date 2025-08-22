import 'package:meta/meta.dart';

/// Annotation for marking a class as a JSON-serializable model.
///
/// Use this annotation along with @JsonSerializable to enable
/// automatic JSON factory generation for a class.
///
/// Example:
/// ```dart
/// @jsonModel
/// @JsonSerializable()
/// class User {
///   final String name;
///   final int age;
///
///   User({required this.name, required this.age});
/// }
/// ```
@immutable
class JsonModel {
  /// Creates a new JsonModel annotation instance
  const JsonModel();
}

/// Annotation for initializing the JsonFactory configuration.
///
/// This annotation should be used on a top-level function that
/// will serve as the initialization point for the JsonFactory.
///
/// Example:
/// ```dart
/// @jsonFactoryInit
/// void initializeJsonFactory() {}
/// ```
@immutable
class JsonFactoryInit {
  /// Creates a new JsonFactoryInit annotation instance
  const JsonFactoryInit();
}

/// Constant instance of [JsonModel] annotation
const jsonModel = JsonModel();

/// Constant instance of [JsonFactoryInit] annotation
const jsonFactoryInit = JsonFactoryInit();
