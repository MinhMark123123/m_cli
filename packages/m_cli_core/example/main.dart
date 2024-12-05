import 'package:args/command_runner.dart';
import 'package:m_cli_core/m_cli_core.dart';

void main(List<String> arguments) async {
  var runner = CommandRunner(
    'badge-test',
    'CLI arc supporter generator test coverage badge',
  )
    ..addCommand(ExampleCommand())
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Noisy logging, including all shell commands executed.',
    );
  await runner.run(arguments);
}

class ExampleCommand extends BaseCommand {
  ExampleCommand() : super();

  @override
  String get description => "echo text";

  @override
  String get name => "echo";

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "text",
          help: "The input text to echo (required).",
          valueHelp: 'text',
          isMandatory: true,
        )
      ];

  @override
  Future<void> onCommandExecuted() async {
    final optionIn = getOptionAt(0);
    final inputText = optionIn.getArgOption<String>(argResults: argResults);

    ConsoleUtils.echoText(message: inputText ?? "");
    updateEndingMessage("Your text has been echo");
  }
}
