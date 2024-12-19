import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/const/prefs_key.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/model/use.dart';
import 'package:m_cli_core/m_cli_core.dart';

class UseComand extends BaseCommand {
  SettingRepository _settingRepository;

  UseComand({
    required SettingRepository settingRepository,
  })  : _settingRepository = settingRepository,
        super();

  @override
  String get description => "Define which template current used";

  @override
  String get name => "use";

  @override
  List<Flag> get provideFlags => [
        Flag(
          name: "info",
          abbr: "i",
          help: "Show the current use information",
        ),
      ];

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "name",
          help: "The name of the saved template to use.",
          valueHelp: "your setting name",
        ),
        CommandOption(
          name: "source",
          help: "source type of the resource template",
          valueHelp: "git/zip/folder",
        ),
      ];

  @override
  Future<void> onCommandExecuted() async {
    final flagInfo = getFlagAt(0);
    final sourceOption = getOptionAt(0);
    final nameOption = getOptionAt(1);
    final source = sourceOption.getArgOption<String?>(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
    bool flagAllEnable = flagInfo.isFlagEnable(argResults: argResults);
    if (flagAllEnable) {
      await _handlePrintOutCurrentUse();
      return;
    }
    await _settingRepository.saveUse(
      Use(name: name, source: SourceType.parse(source)),
    );
  }

  Future<void> _handlePrintOutCurrentUse() async {
    final use = await _settingRepository.getCurrentUse();
    final keys = await _settingRepository.getAllNameSettingsSaved();
    if (keys.length == 1 && keys.first.contains(Keys.defaultKey)) {
      ConsoleUtils.echoLine(
        messageLine:
            "Current default setting is used. To get more information please try m list --name=${Keys.defaultKey}",
      );
      return;
    }
    if (use == null) {
      updateEndingMessage("There are no current used");
      return;
    }
    ConsoleUtils.echoLine(
      messageLine: "Current setting used: ${use.name} source=${use.source}",
    );
  }
}
