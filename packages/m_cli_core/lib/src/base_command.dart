import 'package:args/command_runner.dart';
import 'package:m_cli_core/src/command_options.dart';
import 'package:m_cli_core/src/const/text.dart';
import 'package:m_cli_core/src/flag.dart';
import 'package:m_cli_core/src/utils/console_utils.dart';

/// Base class for creating custom command-line commands.
///
/// This class extends the `Command` class from the `args` package, providing
/// additional functionality for managing options, subcommands, and custom execution logic.
abstract class BaseCommand extends Command {
  /// Stores the ending message to be displayed after the command is executed.
  (TextType, String?)? _descriptionEnding;

  /// List of options provided by the command.
  late List<CommandOption> _options;

  /// Returns a list of command options to be registered for the command.
  ///
  /// Override this in your custom command to specify the options available.
  List<CommandOption> get provideOptions => [];

  /// List of flag provided by the command
  late List<Flag> _flags;

  /// Returns a list of command flags to be registered for the command.
  ///
  /// Override this in your custom command to specify the flags available.
  List<Flag> get provideFlags => [];

  /// Returns a list of subcommands to be added to this command.
  ///
  /// Override this in your custom command to add subcommands.
  List<Command> get subCommands => [];

  /// Constructor for `BaseCommand`.
  ///
  /// - Registers the options and subcommands defined in the overridden
  ///   [provideOptions] and [subCommands] getters.
  BaseCommand() {
    _options = provideOptions;
    _flags = provideFlags;
    // Add options to the argument parser.
    for (var op in _options) {
      argParser.addOption(op.name, help: op.help, valueHelp: op.valueHelp);
    }
    //
    for (var flag in _flags) {
      argParser.addFlag(flag.name, abbr: flag.abbr, help: flag.help);
    }

    // Add subcommands to the command.
    for (var sub in subCommands) {
      addSubcommand(sub);
    }
  }

  /// Retrieves a specific [CommandOption] by its index in the `_options` list.
  ///
  /// - [index]: The index of the option to retrieve.
  ///
  /// Throws a `RangeError` if the index is out of bounds.
  CommandOption getOptionAt(int index) => _options[index];

  /// Retrieves a specific [Flag] by its index in the `_flags` list.
  ///
  /// - [index]: The index of the option to retrieve.
  ///
  /// Throws a `RangeError` if the index is out of bounds.
  Flag getFlagAt(int index) => _flags[index];

  /// Executes the main logic of the command.
  ///
  /// Override this method in your custom command to define its behavior.
  Future<void> onCommandExecuted();

  /// Runs the command, executing its logic and displaying appropriate messages.
  ///
  /// This method:
  /// 1. Displays a message indicating that the command is running.
  /// 2. Calls [onCommandExecuted] to perform the command's logic.
  /// 3. Displays an ending message if one has been set.
  /// 4. Displays a "thank you" message for using the command.
  @override
  Future<void> run() async {
    ConsoleUtils.echoLine(
      messageLine: Texts.runningCommand(_baseCommandName()),
    );
    await onCommandExecuted();
    if (_descriptionEnding != null && _descriptionEnding!.$2 != null) {
      ConsoleUtils.echoLine(
        type: _descriptionEnding!.$1,
        messageLine: _descriptionEnding!.$2!,
      );
    }
    ConsoleUtils.echoLine(
      messageLine: Texts.thanksForUsingCommand(_baseCommandName()),
    );
  }

  String _baseCommandName() => invocation.replaceAll(" [arguments]", "");

  /// Updates the ending message to be displayed after the command's execution.
  ///
  /// - [message]: The message to set as the ending message.
  ///   Pass `null` to clear the ending message.
  void updateEndingMessage(
    String? message, {
    TextType? type,
  }) {
    if (message == null) return;
    _descriptionEnding = (type ?? TextType.normal, message);
  }
}
