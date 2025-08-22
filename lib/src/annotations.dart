import 'package:meta/meta.dart';

/// Annotation for marking a class to be included in the auto-generated JsonFactory.
///
/// Use this annotation to automatically register your model class in the
/// centralized JsonFactory for type-safe JSON parsing.
///
/// The JsonFactory generator will scan all files for classes with this annotation
/// and create a centralized factory that can parse JSON into your model instances.
///
/// ## Requirements:
/// - The class must have a `fromJson(Map<String, dynamic>)` factory constructor
/// - The file must include `part 'filename.g.dart';` directive (if using json_serializable)
///
/// ## Example:
/// ```dart
/// import 'package:json_factory_generator/json_factory_generator.dart';
///
/// @jsonModel
/// class User {
///   final String name;
///   final int age;
///
///   User({required this.name, required this.age});
///
///   factory User.fromJson(Map<String, dynamic> json) => User(
///     name: json['name'] as String,
///     age: json['age'] as int,
///   );
///
///   Map<String, dynamic> toJson() => {
///     'name': name,
///     'age': age,
///   };
/// }
/// ```
///
/// ## With json_serializable (optional):
/// ```dart
/// import 'package:json_annotation/json_annotation.dart';
/// import 'package:json_factory_generator/json_factory_generator.dart';
///
/// part 'user.g.dart';
///
/// @jsonModel
/// @JsonSerializable()
/// class User {
///   final String name;
///   final int age;
///
///   User({required this.name, required this.age});
///
///   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
///   Map<String, dynamic> toJson() => _$UserToJson(this);
/// }
/// ```
///
/// After running `dart run build_runner build`, you can use:
/// ```dart
/// final user = JsonFactory.fromJson<User>(jsonMap);
/// final users = JsonFactory.fromJson<List<User>>(jsonList);
/// ```
@immutable
class JsonModel {
  /// Creates a new JsonModel annotation instance.
  ///
  /// This annotation has no configuration options - simply add `@jsonModel`
  /// to any class that should be included in the generated JsonFactory.
  const JsonModel();
}

/// Constant instance of [JsonModel] annotation.
///
/// Use this to mark your model classes for inclusion in the JsonFactory:
/// ```dart
/// @jsonModel
/// @JsonSerializable()
/// class YourModel { ... }
/// ```
const jsonModel = JsonModel();
