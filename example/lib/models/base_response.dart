import 'package:example/generated/json_factory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// Generic API response wrapper with JsonSerializable
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

  /// Generated fromJson with generic type support
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
