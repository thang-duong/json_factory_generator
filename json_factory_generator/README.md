# JSON Factory Generator

A powerful Dart code generator that creates centralized, type-safe JSON factories for your models. Automatically discovers classes annotated with `@jsonModel` and generates a unified `JsonFactory` with support for both single objects and `List<T>` parsing.

[![Pub Package](https://img.shields.io/pub/v/json_factory_generator.svg)](https://pub.dev/packages/json_factory_generator)
[![Dart Version](https://badgen.net/pub/sdk-version/json_factory_generator)](https://pub.dev/packages/json_factory_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Requirements

- Dart SDK: >=3.5.2 <4.0.0

## Features

- ✅ **Zero runtime initialization** - everything is compile-time generated
- ✅ **Type-safe JSON parsing** - compile-time checking with proper generics  
- ✅ **Auto-discovery** - automatically finds all `@JsonModel` classes with `fromJson` method
- ✅ **List support** - handles `List<T>` parsing with proper type casting
- ✅ **Flexible** - works with manual `fromJson` or `json_serializable` generated methods
- ✅ **No forced dependencies** - `json_serializable` is optional, not required
- ✅ **Configurable output** - customize output path and filename
- ✅ **Error handling** - clear error messages for debugging
- ✅ **Build integration** - works seamlessly with build_runner
- ✅ **Platform support** - supports all Dart platforms (Android, iOS, Web, Desktop)

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  json_factory_annotation: ^1.0.0
  json_annotation: ^4.9.0  # Optional: if using json_serializable

dev_dependencies:
  json_factory_generator: ^1.0.0
  build_runner: ^2.7.0
  # Optional: if using json_serializable for code generation
  json_serializable: ^6.10.0
```

## Setup

1. **Annotate your models** with `@jsonModel`:

### Option A: Manual fromJson (No dependencies)

```dart
import 'package:json_factory_annotation/json_factory_annotation.dart';

@JsonModel
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
import 'package:json_factory_annotation/json_factory_annotation.dart';

part 'user.g.dart';

@JsonModel
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

Run the following command to generate the JSON factory code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This will:
1. Scan your project for classes annotated with `@JsonModel`
2. Generate a centralized `json_factory.dart` file with type-safe parsing methods
3. Place the generated file in your configured output directory (default: lib/generated)

## Usage

After generation, you can use the JsonFactory to parse JSON data:

```dart
import 'package:your_package/generated/json_factory.dart';

// Parse a single object
final json = {'id': 1, 'name': 'John'};
final user = JsonFactory.fromJson<User>(json);

// Parse a list of objects
final jsonList = [
  {'id': 1, 'name': 'John'},
  {'id': 2, 'name': 'Jane'}
];
final users = JsonFactory.fromJsonList<User>(jsonList);
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

This will generate:
- Model `.g.dart` files (if using json_serializable)
- `lib/generated/json_factory.dart` file containing the centralized `JsonFactory` class

## Usage

```dart
import 'package:flutter/material.dart';
import 'generated/json_factory.dart'; // Contains generated JsonFactory

void main() {
  // No initialization needed! 🎉
  runApp(const MyApp());
}

// Parse single objects
final user = JsonFactory.fromJson<User>({"id": 1, "name": "Alice"});

// Parse lists with proper typing
final posts = JsonFactory.fromJson<List<Post>>([
  {"id": 10, "title": "Hello", "content": "Content"},
  {"id": 11, "title": "World", "content": "More content"},
]);
```

## Generic API Response Wrapper

The library includes a powerful `BaseResponse<T>` class for handling API responses with generic type support:

```dart
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
```

### BaseResponse Usage Examples

```dart
// Single user response
final userResponse = BaseResponse<User>.fromJson(
  {
    "success": true,
    "message": "User fetched successfully", 
    "data": {"id": 1, "name": "John Doe"},
    "code": 200
  },
  (json) => User.fromJson(json as Map<String, dynamic>),
);

// List of posts response
final postsResponse = BaseResponse<List<Post>>.fromJson(
  {
    "success": true,
    "message": "Posts retrieved",
    "data": [
      {"id": 1, "title": "First Post", "content": "Content 1"},
      {"id": 2, "title": "Second Post", "content": "Content 2"}
    ],
    "code": 200
  },
  (json) => (json as List).map((item) => Post.fromJson(item)).toList(),
);

// Error response
final errorResponse = BaseResponse<User?>.fromJson(
  {
    "success": false,
    "message": "User not found",
    "data": null,
    "code": 404
  },
  (json) => json != null ? User.fromJson(json as Map<String, dynamic>) : null,
);

// Access response data
if (userResponse.success) {
  print('User: ${userResponse.data?.name}');
} else {
  print('Error: ${userResponse.message}');
}
```

### BaseResponse Benefits

- ✅ **Type-safe generic responses** - compile-time type checking for API data
- ✅ **Consistent API structure** - standardized response format across your app
- ✅ **Auto JSON conversion** - leverages JsonFactory for seamless data parsing
- ✅ **Error handling** - built-in success/failure status with error codes
- ✅ **Flexible data types** - supports any type T including primitives, objects, and lists
- ✅ **Null safety** - proper handling of nullable data fields

```

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

## Troubleshooting

### Common Issues

- **Target of URI doesn't exist: 'lib/generated/json_factory.dart'**: 
  - Run `dart run build_runner build` first to generate the factory file.
  
- **Factory for type X not found**: 
  - Ensure your class has `@jsonModel` annotation and `fromJson` factory constructor.
  - Check that the class is in a file under `lib/` directory.
  
- **No part file**: 
  - Only needed if using `@JsonSerializable()` - ensure `part 'your_file.g.dart';` exists.
  
- **Build fails**: 
  - Try `dart run build_runner clean` then `dart run build_runner build`.
  
- **Import errors**: 
  - Make sure to import the generated factory file correctly: `import 'generated/json_factory.dart';`
  
- **fromJson not found**: 
  - Ensure your class has `factory ClassName.fromJson(Map<String, dynamic> json)` constructor.

### Build Commands

```bash
# Clean previous builds
dart run build_runner clean

# Generate code
dart run build_runner build

# Generate with conflict resolution
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
dart run build_runner watch
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📫 Issues: [GitHub Issues](https://github.com/thang-duong/json_factory_generator/issues)
- 📖 Documentation: [pub.dev](https://pub.dev/packages/json_factory_generator)
- 💬 Discussions: [GitHub Discussions](https://github.com/thang-duong/json_factory_generator/discussions)
