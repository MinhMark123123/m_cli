import 'package:m_cli_core/m_cli_core.dart';
import 'package:test_badge_gen/src/test_badge_manager.dart';
/// A command to generate a test coverage badge in SVG format from an `lcov.info` file.
///
/// The `GeneratorCommand` reads an `lcov.info` file and generates a badge (SVG file)
/// representing test coverage. The input and output paths can be specified through
/// command-line options.
///
/// ### Command Options:
/// - **`--in` (required):** Specifies the input path to the `lcov.info` file.
/// - **`--out` (optional):** Specifies the output path for the generated badge file.
///   Defaults to a file named `coverage_badge.svg` in the current directory if not provided.
///
/// ### Example Usage:
/// ```bash
/// dart run your_tool gen --in=path/to/lcov.info --out=path/to/output_badge.svg
/// ```
/// If `--out` is omitted:
/// ```bash
/// dart run your_tool gen --in=path/to/lcov.info
/// # Generates `coverage_badge.svg` in the current directory.
/// ```
///
/// This command relies on the `TestBadgeManager` to process the input and generate the badge.
class GeneratorCommand extends BaseCommand {
  /// Default file name for the output badge when no `--out` is specified.
  static String defaultSVGFile = "coverage_badge.svg";
  ///default constructor
  GeneratorCommand():super();
  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "in",
          help: "The input path to the lcov.info file (required).",
          valueHelp: 'path',
          isMandatory: true,
        ),
        CommandOption(
          name: "out",
          help:
              "The output path for the generated badge file. Defaults to creating a file named `$defaultSVGFile` in the current directory if not specified.",
          valueHelp: 'path',
        ),
      ];

  @override
  String get description => "Generate a test coverage badge (SVG format) from an lcov.info file.";

  @override
  String get name => "gen";

  @override
  Future<void> onCommandExecuted() async {
    // Retrieve the input and output options.
    final optionIn = getOptionAt(0);
    final optionOut = getOptionAt(1);

    final inputPath = optionIn.getArgOption<String>(argResults: argResults);
    final outputPath = optionOut.getArgOption<String?>(argResults: argResults);

    // Validate the input path.
    if (inputPath == null || inputPath.isEmpty) {
      updateEndingMessage(
        "Generator failed! Please provide a valid path to the lcov.info file using the `--in` option.",
      );
      return;
    }

    // Invoke the badge generation logic using the `TestBadgeManager`.
    final result = await TestBadgeManager.action(
      inPath: inputPath,
      outPath: outputPath ?? defaultSVGFile,
    );

    // Display the result of the operation.
    updateEndingMessage(result);
  }
}
