import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/manager/manager.dart';
import 'package:m_cli_core/m_cli_core.dart';

class DeleteCommand extends BaseCommand {
  final GitSettingManager _gitSettingManager;
  final ZipSettingManager _zipSettingManager;
  final PathSettingManager _pathSettingManager;
  final SettingRepository _settingRepository;

  DeleteCommand({
    required GitSettingManager gitSettingManager,
    required ZipSettingManager zipSettingManager,
    required PathSettingManager pathSettingManager,
    required SettingRepository settingRepository,
  })  : _gitSettingManager = gitSettingManager,
        _zipSettingManager = zipSettingManager,
        _pathSettingManager = pathSettingManager,
        _settingRepository = settingRepository,
        super();

  @override
  String get description => "delete source";

  @override
  String get name => "delete";

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "source",
          help: "source type of the resource template",
          valueHelp: "git/zip/folder",
        ),
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
    final sourceOption = getOptionAt(0);
    final nameOption = getOptionAt(1);
    final source = sourceOption.getArgOption<String?>(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
    final allFlag = getFlagAt(0);
    bool isAllFlagEnable = allFlag.isFlagEnable(argResults: argResults);
    if (isAllFlagEnable) {
      var text = 'Do you want to delete all your config';
      final userConfirm = ConsoleUtils.echoConfirmYnN(message: text);
      if (!userConfirm) {
        ConsoleUtils.echoText(message: "The current setting keep using");
        return;
      } else {
        final allKeys = await _settingRepository.getAllNameSettingsSaved();
        for (var key in allKeys) {
          await _gitSettingManager.deleteSetting(name: key, force: true);
          await _zipSettingManager.deleteSetting(name: key, force: true);
          await _pathSettingManager.deleteSetting(name: key);
        }
      }
      return;
    }
    SourceType sourceType = SourceType.parse(source);
    switch (sourceType) {
      case SourceType.git:
        return _gitSettingManager.deleteSetting(name: name);
      case SourceType.zip:
        return _zipSettingManager.deleteSetting(name: name);
      case SourceType.path:
        return _pathSettingManager.deleteSetting(name: name);
      case SourceType.unknow:
        updateEndingMessage(
          "You haven't input any source! please try m delete --source=<git/zip/folder>",
        );
        return;
    }
  }
}
