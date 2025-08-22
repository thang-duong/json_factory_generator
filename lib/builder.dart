import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/config_generator.dart';

/// Creates and configures the JsonFactory builder
Builder jsonFactoryBuilder(BuilderOptions options) {
  return LibraryBuilder(
    JsonFactoryConfigGenerator(),
    generatedExtension: '.json_factory.dart',
  );
}
