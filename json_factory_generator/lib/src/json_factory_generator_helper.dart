import 'dart:async';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:json_factory_annotation/json_factory_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';

/// Helper class to generate JsonFactory code
class JsonFactoryGeneratorHelper {
  static const _dartFilePattern = 'lib/**.dart';
  
  /// Generates the complete factory file content including imports and generated code
  static String generateFactoryFile(List<ModelInfo> models, String packageName) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();

    // Add imports for all model files with package imports
    final imports = <String>{};
    for (final model in models) {
      final importPath = calculatePackageImportPath(
        model.import,
        packageName,
      );
      imports.add("import '$importPath';");
    }

    for (final import in imports.toList()..sort()) {
      buffer.writeln(import);
    }
    buffer.writeln();

    buffer.write(generateFactoryContent(models));
    return buffer.toString();
  }

  /// Checks if a file should be skipped during processing.
  static bool shouldSkipFile(String path) {
    return path.endsWith('.g.dart') || // Skip generated files
        path.contains('.json_factory.dart') || // Skip factory files
        path.endsWith('_test.dart'); // Skip test files
  }

  /// Gets the import path for a model file.
  static String getImportPath(AssetId assetId) {
    return assetId.path;
  }

  /// Calculate package import path from model file path.
  static String calculatePackageImportPath(String modelPath, String packageName) {
    final relativePath = modelPath.replaceFirst('lib/', '');
    return 'package:$packageName/$relativePath';
  }

  /// Checks if a class has a fromJson factory constructor.
  static bool hasFromJsonConstructor(ClassElement2 classElement) {
    for (final constructor in classElement.constructors2) {
      if (constructor.isFactory && constructor.name3 == 'fromJson') {
        log.info('_hasFromJsonConstructor: ${constructor.name3}');

        if (constructor.formalParameters.length == 1) {
          final parameter = constructor.formalParameters.first;
          final parameterType = parameter.type.toString();

          if (parameterType == 'Map<String, dynamic>' ||
              parameterType == 'Map<String, Object?>' ||
              parameterType.startsWith('Map<String,')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Checks if a class has the required annotation and method to be a model.
  static bool isValidModelClass(ClassElement2 classElement) {
    final hasJsonModel =
        TypeChecker.typeNamed(JsonModel).hasAnnotationOfExact(classElement);

    if (!hasJsonModel) return false;
    return hasFromJsonConstructor(classElement);
  }

  /// Processes a single library file to find model classes.
  static Future<List<ModelInfo>> processLibrary(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    final models = <ModelInfo>[];
    final library = await buildStep.resolver.libraryFor(assetId);
    final libraryReader = LibraryReader(library);

    for (final classElement in libraryReader.classes) {
      if (isValidModelClass(classElement)) {
        final className = classElement.name3.toString();
        log.info('Found model class: $className');
        models.add(
          ModelInfo(
            name: className,
            import: getImportPath(assetId),
          ),
        );
      }
    }

    return models;
  }

  /// Finds all model classes annotated with @jsonModel and @JsonSerializable.
  static Future<List<ModelInfo>> findAnnotatedModels(BuildStep buildStep) async {
    final models = <ModelInfo>[];
    final dartFiles = Glob(_dartFilePattern);

    await for (final assetId in buildStep.findAssets(dartFiles)) {
      if (shouldSkipFile(assetId.path)) continue;

      try {
        final modelInfo = await processLibrary(assetId, buildStep);
        models.addAll(modelInfo);
      } catch (e) {
        log.warning('Error processing ${assetId.path}: $e');
      }
    }

    if (models.isEmpty) {
      log.warning('No model classes found with @jsonModel annotation');
    }

    return models;
  }

  /// Generates factory class content for JsonFactory.
  static String generateFactoryContent(List<ModelInfo> models) {
    final buffer = StringBuffer();

    buffer.writeln('/// Auto-generated JsonFactory for type-safe JSON parsing in Flutter/Dart');
    buffer.writeln('///');
    buffer.writeln('/// A centralized factory for parsing JSON data into strongly-typed Dart objects.');
    buffer.writeln('/// Works with any model class annotated with @jsonModel and @JsonSerializable.');
    buffer.writeln('///');
    buffer.writeln('/// Features:');
    buffer.writeln('/// - Type-safe JSON parsing for models and lists of models');
    buffer.writeln('/// - Automatic null-safety handling');
    buffer.writeln('/// - Support for generic types and collections');
    buffer.writeln('/// - Built-in error handling with clear messages');
    buffer.writeln('///');
    buffer.writeln('/// Usage examples:');
    buffer.writeln('///   // Parse a single object');
    buffer.writeln('///   final user = JsonFactory.fromJson<User>(jsonMap);');
    buffer.writeln('///   ');
    buffer.writeln('///   // Parse a list of objects');
    buffer.writeln('///   final users = JsonFactory.fromJson<List<User>>(jsonList);');
    buffer.writeln('///   ');
    buffer.writeln('///   // Handle nullable types');
    buffer.writeln('///   final userOrNull = JsonFactory.fromJson<User?>(maybeNull);');
    buffer.writeln('///   final usersOrNull = JsonFactory.fromJson<List<User>?>(maybeNull);');
    buffer.writeln('class JsonFactory {');

    // Generate _factories map
    _generateFactoriesMap(buffer, models);

    // Generate _typeMap
    _generateTypeMap(buffer, models);

    // Generate _listCasters map
    _generateListCasters(buffer, models);

    // Generate methods
    _generateMethods(buffer);

    // Generate helper methods
    buffer.writeln('  // -----------------------------');
    buffer.writeln('  // Helpers');
    buffer.writeln('  // -----------------------------\n');
    
    buffer.writeln('  /// Returns true if generic T is a nullable type (ends with \'?\').');
    buffer.writeln('  static bool _isNullableT<T>() {');
    buffer.writeln('    final s = _typeNameOf<T>();');
    buffer.writeln('    return s.endsWith(\'?\');');
    buffer.writeln('  }\n');

    buffer.writeln('  /// Returns T\'s name as string (e.g., "User", "User?", "List<User>", "List<User>?")');
    buffer.writeln('  static String _typeNameOf<T>() => T.toString();\n');

    buffer.writeln('  /// Strips a single trailing \'?\' (nullability) from a type name string.');
    buffer.writeln('  static String _stripNullability(String typeName) =>');
    buffer.writeln('      typeName.endsWith(\'?\') ? typeName.substring(0, typeName.length - 1) : typeName;');
    buffer.writeln('}\n');

    buffer.writeln('/// Type definition for JSON factory functions.');
    buffer.writeln('/// ');
    buffer.writeln('/// Each registered model type has a corresponding factory function');
    buffer.writeln('/// that takes dynamic JSON data and returns a parsed model instance.');
    buffer.writeln('typedef FromJsonFunc = dynamic Function(dynamic json);');

    return buffer.toString();
  }

  /// Generates the _factories map content
  static void _generateFactoriesMap(StringBuffer buffer, List<ModelInfo> models) {
    buffer.writeln('  /// Maps Dart Types to their corresponding JSON parsing functions.');
    buffer.writeln('  /// Key: The Dart Type (e.g., User, Post)');
    buffer.writeln('  /// Value: A function that converts JSON data to that Type');
    buffer.writeln('  static final Map<Type, FromJsonFunc> _factories = {');
    for (final model in models) {
      buffer.writeln('    ${model.name}: (json) => '
          '${model.name}.fromJson(json as Map<String, dynamic>),');
    }
    buffer.writeln('  };');
    buffer.writeln();
  }

  /// Generates the _typeMap content
  static void _generateTypeMap(StringBuffer buffer, List<ModelInfo> models) {
    buffer.writeln('  /// Internal map of string type names to actual Dart Types.');
    buffer.writeln('  /// Note: keys are non-nullable simple names (no \'?\', no generics)');
    buffer.writeln('  static final Map<String, Type> _typeMap = {');
    for (final model in models) {
      buffer.writeln('    \'${model.name}\': ${model.name},');
    }
    buffer.writeln('  };');
    buffer.writeln();
  }

  /// Generates the _listCasters map content
  static void _generateListCasters(StringBuffer buffer, List<ModelInfo> models) {
    buffer.writeln('  /// Type-safe casting functions for converting lists of dynamic to strongly-typed lists.');
    buffer.writeln('  /// Key: The element Type (e.g., User for List<User>)');
    buffer.writeln('  /// Value: A function that safely casts a List<dynamic> to List<T>');
    buffer.writeln('  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {');
    for (final model in models) {
      buffer.writeln('    ${model.name}: (list) => list.cast<${model.name}>().toList(),');
    }
    buffer.writeln('  };');
  }

  /// Generates all the methods for JsonFactory
  static void _generateMethods(StringBuffer buffer) {
    _generateFromJson(buffer);
    _generateHandleListType(buffer);
    _generateHandleSingleType(buffer);
  }

  /// Generates fromJson method
  static void _generateFromJson(StringBuffer buffer) {
    buffer.writeln('''
  /// Converts JSON data to the specified type T
  /// Supports both single objects and lists, with nullable T handling.
  static T fromJson<T>(dynamic json) {
    // If incoming JSON is null:
    // - If T is nullable (e.g. User?, List<User>?), return null as T
    // - Else, throw a clear error
    if (json == null) {
      if (_isNullableT<T>()) {
        return null as T; // safe because T is nullable
      }
      throw ArgumentError('JSON data is null for non-nullable type \$T');
    }

    // If it's a list, handle as List<Inner>
    if (json is List) {
      return _handleListType<T>(json);
    }

    // Else expect a single object (Map)
    return _handleSingleType<T>(json);
  }
''');
  }

  /// Generates _handleListType method
  static void _generateHandleListType(StringBuffer buffer) {
    buffer.writeln('''
  /// Handles conversion of `List<Inner>` types.
  /// Example: when `T` is `List<Post>` or `List<Post>?`.
  static T _handleListType<T>(List json) {
    final typeStr = _typeNameOf<T>();
    final bareTypeStr = _stripNullability(typeStr); // e.g. "List<User>"

    // If T isn't List<...>, just return as-is (caller asked for raw list)
    if (!bareTypeStr.startsWith('List<') || !bareTypeStr.endsWith('>')) {
      return json as T;
    }

    // Extract inner type name: "User" from "List<User>"
    final innerTypeName = bareTypeStr.substring(5, bareTypeStr.length - 1);

    // Map to the Dart Type of inner model
    final innerDartType = _typeMap[innerTypeName];
    if (innerDartType == null) {
      throw ArgumentError('Unknown inner type \$innerTypeName in \$typeStr');
    }

    // 1) Parse each JSON item using the registered factory for Inner
    final factory = _factories[innerDartType];
    if (factory == null) {
      throw ArgumentError(
          'No factory registered for inner type \$innerTypeName in \$typeStr');
    }
    final rawList = json.map((e) => factory(e)).toList(); // List<dynamic>

    // 2) Cast to strongly-typed List<Inner> using a generated caster
    final caster = _listCasters[innerDartType];
    if (caster != null) {
      final typedList = caster(rawList); // List<Inner>
      // 3) Return as T (where T == List<Inner> or List<Inner>?)
      return typedList as T;
    }

    // Fallback: return dynamic list if no caster available
    return rawList as T;
  }
''');
  }

  /// Generates _handleSingleType method
  static void _generateHandleSingleType(StringBuffer buffer) {
    buffer.writeln('''
  /// Handles conversion of single object types (e.g., `User` or `User?`).
  static T _handleSingleType<T>(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
        'Expected JSON object (Map) for type \$T, got \${json.runtimeType}',
      );
    }

    final typeStr = _stripNullability(_typeNameOf<T>()); // e.g. "User"
    final dartType = _typeMap[typeStr];
    if (dartType == null) {
      throw ArgumentError('Unknown or unregistered type \$typeStr for \$T');
    }

    final factory = _factories[dartType];
    if (factory == null) {
      throw ArgumentError('No factory registered for type \$typeStr');
    }

    return factory(json) as T;
  }
''');
  }
}

/// Represents a model class that needs to be included in the JsonFactory.
class ModelInfo {
  /// The name of the model class (e.g., "User", "Post")
  final String name;

  /// The import path for the model class relative to the package
  /// (e.g., "lib/models/user.dart")
  final String import;

  const ModelInfo({
    required this.name,
    required this.import,
  });

  @override
  String toString() => 'ModelInfo(name: $name, import: $import)';
}
