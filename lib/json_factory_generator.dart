/// JSON Factory Generator Library
/// 
/// This library provides automatic code generation for centralized JSON factories
/// that can parse JSON data into strongly-typed Dart objects.
/// 
/// ## Key Features
/// - **No forced dependencies**: Works with any class that has a `fromJson` method
/// - **Optional json_serializable support**: Works with or without `@JsonSerializable`
/// - **Type-safe**: Compile-time generation with runtime type safety
/// - **List support**: Handles `List<T>` parsing with proper generic types
/// 
/// ## Usage
/// 
/// 1. Add the `@jsonModel` annotation to your model classes:
/// 
/// ### Manual fromJson (No dependencies)
/// ```dart
/// @jsonModel
/// class User {
///   final String name;
///   
///   User({required this.name});
///   
///   factory User.fromJson(Map<String, dynamic> json) => User(
///     name: json['name'] as String,
///   );
/// }
/// ```
/// 
/// ### With json_serializable (Optional)
/// ```dart
/// @jsonModel
/// @JsonSerializable()
/// class User {
///   final String name;
///   
///   User({required this.name});
///   
///   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
/// }
/// ```
/// 
/// 2. Run code generation:
/// ```bash
/// dart run build_runner build
/// ```
/// 
/// 3. Use the generated JsonFactory:
/// ```dart
/// final user = JsonFactory.fromJson<User>(jsonData);
/// final users = JsonFactory.fromJson<List<User>>(jsonList);
/// ```
/// 
/// The library automatically discovers all annotated models with `fromJson` methods
/// and generates a centralized factory with type-safe parsing capabilities.
library json_factory_generator;

export 'src/annotations.dart';
export 'builder.dart';
