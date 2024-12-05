import 'package:args/command_runner.dart';
import 'package:test_badge_gen/src/generator_command.dart';

void main(List<String> arguments) async {
  var runner = CommandRunner(
    'badge-test',
    'CLI arc supporter generator test coverage badge',
  )
    ..addCommand(GeneratorCommand())
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Noisy logging, including all shell commands executed.',
    );
  await runner.run(arguments);
}
