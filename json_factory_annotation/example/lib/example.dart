import 'package:json_factory_annotation/json_factory_annotation.dart';

// Example of using @JsonModel annotation with manual JSON serialization
@JsonModel()
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

void main() {
  // Example JSON data
  final userJson = {
    'id': 1,
    'name': 'John Doe',
    'email': 'john@example.com',
  };

  // Creating object from JSON
  final user = User.fromJson(userJson);

  // Converting object back to JSON
  print('User JSON: ${user.toJson()}');
  // Output: User JSON: {id: 1, name: John Doe, email: john@example.com}
}
