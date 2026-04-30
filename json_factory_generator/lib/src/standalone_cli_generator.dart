import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:yaml/yaml.dart';

import 'json_factory_generator_helper.dart';

class StandaloneCliGenerator {
  static Future<int> run({
    required String projectRoot,
    String? outputPath,
    String? outputFileName,
    required bool verbose,
  }) async {
    final rootDir = Directory(projectRoot);
    final libDir = Directory('$projectRoot/lib');

    if (!await rootDir.exists()) {
      stderr.writeln('Project directory does not exist: $projectRoot');
      return 2;
    }

    if (!await libDir.exists()) {
      stderr.writeln('Could not find lib/ directory in: $projectRoot');
      return 2;
    }

    final packageName = await _readPackageName(projectRoot);
    if (packageName == null || packageName.isEmpty) {
      stderr.writeln('Could not read package name from pubspec.yaml');
      return 2;
    }

    final models = await _discoverModels(projectRoot, verbose);
    if (models.isEmpty) {
      stderr.writeln('No @JsonModel/@jsonModel classes with fromJson found.');
      return 1;
    }

    final content = JsonFactoryGeneratorHelper.generateFactoryFile(
      models,
      packageName,
    );

    final buildOptions = await _readBuildOptions(projectRoot);
    final resolvedOutputPath =
        outputPath ?? buildOptions.outputPath ?? 'lib/generated';
    final resolvedOutputFileName =
        outputFileName ?? buildOptions.outputFileName ?? 'json_factory';

    final normalizedOutputPath = _normalizeOutputPath(resolvedOutputPath);
    final outputDir = Directory('$projectRoot/$normalizedOutputPath');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final outputFile = File(
      '$projectRoot/$normalizedOutputPath/$resolvedOutputFileName.dart',
    );
    await outputFile.writeAsString(content);

    stdout.writeln('Generated: ${outputFile.path}');
    stdout.writeln('Models: ${models.length}');
    return 0;
  }

  static Future<_BuildOptions> _readBuildOptions(String projectRoot) async {
    final buildYaml = File('$projectRoot/build.yaml');
    if (!await buildYaml.exists()) return const _BuildOptions();

    try {
      final content = await buildYaml.readAsString();
      final root = loadYaml(content);
      if (root is! YamlMap) return const _BuildOptions();

      final targets = root['targets'];
      if (targets is! YamlMap) return const _BuildOptions();

      final defaultTarget = targets[r'$default'];
      if (defaultTarget is! YamlMap) return const _BuildOptions();

      final builders = defaultTarget['builders'];
      if (builders is! YamlMap) return const _BuildOptions();

      final builderConfig = builders['json_factory_generator:jsonFactoryBuilder'];
      if (builderConfig is! YamlMap) return const _BuildOptions();

      final options = builderConfig['options'];
      if (options is! YamlMap) return const _BuildOptions();

      return _BuildOptions(
        outputPath: options['output_path']?.toString(),
        outputFileName: options['output_file_name']?.toString(),
      );
    } catch (_) {
      return const _BuildOptions();
    }
  }

  static Future<String?> _readPackageName(String projectRoot) async {
    final pubspec = File('$projectRoot/pubspec.yaml');
    if (!await pubspec.exists()) return null;

    final content = await pubspec.readAsString();
    final match = RegExp(
      r'^name\s*:\s*([^\s#]+)',
      multiLine: true,
    ).firstMatch(content);
    return match?.group(1)?.trim();
  }

  static Future<List<ModelInfo>> _discoverModels(
    String projectRoot,
    bool verbose,
  ) async {
    final libDir = Directory('$projectRoot/lib');
    final models = <ModelInfo>[];

    await for (final entity in libDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final relativePath = entity.path.replaceFirst('$projectRoot/', '');
      if (JsonFactoryGeneratorHelper.shouldSkipFile(relativePath)) {
        continue;
      }

      final found = await _modelsInFile(entity, relativePath);
      if (found.isNotEmpty) {
        models.addAll(found);
        if (verbose) {
          for (final model in found) {
            stdout.writeln('Found model: ${model.name} (${model.import})');
          }
        }
      }
    }

    return models;
  }

  static Future<List<ModelInfo>> _modelsInFile(
    File file,
    String relativePath,
  ) async {
    final source = await file.readAsString();
    final result = parseString(content: source, path: file.path);
    final unit = result.unit;
    final models = <ModelInfo>[];

    for (final declaration in unit.declarations) {
      if (declaration is! ClassDeclaration) continue;

      if (!_hasJsonModelAnnotation(declaration)) continue;
      if (!_hasFromJsonFactory(declaration)) continue;

      final className = declaration.name.lexeme;
      models.add(ModelInfo(name: className, import: relativePath));
    }

    return models;
  }

  static bool _hasJsonModelAnnotation(ClassDeclaration classDeclaration) {
    for (final metadata in classDeclaration.metadata) {
      final name = metadata.name.name;
      if (name == 'JsonModel' || name == 'jsonModel') {
        return true;
      }
    }
    return false;
  }

  static bool _hasFromJsonFactory(ClassDeclaration classDeclaration) {
    for (final member in classDeclaration.members) {
      if (member is! ConstructorDeclaration) continue;
      if (member.factoryKeyword == null) continue;
      final constructorName = member.name?.lexeme;
      if (constructorName != 'fromJson') continue;

      final parameters = member.parameters.parameters;
      if (parameters.length != 1) continue;

      final parameter = parameters.first;
      if (parameter is! SimpleFormalParameter) continue;

      final typeSource = parameter.type?.toSource() ?? '';
      if (typeSource == 'Map<String, dynamic>' ||
          typeSource == 'Map<String, Object?>' ||
          typeSource.startsWith('Map<String,')) {
        return true;
      }
    }
    return false;
  }

  static String _normalizeOutputPath(String outputPath) {
    final trimmed = outputPath.trim().replaceAll('\\', '/');
    if (trimmed.isEmpty) return 'lib/generated';
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}

class _BuildOptions {
  final String? outputPath;
  final String? outputFileName;

  const _BuildOptions({
    this.outputPath,
    this.outputFileName,
  });
}
