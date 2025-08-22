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

/// Constant instance of [JsonModel] annotation
const jsonModel = JsonModel();
