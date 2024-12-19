import 'dart:io';

import 'package:test/test.dart';
import 'package:test_badge_gen/src/test_badge_manager.dart';

void main() {
  const inputPath = 'test_resources/lcov.info';
  const outputPath = 'test_resources/coverage_badge.svg';

  setUp(() async {
    // Setup a dummy lcov.info file
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      inputFile.createSync(recursive: true);
    }
    await inputFile.writeAsString(
      'TN:\nSF:main.dart\nDA:1,1\nend_of_record\n',
    );
  });

  tearDown(() async {
    // Clean up test files
    final outputFile = File(outputPath);
    final inputFile = File(inputPath);
    final dir = Directory('test_resources');
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    if (inputFile.existsSync()) {
      inputFile.deleteSync();
    }
    if (dir.existsSync()) {
      dir.deleteSync();
    }
  });

  test('Action generates a badge file', () async {
    final result = await TestBadgeManager.action(
      inPath: inputPath,
      outPath: outputPath,
    );
    expect(
      result,
      contains('Success: Coverage badge generated at $outputPath'),
    );
    expect(File(outputPath).existsSync(), isTrue);
  });

  test('Fails when input file is missing', () async {
    const missingInputPath = 'missing.lcov.info';
    final result = await TestBadgeManager.action(
      inPath: missingInputPath,
      outPath: outputPath,
    );
    expect(
      result,
      contains("Error: lcov.info file not found at $missingInputPath"),
    );
  });
}
