// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse<T> _$BaseResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    BaseResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: DataConverter<T?>().fromJson(json['data']),
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BaseResponseToJson<T>(
  BaseResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': DataConverter<T?>().toJson(instance.data),
      'code': instance.code,
    };
