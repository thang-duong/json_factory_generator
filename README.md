# JSON Factory Generator

A powerful Dart code generator that creates centralized, type-safe JSON factories for your models. Automatically discovers classes annotated with `@jsonModel` and generates a unified `JsonFactory` with support for both single objects and `List<T>` parsing.

[![Pub Package](https://img.shields.io/pub/v/json_factory_generator.svg)](https://pub.dev/packages/json_factory_generator)
[![Dart Version](https://badgen.net/pub/sdk-version/json_factory_generator)](https://pub.dev/packages/json_factory_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- ✅ **Zero runtime initialization** - everything is compile-time generated
- ✅ **Type-safe JSON parsing** - compile-time checking with proper generics
- ✅ **Auto-discovery** - automatically finds all `@jsonModel` classes with `fromJson` method
- ✅ **List support** - handles `List<T>` parsing with proper type casting
- ✅ **Flexible** - works with manual `fromJson` or `json_serializable` generated methods
- ✅ **No forced dependencies** - `json_serializable` is optional, not required
- ✅ **Configurable output** - customize output path and filename
- ✅ **Error handling** - clear error messages for debugging
- ✅ **Build integration** - works seamlessly with build_runner
- ✅ **Platform support** - supports all Dart platforms (Android, iOS, Web, Desktop)

## Install (in your app/package)

```yaml
dependencies:
  json_factory_generator: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.11
  # Optional: if using json_serializable for code generation
  json_annotation: ^4.9.0
  json_serializable: ^6.9.0
```

## Setup

1. **Annotate your models** with `@jsonModel`:

### Option A: Manual fromJson (No dependencies)

```dart
import 'package:json_factory_generator/json_factory_generator.dart';

@jsonModel
class User {
  final int id;
  final String name;
  
  User({required this.id, required this.name});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

### Option B: With json_serializable (Recommended for complex models)

```dart
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
```

> **Important**: Your model class must have a `fromJson(Map<String, dynamic>)` factory constructor.

2. **Configure build.yaml** (optional - for custom output path):

```yaml
targets:
  $default:
    builders:
      json_factory_generator:jsonFactoryBuilder:
        options:
          output_path: lib/generated  # Default: lib
          output_file_name: json_factory  # Default: json_factory
```

## Generate

```bash
dart run build_runner build --delete-conflicting-outputs
```

This will generate:
- Model `.g.dart` files (from json_serializable)
- `lib/generated/json_factory.dart` file containing the centralized `JsonFactory` class

## Use

```dart
import 'package:flutter/material.dart';
import 'generated/json_factory.dart'; // Contains generated JsonFactory

void main() {
  // No initialization needed! 🎉
  runApp(const MyApp());
}

// Use the generated JsonFactory
final user = JsonFactory.fromJson<User>({"id":1, "name":"Alice"});
final posts = JsonFactory.fromJson<List<Post>>([
  {"id": 10, "title": "Hello", "content": "Content"},
]);

// List parsing with proper typing
final userList = JsonFactory.fromJson<List<User>>([
  {"id": 1, "name": "Alice"},
  {"id": 2, "name": "Bob"}
]);
```

## Migration from Previous Versions

**If you used this package with different annotation names before:**
```dart
// Old usage
@autoModel
@JsonSerializable()
class User { ... }

// Current usage  
@jsonModel
@JsonSerializable()
class User { ... }
```

## Common Issues

- **Target of URI doesn't exist: 'lib/generated/json_factory.dart'**: Run `dart run build_runner build` first.
- **Factory for type X not found**: Make sure your class has `@jsonModel` annotation and `fromJson` factory constructor.
- **No part file**: Only needed if using `@JsonSerializable()` - ensure `part 'your_file.g.dart';` exists.
- **Build fails**: Try `dart run build_runner clean` then `dart run build_runner build`.
- **Import errors**: Make sure to import the generated factory file correctly.
- **fromJson not found**: Ensure your class has `factory ClassName.fromJson(Map<String, dynamic> json)` constructor.

## Features

- ✅ **Zero runtime initialization** - everything is compile-time generated
- ✅ **Type-safe JSON parsing** - compile-time checking with proper generics
- ✅ **Auto-discovery** - automatically finds all `@jsonModel` classes with `fromJson` method
- ✅ **List support** - handles `List<T>` parsing with proper type casting
- ✅ **Flexible** - works with manual `fromJson` or `json_serializable` generated methods
- ✅ **No forced dependencies** - `json_serializable` is optional, not required
- ✅ **Configurable output** - customize output path and filename
- ✅ **Error handling** - clear error messages for debugging
- ✅ **Build integration** - works seamlessly with build_runner

## How it works

1. **Annotation scanning**: The generator scans all Dart files for `@jsonModel` classes
2. **Code generation**: Creates a centralized `JsonFactory` class with type-safe factories
3. **Type mapping**: Generates internal maps for efficient type lookup and casting
4. **List handling**: Special logic for parsing `List<T>` with proper generic types
5. **No runtime setup**: Everything is generated at build time, zero initialization needed

## Architecture

```
Your Models (@jsonModel) 
     ↓
Generator scans files
     ↓  
Generates JsonFactory class
     ↓
Type-safe fromJson<T>() method
```
