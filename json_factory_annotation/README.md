# JSON Factory Annotation

Annotation package for centralized, type-safe JSON factory generation in Dart models. This package provides annotations that work with `json_factory_generator` to automatically generate JSON serialization code for your Dart classes.

## Features

- Type-safe JSON serialization
- Support for generic API responses
- Handle complex object graphs
- Centralized JSON factory generation

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  json_factory_annotation: ^1.0.0

dev_dependencies:
  json_factory_generator: ^1.0.0
  build_runner: ^2.4.0
```

## Usage

### Basic Usage

```dart
import 'package:json_factory_annotation/json_factory_annotation.dart';

@JsonModel // Mark this class for JsonFactory generation
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    age: json['age'] as int,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };
}
```

### With json_serializable

```dart
import 'package:json_factory_annotation/json_factory_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonModel // Mark this class for JsonFactory generation
@JsonSerializable()
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

## Annotations

### @JsonModel

The main annotation that marks a class for inclusion in the generated JsonFactory. Any class annotated with `@JsonModel` will be discovered by the generator and included in the centralized JSON factory.

Requirements:
- Class must have a `fromJson` factory constructor
- Class must be in a file under the `lib/` directory
- Class must be properly imported in your code

## Additional information

For more detailed information, examples, and documentation, visit:
- [GitHub Repository](https://github.com/thang-duong/json_factory_generator)
- [Issue Tracker](https://github.com/thang-duong/json_factory_generator/issues)
