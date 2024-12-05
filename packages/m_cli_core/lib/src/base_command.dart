import 'package:args/command_runner.dart';
import 'package:m_cli_core/src/command_options.dart';
import 'package:m_cli_core/src/const/text.dart';
import 'package:m_cli_core/src/utils/console_utils.dart';

/// Base class for creating custom command-line commands.
///
/// This class extends the `Command` class from the `args` package, providing
/// additional functionality for managing options, subcommands, and custom execution logic.
abstract class BaseCommand extends Command {
  /// Stores the ending message to be displayed after the command is executed.
  String? _descriptionEnding;

  /// List of options provided by the command.
  late List<CommandOption> _options;

  /// Returns a list of command options to be registered for the command.
  ///
  /// Override this in your custom command to specify the options available.
  List<CommandOption> get provideOptions => [];

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

    // Add options to the argument parser.
    for (var op in provideOptions) {
      argParser.addOption(op.name, help: op.help, valueHelp: op.valueHelp);
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
    ConsoleUtils.echoLine(messageLine: Texts.runningCommand("${_baseCommandName()}"));
    await onCommandExecuted();
    if (_descriptionEnding != null) {
      ConsoleUtils.echoLine(messageLine: _descriptionEnding!);
    }
    ConsoleUtils.echoLine(messageLine: Texts.thanksForUsingCommand("${_baseCommandName()}"));
  }

  String _baseCommandName() => invocation.replaceAll(" [arguments]", "");

  /// Updates the ending message to be displayed after the command's execution.
  ///
  /// - [message]: The message to set as the ending message.
  ///   Pass `null` to clear the ending message.
  void updateEndingMessage(String? message) => _descriptionEnding = message;
}