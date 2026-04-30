import 'dart:async';
import 'dart:io';

import 'package:json_factory_generator/src/standalone_cli_generator.dart';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  if (args.contains('--version')) {
    stdout.writeln('json_factory_generator CLI');
    return;
  }

  final command = _resolveCommand(args);
  if (command == null) {
    stderr.writeln('Unknown command.');
    _printUsage();
    exitCode = 64;
    return;
  }

  final verbose = args.contains('--verbose') || args.contains('-v');
  if (command == 'generate') {
    final outputPath = _readOptionValue(args, '--output-path');
    final outputFileName = _readOptionValue(args, '--output-file-name');

    final code = await StandaloneCliGenerator.run(
      projectRoot: Directory.current.path,
      outputPath: outputPath,
      outputFileName: outputFileName,
      verbose: verbose,
    );
    exitCode = code;
    return;
  }

  final passthrough = _collectPassthroughArgs(args);
  final runnerArgs = _buildRunnerArgs(command, passthrough);

  if (verbose) {
    stdout.writeln('Running: dart run build_runner ${runnerArgs.join(' ')}');
  }

  final process = await Process.start('dart', [
    'run',
    'build_runner',
    ...runnerArgs,
  ], mode: ProcessStartMode.inheritStdio);

  final code = await process.exitCode;
  exitCode = code;
}

String? _resolveCommand(List<String> args) {
  final nonFlagArgs = args.where((arg) => !arg.startsWith('-')).toList();
  if (nonFlagArgs.isEmpty) return 'build';

  const allowed = {'generate', 'build', 'watch', 'clean'};
  final command = nonFlagArgs.first;
  if (!allowed.contains(command)) return null;
  return command;
}

List<String> _collectPassthroughArgs(List<String> args) {
  const localFlags = {
    '--help',
    '-h',
    '--version',
    '--verbose',
    '-v',
    '--output-path',
    '--output-file-name',
  };
  final passthrough = <String>[];
  var consumedCommand = false;
  var skipNext = false;

  for (final arg in args) {
    if (skipNext) {
      skipNext = false;
      continue;
    }

    if (arg == '--output-path' || arg == '--output-file-name') {
      skipNext = true;
      continue;
    }

    if (localFlags.contains(arg)) continue;

    if (!arg.startsWith('-') && !consumedCommand) {
      consumedCommand = true;
      continue;
    }

    passthrough.add(arg);
  }

  return passthrough;
}

String? _readOptionValue(List<String> args, String key) {
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == key) {
      return args[i + 1];
    }
  }
  return null;
}

List<String> _buildRunnerArgs(String command, List<String> passthrough) {
  final result = <String>[command];

  if (command == 'build' &&
      !passthrough.contains('--delete-conflicting-outputs')) {
    result.add('--delete-conflicting-outputs');
  }

  result.addAll(passthrough);
  return result;
}

void _printUsage() {
  stdout.writeln('''
json_factory_generator CLI

Usage:
  dart run json_factory_generator [command] [options]

Commands:
  generate   Generate json_factory.dart directly
  build      Run build_runner build (default)
  watch      Run build_runner watch
  clean      Run build_runner clean

Options:
  -h, --help                  Show usage
  --version                   Show CLI version info
  -v, --verbose               Print extra logs
  --output-path <path>        Output directory (generate only)
  --output-file-name <name>   Output file name without .dart (generate only)

Notes:
  - generate mode does not run other builders, so it is faster in mixed-builder packages.
  - For build, --delete-conflicting-outputs is enabled by default.
  - Unknown options are passed through to build_runner for build/watch/clean.
''');
}
