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

    buffer.writeln('/// Auto-generated JsonFactory for type-safe JSON parsing');
    buffer.writeln('/// ');
    buffer.writeln('/// This class provides centralized, type-safe JSON parsing for all');
    buffer.writeln('/// model classes annotated with @jsonModel and @JsonSerializable.');
    buffer.writeln('/// ');
    buffer.writeln('/// Usage:');
    buffer.writeln('///   final user = JsonFactory.fromJson<User>(jsonMap);');
    buffer.writeln('///   final users = JsonFactory.fromJson<List<User>>(jsonList);');
    buffer.writeln('class JsonFactory {');

    // Generate _factories map
    _generateFactoriesMap(buffer, models);

    // Generate _typeMap
    _generateTypeMap(buffer, models);

    // Generate _listCasters map
    _generateListCasters(buffer, models);

    // Generate methods
    _generateMethods(buffer);

    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('/// Type definition for JSON factory functions.');
    buffer.writeln('/// ');
    buffer.writeln('/// Each registered model type has a corresponding factory function');
    buffer.writeln('/// that takes dynamic JSON data and returns a parsed model instance.');
    buffer.writeln('typedef FromJsonFunc = dynamic Function(dynamic json);');

    return buffer.toString();
  }

  /// Generates the _factories map content
  static void _generateFactoriesMap(StringBuffer buffer, List<ModelInfo> models) {
    buffer.writeln('  /// Internal map of Type to JSON parsing functions.');
    buffer.writeln('  /// Each entry maps a model class Type to its fromJson factory method.');
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
    buffer.writeln('  /// Used for resolving generic types like List<User> at runtime.');
    buffer.writeln('  static final Map<String, Type> _typeMap = {');
    for (final model in models) {
      buffer.writeln('    \'${model.name}\': ${model.name},');
    }
    buffer.writeln('  };');
    buffer.writeln();
  }

  /// Generates the _listCasters map content
  static void _generateListCasters(StringBuffer buffer, List<ModelInfo> models) {
    buffer.writeln('  /// Generated list casters for safe List<T> type conversion.');
    buffer.writeln('  /// ');
    buffer.writeln('  /// When parsing List<ModelType>, we first parse each JSON object into');
    buffer.writeln('  /// model instances (creating List<dynamic>), then use these casters');
    buffer.writeln('  /// to safely convert to List<ModelType> with proper generic typing.');
    buffer.writeln('  /// ');
    buffer.writeln('  /// This avoids runtime type errors and provides compile-time safety.');
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
  /// Supports both single objects and lists
  static T fromJson<T>(dynamic json) {
    if (json == null) {
      throw ArgumentError('JSON data is null for type \$T');
    }

    // Handle List<T>
    if (json is List) {
      return _handleListType<T>(json);
    }

    // Handle single object
    return _handleSingleType<T>(json);
  }
''');
  }

  /// Generates _handleListType method
  static void _generateHandleListType(StringBuffer buffer) {
    buffer.writeln('''
  /// Handles conversion of `List<Inner>` types.
  /// Example: when `T` is `List<Post>`, this will:
  /// 1) parse each JSON item using the registered factory for `Post`,
  /// 2) cast the result to `List<Post>` via a generated caster,
  /// 3) return it as `T`.
  static T _handleListType<T>(List json) {
    final typeStr = T.toString();
    // If T isn't a List<...>, just return the original list as-is.
    if (!typeStr.startsWith('List<') || !typeStr.endsWith('>')) {
      return json as T;
    }

    // Extract inner type name, e.g. "Post" from "List<Post>".
    final innerTypeName = typeStr.substring(5, typeStr.length - 1);

    // Look up the actual Dart Type from the generated type map.
    final dartType = _typeMap[innerTypeName];
    if (dartType == null) {
      throw ArgumentError('Unknown type \$innerTypeName in List<\$innerTypeName>');
    }

    // Step 1: Map raw JSON to model instances using the correct factory.
    final factory = _factories[dartType]!;
    final rawList = json.map((e) => factory(e)).toList(); // List<dynamic>

    // Step 2: Cast to a strongly-typed List<Inner> using a generated caster.
    final caster = _listCasters[dartType];
    if (caster != null) {
      final typedList = caster(rawList); // List<Inner>
      // Step 3: Return as T (where T == List<Inner>).
      return typedList as T;
    }

    // Fallback: return the dynamic list if no caster is available.
    return rawList as T;
  }
''');
  }

  /// Generates _handleSingleType method
  static void _generateHandleSingleType(StringBuffer buffer) {
    buffer.writeln('''
  /// Handles conversion of single object types
  static T _handleSingleType<T>(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
          'Expected JSON object for type \$T, got \${json.runtimeType}');
    }

    final factory = _factories[T];
    if (factory == null) {
      throw ArgumentError('No factory registered for type \$T');
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
