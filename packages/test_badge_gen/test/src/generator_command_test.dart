import 'dart:io';
import 'package:test/test.dart';

import '../main_shadow.dart' as mainer;

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
    final defaultPath = File("coverage_badge.svg");
    final dir = Directory('test_resources');
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    if (defaultPath.existsSync()) {
      defaultPath.deleteSync();
    }
    if (inputFile.existsSync()) {
      inputFile.deleteSync();
    }
    if (dir.existsSync()) {
      dir.deleteSync();
    }
  });

  test('Executes successfully with valid options', () async {
    await mainer.main(["gen", "--in=$inputPath", "--out=$outputPath"]);
    // Ensure the badge file is created
    final outputFile = File('test_resources/coverage_badge.svg');
    expect(outputFile.existsSync(), isTrue);
  });

  test('Fails when input path is missing', () async {
    await mainer.main(["gen", "--in=$inputPath"]);
    // Ensure the badge file is created
    final outputFile = File('coverage_badge.svg');
    expect(outputFile.existsSync(), isTrue);
  });
}
