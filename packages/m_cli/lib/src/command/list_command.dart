import 'package:m_cli/src/const/texts.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/model/setting_data.dart';
import 'package:m_cli_core/m_cli_core.dart';

class ListCommand extends BaseCommand {
  final SettingRepository _settingRepository;

  ListCommand({required SettingRepository settingRepository})
      : _settingRepository = settingRepository;

  @override
  String get description =>
      "Displays all saved templates along with their details (name, source, and link/path)";

  @override
  String get name => "list";

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "name",
          help: "The name of the saved template to use.",
          valueHelp: "your setting name",
        ),
      ];

  @override
  List<Flag> get provideFlags => [
        Flag(
          name: 'all',
          abbr: 'a',
          help: 'Get information of all of the setting used',
        ),
      ];

  @override
  Future<void> onCommandExecuted() async {
    final allFlag = getFlagAt(0);
    final nameOption = getOptionAt(0);
    bool isAllFlagEnable = allFlag.isFlagEnable(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
    final keys = await _settingRepository.getAllNameSettingsSaved();
    if (keys.isEmpty) {
      updateEndingMessage(
        "There are no setting saved. Please try ${Texts.defaultSetupCLI}",
        type: TextType.warn,
      );
      return;
    }
    if (isAllFlagEnable || name == null || name.isEmpty) {
      await _handleListAll(keys.toList());
      return;
    }
    await _handleListAll(keys.toList().where((e) => e.contains(name)).toList());
  }

  Future<void> _handleListAll(List<String> keys) async {
    for(var i = 0; i < keys.length; i++){
      final key = keys[i];
      final setting = await _settingRepository.getSettingData(name: key);
      final text = setting?.prettyText();
      if(text?.isNotEmpty == true){
        ConsoleUtils.echoTextLine(messageLine: Texts.lineSlash);
        ConsoleUtils.echoTextLine(
          messageLine: "name: $keys\n$text",
        );
        ConsoleUtils.echoTextLine(messageLine: Texts.lineSlash);
      }

    }
  }
}
