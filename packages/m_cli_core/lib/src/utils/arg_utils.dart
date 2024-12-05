
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
/// Retrieves a value of a specific type [T] from the parsed command-line arguments.
///
/// This function is used to extract and validate the value of a given command-line option
/// from the [ArgResults]. It ensures that required options are provided and throws appropriate
/// exceptions if conditions are not met.
///
/// ### Parameters:
/// - [name]: The name of the command-line option to retrieve (e.g., `out` for `--out`).
/// - [argResults]: The parsed command-line arguments provided by the user.
/// - [isMandatory]: Whether the option is required (default: `false`).
/// - [usage]: A string containing usage instructions or help text, shown in exception messages.
///
/// ### Returns:
/// The value of the specified option cast to type [T].
///
/// ### Throws:
/// - [UsageException] if:
///   - [argResults] is null.
///   - The option [name] was not parsed.
///   - The option is mandatory but not provided.
///
/// ### Example:
/// ```dart
/// final args = ArgParser()
///   ..addOption('out', help: 'The output file path', valueHelp: 'path');
/// final results = args.parse(['--out', 'output.txt']);
///
/// final outputPath = getArg<String>('out', results, isMandatory: true);
/// print('Output path: $outputPath'); // Output: Output path: output.txt
/// ```
T getArg<T>(String name, ArgResults? argResults,
    {bool isMandatory = false, usage}) {
  if (argResults == null) {
    throw UsageException('The `$name` have no argResults', usage);
  }
  if (argResults.wasParsed(name)) {
    final T arg = argResults[name] as T;
    if (arg == null && isMandatory) {
      throw UsageException('The `$name` is mandatory', usage);
    }
    return arg;
  }
  throw UsageException('The `$name` have no argResults', usage);
}
