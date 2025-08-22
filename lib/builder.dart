import 'package:build/build.dart';
import 'src/config_generator.dart';

/// Creates and configures the JsonFactory builder
Builder jsonFactoryBuilder(BuilderOptions options) {
  return JsonFactoryBuilder(options);
}

/// Custom builder that generates json_factory.dart in lib/ directory
class JsonFactoryBuilder implements Builder {
  final BuilderOptions options;
  
  JsonFactoryBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['json_factory.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only run for the synthetic input
    if (buildStep.inputId.path != r'lib/$lib$') return;
    
    final generator = JsonFactoryConfigGenerator(
      outputFileName: options.config['output_file_name'] as String? ?? 'json_factory',
      outputPath: options.config['output_path'] as String? ?? 'lib',
    );
    
    final models = await generator.findAnnotatedModels(buildStep);
    
    if (models.isEmpty) {
      log.warning('No @jsonModel classes found');
      return;
    }
    
    final content = generator.generateFactoryFile(models);
    
    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/json_factory.dart',
    );
    
    await buildStep.writeAsString(outputId, content);
  }
}
