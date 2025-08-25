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
  json_factory_annotation: ^0.1.0

dev_dependencies:
  json_factory_generator: ^0.1.0
  build_runner: ^2.4.0
```

## Usage

```dart
import 'package:json_factory_annotation/json_factory_annotation.dart';

@JsonSerializable()
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}
```

## Additional information

For more detailed information, examples, and documentation, visit:
- [GitHub Repository](https://github.com/thang-duong/json_factory_generator)
- [Issue Tracker](https://github.com/thang-duong/json_factory_generator/issues)
