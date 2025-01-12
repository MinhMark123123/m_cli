import 'package:m_cli_core/m_cli_core.dart';

class InjectCommand extends BaseCommand {
  InjectCommand() : super();

  @override
  String get description => "Inject whatever";

  @override
  String get name => "inject";

  @override
  Future<void> onCommandExecuted() async {
    updateEndingMessage("In development", type: TextType.warn);
  }
}
