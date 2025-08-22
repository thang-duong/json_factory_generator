````markdown
# auto_model_factory

Auto-register `Type -> fromJson` factories for your `json_serializable` models using `@autoModel`.

## Install (in your app/package)

```yaml
dependencies:
  auto_model_factory:
    path: ../auto_model_factory  # or use pub.dev once published
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.11
  json_serializable: ^6.9.0
```

## Setup

1. **Create an injection file** (e.g., `lib/injection.dart`):

```dart
import 'package:auto_model_factory/auto_model_factory.dart';
// Import all your model files here
import 'models/user.dart';
import 'models/post.dart';

part 'injection.config.dart';

@injectableInit
void configureDependencies() {}
```

2. **Annotate your models**:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:auto_model_factory/auto_model_factory.dart';

part 'user.g.dart';

@autoModel
@JsonSerializable()
class User {
  final int id;
  final String name;
  User({required this.id, required this.name});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

> Ensure your model files have `part 'xxx.g.dart';` so the shared part (from this library) can be combined.

## Generate

```bash
dart run build_runner build --delete-conflicting-outputs
```

This will generate:
- Model `.g.dart` files (from json_serializable)
- `injection.config.dart` file containing the `ModelFactory` class

## Use

```dart
import 'package:flutter/material.dart';
import 'injection.dart'; // Contains generated ModelFactory

void main() {
  // No initialization needed! 🎉
  runApp(const MyApp());
}

// Use the generated ModelFactory
final user = ModelFactory.fromJson<User>({"id":1, "name":"Alice"});
final posts = ModelFactory.fromJson<List<Post>>([
  {"id": 10, "title": "Hello"},
]);

// Additional utilities
print('Registered types: ${ModelFactory.registeredTypes}');
print('Is User registered: ${ModelFactory.isRegistered<User>()}');
print('Is Post type registered: ${ModelFactory.isTypeRegistered("Post")}');
```

## Migration from v0.0.x

**Before:**
```dart
void main() {
  ModelFactory.init(); // Required
  runApp(MyApp());
}
```

**After:**
```dart
import 'injection.dart'; // Add this import

void main() {
  // No init needed!
  runApp(MyApp());
}
```

## Common issues

- *Target of URI doesn't exist: 'injection.config.dart'*: Run `dart run build_runner build` first.
- *Factory for type X not found*: missing `@autoModel` annotation.
- *No part file*: ensure `part 'your_file.g.dart';` exists in each model library.
- *Unused import warnings*: The imports in injection.dart are needed for the generated code to work.

## Features

- ✅ **Zero runtime initialization** - everything is compile-time generated
- ✅ **Type-safe** - compile-time checking of model registrations  
- ✅ **Auto-discovery** - automatically finds all `@autoModel` classes
- ✅ **List support** - handles `List<T>` parsing automatically with proper typing
- ✅ **Debugging utilities** - check registered types and registration status
- ✅ **Injectable-style** - similar workflow to injectable package

## How it works

1. **Annotation scanning**: The generator scans all Dart files for `@autoModel` classes
2. **Code generation**: Creates a centralized `ModelFactory` class with all registered types
3. **Type-safe parsing**: Uses compile-time generated code for type-safe JSON parsing
4. **No runtime setup**: Everything is generated at build time, no initialization needed

````
