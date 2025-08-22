import 'package:build/build.dart';
import 'src/config_generator.dart';

/// Creates and configures the JsonFactory builder for code generation.
/// 
/// This builder is responsible for scanning all Dart files in the project,
/// finding classes annotated with `@jsonModel`, and generating a centralized
/// JsonFactory class with type-safe parsing methods.
/// 
/// The builder can be configured via build.yaml:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       json_factory_generator:jsonFactoryBuilder:
///         options:
///           output_path: lib/generated  # Where to place the generated file
///           output_file_name: json_factory  # Name of generated file (without .dart)
/// ```
Builder jsonFactoryBuilder(BuilderOptions options) {
  return JsonFactoryBuilder(options);
}

/// Custom builder that generates a centralized JsonFactory class.
/// 
/// This builder scans the entire project for classes annotated with `@jsonModel`
/// and `@JsonSerializable`, then generates a single JsonFactory class containing
/// all the necessary type mappings and factory functions.
/// 
/// The generated JsonFactory provides:
/// - Type-safe JSON parsing via `JsonFactory.fromJson<T>(json)`
/// - Support for both single objects and lists (List<T>)
/// - Compile-time type checking
/// - No runtime initialization required
/// 
/// Configuration options:
/// - `output_path`: Directory where the factory file is generated (default: "lib")
/// - `output_file_name`: Name of the generated file without extension (default: "json_factory")
class JsonFactoryBuilder implements Builder {
  final BuilderOptions options;
  
  JsonFactoryBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    final outputFileName = options.config['output_file_name'] as String? ?? 'json_factory';
    final outputPath = options.config['output_path'] as String? ?? 'lib';
    
    // Calculate relative path from lib/
    String relativePath;
    if (outputPath == 'lib') {
      relativePath = '$outputFileName.dart';
    } else if (outputPath.startsWith('lib/')) {
      relativePath = '${outputPath.substring(4)}/$outputFileName.dart';
    } else {
      relativePath = '$outputPath/$outputFileName.dart';
    }
    
    return {
      r'$lib$': [relativePath]
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only run for the synthetic input
    if (buildStep.inputId.path != r'lib/$lib$') return;
    
    final outputFileName = options.config['output_file_name'] as String? ?? 'json_factory';
    final outputPath = options.config['output_path'] as String? ?? 'lib';
    
    final generator = JsonFactoryConfigGenerator(
      outputFileName: outputFileName,
      outputPath: outputPath,
    );
    
    final models = await generator.findAnnotatedModels(buildStep);
    
    if (models.isEmpty) {
      log.warning('No @jsonModel classes found');
      return;
    }
    
    // Get package name for generating package imports
    final packageName = buildStep.inputId.package;
    final content = generator.generateFactoryFile(models, packageName);
    
    // Use the configured output path and filename
    final outputFilePath = '$outputPath/$outputFileName.dart';
    
    final outputId = AssetId(
      buildStep.inputId.package,
      outputFilePath,
    );
    
    await buildStep.writeAsString(outputId, content);
  }
}
