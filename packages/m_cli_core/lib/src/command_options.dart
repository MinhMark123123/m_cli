import 'package:args/args.dart';
import 'package:m_cli_core/src/utils/arg_utils.dart';

/// Represents a command-line option for a CLI command.
///
/// This class is used to define command options (flags or arguments) with details such as name, help text,
/// value help (expected format), and whether the option is mandatory.
///
/// ### Example Usage:
/// ```dart
/// CommandOption(
///   name: 'out',
///   help: 'The output path',
///   valueHelp: 'path',
/// );
/// // Result: --out=<path>      The output path
/// ```
class CommandOption {
  /// The name of the command-line option.
  ///
  /// This is the key used in the command-line argument (e.g., `--name`).
  final String name;

  /// The description or help text for the command-line option.
  ///
  /// This text is displayed when the `--help` command is invoked.
  final String help;

  /// Describes the expected format of the option's value (e.g., `<path>`, `<number>`).
  ///
  /// This text is shown alongside the help text to clarify what value should be passed.
  final String valueHelp;

  /// Whether this option is mandatory for the command.
  ///
  /// If `true`, the command will require this option to be provided when executed.
  final bool isMandatory;

  /// Creates a new [CommandOption].
  ///
  /// - [name]: The name of the command option (e.g., `out` for `--out`).
  /// - [help]: A brief description of the option's purpose.
  /// - [valueHelp]: A string describing the expected value of the option.
  /// - [isMandatory]: Whether the option is required (default: `false`).
  CommandOption({
    required this.name,
    required this.help,
    required this.valueHelp,
    this.isMandatory = false,
  });

  /// Retrieves the value of the command-line option from the [ArgResults].
  ///
  /// - [argResults]: The parsed arguments from the command-line input.
  ///
  /// Returns the value of the option if provided, or `null` if not found.
  ///
  /// If [isMandatory] is `true` and the option is not present, this function
  /// is expected to handle errors or notify the user externally.
  ///
  /// ### Example:
  /// ```dart
  /// final option = CommandOption(
  ///   name: 'out',
  ///   help: 'The output path',
  ///   valueHelp: 'path',
  ///   isMandatory: true,
  /// );
  /// final value = option.getArgOption<String>(argResults: args);
  /// ```
  T? getArgOption<T>({ArgResults? argResults}) {
    try {
      return getArg<T?>(
        name,
        argResults,
        isMandatory: isMandatory,
      );
    } catch (e) {
      return null;
    }
  }
}
