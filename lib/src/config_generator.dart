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
class JsonFactoryConfigGenerator extends Generator {
  static const _dartFilePattern = 'lib/**.dart';
  
  /// Configuration options for the generator
  final String outputFileName;
  final String outputPath;
  
  JsonFactoryConfigGenerator({
    this.outputFileName = 'json_factory',
    this.outputPath = 'lib/generated',
  });

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Only generate for lib/models/ files to avoid duplicate generation
    final inputPath = buildStep.inputId.path;
    if (!inputPath.startsWith('lib/models/') || inputPath.endsWith('.g.dart')) {
      return '';
    }
    
    final models = await findAnnotatedModels(buildStep);
    
    // Only generate if we have models and this is the first model file processed
    if (models.isEmpty) return '';
    
    // Check if this is the first model file being processed
    // We'll generate the factory only for the first model file found
    final firstModelFile = models.first.import;
    if (inputPath != firstModelFile) return '';

    // Get package name from buildStep
    final packageName = buildStep.inputId.package;
    return generateFactoryFile(models, packageName);
  }

  /// Public method to find all annotated models
  Future<List<ModelInfo>> findAnnotatedModels(BuildStep buildStep) async {
    return _findAnnotatedModels(buildStep);
  }

  /// Public method to generate the factory file content
  String generateFactoryFile(List<ModelInfo> models, String packageName) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated on: ${DateTime.now()}');
    buffer.writeln();
    
    // Add imports for all model files with package imports
    final imports = <String>{};
    for (final model in models) {
      final importPath = _calculatePackageImportPath(model.import, packageName);
      imports.add("import '$importPath';");
    }
    
    for (final import in imports.toList()..sort()) {
      buffer.writeln(import);
    }
    buffer.writeln();

    buffer.write(_generateFactoryClass(models));
    return buffer.toString();
  }

  /// Calculate package import path from model file path
  String _calculatePackageImportPath(String modelPath, String packageName) {
    // Convert lib/models/post.dart -> package:{package_name}/models/post.dart
    final relativePath = modelPath.replaceFirst('lib/', '');
    return 'package:$packageName/$relativePath';
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
