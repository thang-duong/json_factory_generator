import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'annotations.dart';

/// Represents a model class that needs to be included in the JsonFactory.
///
/// This class holds metadata about a model that was discovered during
/// the code generation process, including its class name and import path.
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

/// Generates a centralized JsonFactory class for all annotated models.
///
/// This generator is responsible for:
/// 1. Scanning all Dart files in the project for classes with `@jsonModel` annotation
/// 2. Collecting metadata about each discovered model class
/// 3. Generating a centralized JsonFactory class with type-safe parsing methods
/// 4. Creating internal type mappings for efficient runtime lookups
///
/// The generated JsonFactory provides a single entry point for parsing JSON data
/// into strongly-typed Dart objects, supporting both single objects and lists.
///
/// ## Generated Code Structure:
/// - `_factories`: Map of Type to parsing functions
/// - `_typeMap`: Map of string names to Dart Types for generic parsing
/// - `_listCasters`: Map of Type to list casting functions for List<T> support
/// - `fromJson<T>()`: Main parsing method with type-safe generics
///
/// ## Configuration:
/// - `outputFileName`: Name of the generated file (default: "json_factory")
/// - `outputPath`: Directory for the generated file (default: "lib/generated")
class JsonFactoryConfigGenerator extends Generator {
  static const _dartFilePattern = 'lib/**.dart';

  /// Configuration options for the generator
  final String outputFileName;
  final String outputPath;

  /// Creates a new JsonFactoryConfigGenerator with optional configuration.
  ///
  /// [outputFileName] specifies the name of the generated file without extension.
  /// [outputPath] specifies the directory where the file should be generated.
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
    
    // Generate content hash for cache optimization
    final contentHash = _generateContentHash(models, packageName);
    log.info('Content hash for cache: $contentHash');
    
    return generateFactoryFile(models, packageName);
  }

  /// Generates a content hash based on model metadata for cache optimization
  String _generateContentHash(List<ModelInfo> models, String packageName) {
    final buffer = StringBuffer();
    buffer.write(packageName);
    for (final model in models) {
      buffer.write('${model.name}:${model.import}');
    }
    return buffer.toString().hashCode.toString();
  }

  /// Public method to find all annotated models in the project.
  ///
  /// Scans all Dart files in the lib/ directory for classes that have both
  /// `@jsonModel` and `@JsonSerializable()` annotations. Returns a list of
  /// [ModelInfo] objects containing metadata about each discovered model.
  ///
  /// This method is used by the builder to collect all models before
  /// generating the centralized JsonFactory class.
  Future<List<ModelInfo>> findAnnotatedModels(BuildStep buildStep) async {
    return _findAnnotatedModels(buildStep);
  }

  /// Public method to generate the factory file content.
  ///
  /// Takes a list of discovered models and generates the complete Dart code
  /// for the JsonFactory class. The generated code includes:
  /// - Import statements for all model files
  /// - Factory function mappings
  /// - Type name to Type mappings
  /// - List casting functions
  /// - The main fromJson<T>() method
  ///
  /// [models] List of model metadata to include in the factory
  /// [packageName] The current package name for generating import statements
  String generateFactoryFile(List<ModelInfo> models, String packageName) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
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

  /// Calculate package import path from model file path.
  ///
  /// Converts a local file path like "lib/models/post.dart" into a proper
  /// package import path like "package:my_package/models/post.dart".
  ///
  /// This is necessary because the generated JsonFactory needs to import
  /// all model files using package imports for proper resolution.
  String _calculatePackageImportPath(String modelPath, String packageName) {
    // Convert lib/models/post.dart -> package:{package_name}/models/post.dart
    final relativePath = modelPath.replaceFirst('lib/', '');
    return 'package:$packageName/$relativePath';
  }

  /// Finds all model classes annotated with @jsonModel and @JsonSerializable.
  ///
  /// This method performs a comprehensive scan of the project:
  /// 1. Uses glob patterns to find all Dart files in lib/
  /// 2. Parses each file to find class declarations
  /// 3. Checks for the required annotations on each class
  /// 4. Collects metadata about valid model classes
  ///
  /// Only classes that have both annotations are included in the result.
  /// Files ending in .g.dart, .json_factory.dart, or _test.dart are skipped.
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

  /// Processes a single library file to find model classes.
  ///
  /// For each Dart file:
  /// 1. Resolves the library using the Dart analyzer
  /// 2. Iterates through all class elements in the library
  /// 3. Validates each class for required annotations
  /// 4. Extracts metadata for valid model classes
  ///
  /// Returns a list of ModelInfo objects for classes that meet the criteria.
  Future<List<ModelInfo>> _processLibrary(
    AssetId assetId,
    BuildStep buildStep,
  ) async {
    final models = <ModelInfo>[];
    final library = await buildStep.resolver.libraryFor(assetId);
    final libraryReader = LibraryReader(library);

    for (final classElement in libraryReader.classes) {
      if (_isValidModelClass(classElement)) {
        final className = classElement.name ?? 'Unknown';
        log.info('Found model class: $className');
        models.add(
          ModelInfo(
            name: className,
            import: _getImportPath(assetId),
          ),
        );
      }
    }

    return models;
  }

  /// Checks if a class has the required annotation and method to be a model.
  ///
  /// A valid model class must have:
  /// 1. `@jsonModel` annotation from this package
  /// 2. A `fromJson` factory constructor that accepts Map<String, dynamic>
  ///
  /// This ensures that the class has both the intent to be included (via @jsonModel)
  /// and the necessary fromJson factory method for JSON parsing.
  bool _isValidModelClass(ClassElement classElement) {
    final hasJsonModel =
        TypeChecker.typeNamed(JsonModel).hasAnnotationOfExact(classElement);

    if (!hasJsonModel) return false;

    // Check if class has a fromJson factory constructor
    final hasFromJsonMethod = _hasFromJsonConstructor(classElement);

    return hasFromJsonMethod;
  }

  /// Checks if a class has a fromJson factory constructor.
  ///
  /// Looks for a factory constructor named 'fromJson' that accepts
  /// a Map<String, dynamic> parameter, which is the standard pattern
  /// for JSON deserialization in Dart.
  bool _hasFromJsonConstructor(ClassElement classElement) {
    for (final constructor in classElement.constructors) {
      // Check if it's a factory constructor named 'fromJson'
      if (constructor.isFactory && constructor.name == 'fromJson') {
        // Check if it has exactly one parameter of type Map<String, dynamic>
        if (constructor.formalParameters.length == 1) {
          final parameter = constructor.formalParameters.first;
          final parameterType = parameter.type.toString();

          // Check for Map<String, dynamic> parameter
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

  /// Generates the complete JsonFactory class with all its components.
  ///
  /// Creates a comprehensive JsonFactory class containing:
  /// 1. Internal maps for type resolution and factory functions
  /// 2. List casting functions for proper List<T> support
  /// 3. The main fromJson<T>() method with generic type support
  /// 4. Helper methods for handling different JSON structures
  ///
  /// The generated class is completely self-contained and requires no
  /// runtime initialization - all type mappings are created at compile time.
  String _generateFactoryClass(List<ModelInfo> models) {
    final buffer = StringBuffer();

    buffer.writeln('/// Auto-generated JsonFactory for type-safe JSON parsing');
    buffer.writeln('/// ');
    buffer.writeln(
        '/// This class provides centralized, type-safe JSON parsing for all');
    buffer.writeln(
        '/// model classes annotated with @jsonModel and @JsonSerializable.');
    buffer.writeln('/// ');
    buffer.writeln('/// Usage:');
    buffer.writeln('///   final user = JsonFactory.fromJson<User>(jsonMap);');
    buffer.writeln(
        '///   final users = JsonFactory.fromJson<List<User>>(jsonList);');
    buffer.writeln('class JsonFactory {');

    // Generate _factories map
    buffer.writeln('  /// Internal map of Type to JSON parsing functions.');
    buffer.writeln(
        '  /// Each entry maps a model class Type to its fromJson factory method.');
    buffer.writeln('  static final Map<Type, FromJsonFunc> _factories = {');
    for (final model in models) {
      buffer.writeln('    ${model.name}: (json) => '
          '${model.name}.fromJson(json as Map<String, dynamic>),');
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Generate _typeMap
    buffer.writeln(
        '  /// Internal map of string type names to actual Dart Types.');
    buffer.writeln(
        '  /// Used for resolving generic types like List<User> at runtime.');
    buffer.writeln('  static final Map<String, Type> _typeMap = {');
    for (final model in models) {
      buffer.writeln('    \'${model.name}\': ${model.name},');
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Generate _listCasters map
    buffer.writeln(
        '  /// Generated list casters for safe List<T> type conversion.');
    buffer.writeln('  /// ');
    buffer.writeln(
        '  /// When parsing List<ModelType>, we first parse each JSON object into');
    buffer.writeln(
        '  /// model instances (creating List<dynamic>), then use these casters');
    buffer.writeln(
        '  /// to safely convert to List<ModelType> with proper generic typing.');
    buffer.writeln('  /// ');
    buffer.writeln(
        '  /// This avoids runtime type errors and provides compile-time safety.');
    buffer.writeln(
        '  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {');
    for (final model in models) {
      buffer.writeln(
          '    ${model.name}: (list) => list.cast<${model.name}>().toList(),');
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
    buffer.writeln('/// Type definition for JSON factory functions.');
    buffer.writeln('/// ');
    buffer.writeln(
        '/// Each registered model type has a corresponding factory function');
    buffer.writeln(
        '/// that takes dynamic JSON data and returns a parsed model instance.');
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

  /// Gets the import path for a model file.
  ///
  /// Simply returns the asset path, which will be converted to a proper
  /// package import path by _calculatePackageImportPath() when generating
  /// the final imports in the JsonFactory file.
  String _getImportPath(AssetId assetId) {
    return assetId.path;
  }

  /// Determines if a file should be skipped during processing.
  ///
  /// Skips:
  /// - Generated .g.dart files (from json_serializable)
  /// - Previously generated .json_factory.dart files
  /// - Test files ending in _test.dart
  ///
  /// This prevents infinite generation loops and improves performance
  /// by avoiding files that don't contain model definitions.
  bool _shouldSkipFile(String path) {
    return path.endsWith('.g.dart') || // Skip generated files
        path.contains('.json_factory.dart') || // Skip factory files
        path.endsWith('_test.dart'); // Skip test files
  }
}
