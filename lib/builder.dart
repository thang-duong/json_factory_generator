import 'package:build/build.dart';
import 'src/config_generator.dart';

/// Creates and configures the JsonFactory builder
Builder jsonFactoryBuilder(BuilderOptions options) {
  return JsonFactoryBuilder(options);
}

/// Custom builder that generates json_factory.dart in configured directory
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
