import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'package:json_annotation/json_annotation.dart';
import 'annotations.dart';

/// Represents a model class that needs JSON factory generation
class ModelInfo {
  /// The name of the model class
  final String name;

  /// The import path for the model class
  final String import;

  const ModelInfo({
    required this.name,
    required this.import,
  });
}

/// Generates a centralized JsonFactory configuration for all annotated models
class JsonFactoryConfigGenerator extends GeneratorForAnnotation<JsonFactoryInit> {
  static const _dartFilePattern = 'lib/**.dart';

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final models = await _findAnnotatedModels(buildStep);

    // Add part directive
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND\n');
    buffer.writeln('part of \'${element.source?.uri.pathSegments.last}\';');
    buffer.writeln('\n');

    buffer.write(_generateFactoryClass(models));
    return buffer.toString();
  }

  /// Finds all model classes annotated with @jsonModel and @JsonSerializable
  Future<List<ModelInfo>> _findAnnotatedModels(BuildStep buildStep) async {
    final models = <ModelInfo>[];
    final dartFiles = Glob(_dartFilePattern);

    await for (final assetId in buildStep.findAssets(dartFiles)) {
      if (_shouldSkipFile(assetId.path)) continue;

      try {
        final modelInfo = await _processLibrary(assetId, buildStep);
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

  /// Processes a single library file to find model classes
  Future<List<ModelInfo>> _processLibrary(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    final models = <ModelInfo>[];
    final library = await buildStep.resolver.libraryFor(assetId);
    final libraryReader = LibraryReader(library);

    for (final classElement in libraryReader.classes) {
      if (_isValidModelClass(classElement)) {
        log.info('Found model class: ${classElement.name}');
        models.add(
          ModelInfo(
            name: classElement.name,
            import: _getImportPath(assetId),
          ),
        );
      }
    }

    return models;
  }

  /// Checks if a class has the required annotations to be a model
  bool _isValidModelClass(ClassElement classElement) {
    final hasJsonModel = TypeChecker.fromRuntime(JsonModel)
        .hasAnnotationOfExact(classElement);
    final hasJsonSerializable = TypeChecker.fromRuntime(JsonSerializable)
        .hasAnnotationOfExact(classElement);

    return hasJsonModel && hasJsonSerializable;
  }

  /// Generates the JsonFactory class with all its components
  String _generateFactoryClass(List<ModelInfo> models) {
    final buffer = StringBuffer();

    buffer.writeln('/// Auto-generated JsonFactory configuration');
    buffer.writeln('/// Generated on: ${DateTime.now()}');
    buffer.writeln('class JsonFactory {');

    // Generate _factories map
    buffer.writeln('  static final Map<Type, FromJsonFunc> _factories = {');
    for (final model in models) {
      buffer.writeln('    ${model.name}: (json) => '
          '${model.name}.fromJson(json as Map<String, dynamic>),');
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Generate _typeMap
    buffer.writeln('  static final Map<String, Type> _typeMap = {');
    for (final model in models) {
      buffer.writeln('    \'${model.name}\': ${model.name},');
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Generate _listCasters map
    buffer.writeln('  /// Generated list casters to convert `List<dynamic>` into `List<T>` safely');
    buffer.writeln('  /// without long `if/else` chains. Each entry corresponds to a model type');
    buffer.writeln('  /// registered in `_factories`. Keep this in sync with `_factories`.');
    buffer.writeln('  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {');
    for (final model in models) {
      buffer.writeln('    ${model.name}: (list) => list.cast<${model.name}>().toList(),');
    }
    buffer.writeln('  };');

    // Generate fromJson method
    _generateFromJson(buffer);

    // Generate _handleListType method
    _generateHandleListType(buffer);

    // Generate _handleSingleType method
    _generateHandleSingleType(buffer);

    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('/// Type definition for JSON factory functions');
    buffer.writeln('typedef FromJsonFunc = dynamic Function(dynamic json);');

    return buffer.toString();
  }

  void _generateFromJson(StringBuffer buffer) {
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

  void _generateHandleListType(StringBuffer buffer) {
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

  void _generateHandleSingleType(StringBuffer buffer) {
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

  /// Gets the import path for a model file
  String _getImportPath(AssetId assetId) {
    return assetId.path;
  }

  /// Determines if a file should be skipped during processing
  bool _shouldSkipFile(String path) {
    return path.endsWith('.g.dart') || // Skip generated files
           path.contains('.json_factory.dart') || // Skip factory files
           path.endsWith('_test.dart'); // Skip test files
  }
}
