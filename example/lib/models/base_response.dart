import 'package:example/generated/json_factory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// A type-safe wrapper for API responses that handles common response fields.
///
/// Features:
/// - Generic type [T] for flexible data payload
/// - Built-in success/failure status
/// - Standard message field for user feedback
/// - Optional status code for HTTP responses
/// - Automatic JSON serialization/deserialization
/// - Null-safety support for the data field
///
/// Example:
/// ```dart
/// final response = BaseResponse<User>.fromJson(
///   jsonMap,
///   (json) => User.fromJson(json as Map<String, dynamic>),
/// );
/// 
/// if (response.success) {
///   final user = response.data;  // Type-safe User object
/// }
/// ```
@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  final bool success;
  final String message;
  @DataConverter()
  final T? data;
  final int? code;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  /// Creates a [BaseResponse] instance from a JSON Map.
  /// 
  /// Parameters:
  /// - [json]: The JSON map containing response data
  /// - [fromJsonT]: A function that converts JSON to type [T]
  /// 
  /// The [fromJsonT] parameter is typically a model's fromJson constructor or
  /// JsonFactory.fromJson for complex types.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);

  /// Generated toJson with generic type support
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'BaseResponse(success: $success, message: $message, data: $data, code: $code)';
  }
}

/// A JSON converter that uses [JsonFactory] to handle complex type conversions.
///
/// This converter automatically handles:
/// - Null values
/// - Single objects of type [T]
/// - Lists of type [T]
/// - Nested generic types
///
/// Used internally by [BaseResponse] to convert the data field.
class DataConverter<T> implements JsonConverter<T?, Object?> {
  const DataConverter();

  @override
  T? fromJson(Object? json) {
    return JsonFactory.fromJson(json);
  }

  @override
  Object? toJson(T? object) {
    return object;
  }
}
