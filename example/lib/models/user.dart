import 'package:json_annotation/json_annotation.dart';
import 'package:json_factory_generator/json_factory_generator.dart';

part 'user.g.dart';

@jsonModel
@JsonSerializable()
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
