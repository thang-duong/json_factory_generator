import 'package:json_annotation/json_annotation.dart';
import 'package:json_factory_generator/json_factory_generator.dart';

part 'post.g.dart';

@jsonModel
@JsonSerializable()
class Post {
  final int id;
  final String title;
  final String content;

  Post({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
