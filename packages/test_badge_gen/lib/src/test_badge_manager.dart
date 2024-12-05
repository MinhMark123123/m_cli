import 'dart:convert';
import 'dart:io';

/// A utility class for generating a test coverage badge in SVG format.
///
/// The `TestBadgeManager` processes an `lcov.info` file to extract test coverage
/// data and generates a corresponding badge in SVG format.
///
/// ### Example Usage:
/// ```dart
/// final result = await TestBadgeManager.action(
///   inPath: 'path/to/lcov.info',
///   outPath: 'path/to/coverage_badge.svg',
/// );
/// print(result); // Output: Success or error message
/// ```
class TestBadgeManager {
  /// Private constructor to prevent instantiation.
  TestBadgeManager._();

  /// Processes the input `lcov.info` file and generates a badge in SVG format.
  ///
  /// #### Parameters:
  /// - **`inPath` (required):** The path to the input `lcov.info` file containing test coverage data.
  /// - **`outPath` (required):** The path where the generated SVG badge will be saved.
  ///
  /// #### Returns:
  /// A `Future<String>` that completes with a success message if the operation
  /// is successful, or an error message if the operation fails.
  static Future<String> action({
    required String inPath,
    required String outPath,
  }) async {
    final lcovFilePath = inPath; // Path to the lcov.info file
    final badgeOutputPath = outPath; // Path to save the badge SVG
    if (inPath.isEmpty) {
      return "Error: Input path is empty. Please provide a valid path to the lcov.info file.";
    }
    if (outPath.isEmpty) {
      return "Error: Output path is empty. Please provide a valid path to save the SVG badge.";
    }
    if (!outPath.endsWith(".svg")) {
      return "Error: output path must end with .svg ";
    }
    if (!inPath.endsWith("lcov.info")) {
      return "Error: lcov.info file not found at $lcovFilePath";
    }
    // Ensure the lcov.info file exists
    final lcovFile = File(lcovFilePath);
    if (!await lcovFile.exists()) {
      return 'Error: lcov.info file not found at $lcovFilePath';
    }

    // Read the lcov.info content
    final lcovContent = await lcovFile.readAsString();
    var coveragePercentage = 0.0;
    try {
      coveragePercentage = _calculateCoveragePercentage(lcovContent);
    } catch (e) {
      return e.toString();
    }
    // Generate the badge SVG
    final badgeSvg = _generateBadgeSvg(coveragePercentage);

    // Save the badge to a file
    final badgeFile = File(badgeOutputPath);
    await badgeFile.writeAsString(badgeSvg);

    return "Success: Coverage badge generated at $badgeOutputPath";
  }

  static double _calculateCoveragePercentage(String lcovContent) {
    final lines = LineSplitter.split(lcovContent);

    int totalLines = 0;
    int coveredLines = 0;

    for (final line in lines) {
      if (line.startsWith('DA:')) {
        totalLines++;
        final data = line.split(',');
        if (int.parse(data[1]) > 0) {
          coveredLines++;
        }
      }
    }

    if (totalLines == 0) {
      throw ('Error: No coverage data found in lcov.info');
    }

    return (coveredLines / totalLines) * 100;
  }

  static String _generateBadgeSvg(double coverage) {
    final coverageInt = coverage.round();
    final coverageColor = _getCoverageColor(coverageInt);

    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="150" height="20" role="img" aria-label="coverage: $coverageInt%">
  <title>Coverage: $coverageInt%</title>
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="a">
    <rect width="150" height="20" rx="3" fill="#fff"/>
  </clipPath>
  <g clip-path="url(#a)">
    <rect width="90" height="20" fill="#555"/>
    <rect x="90" width="60" height="20" fill="$coverageColor"/>
    <rect width="150" height="20" fill="url(#b)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="Verdana, Geneva, sans-serif" font-size="11">
    <text x="45" y="15" fill="#010101" fill-opacity=".3">coverage</text>
    <text x="45" y="14">coverage</text>
    <text x="120" y="15" fill="#010101" fill-opacity=".3">$coverageInt%</text>
    <text x="120" y="14">$coverageInt%</text>
  </g>
</svg>
  ''';
  }

  static String _getCoverageColor(int coverage) {
    if (coverage > 95) {
      return '#4c1'; // Good
    } else if (coverage >= 90) {
      return '#a3c51c'; // Acceptable
    } else if (coverage >= 75) {
      return '#dfb317'; // Medium
    } else if (coverage > 0) {
      return '#e05d44'; // Low
    } else {
      return '#9f9f9f'; // Unknown (no coverage)
    }
  }
}
