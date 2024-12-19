import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/manager/manager.dart';
import 'package:m_cli/src/util/setting_utils.dart';
import 'package:m_cli_core/m_cli_core.dart';

class SyncComand extends BaseCommand {
  final GitSettingManager _gitSettingManager;
  final ZipSettingManager _zipSettingManager;
  final SettingRepository _settingRepository;

  SyncComand({
    required GitSettingManager gitSettingManager,
    required ZipSettingManager zipSettingManager,
    required SettingRepository settingRepository,
  })  : _gitSettingManager = gitSettingManager,
        _zipSettingManager = zipSettingManager,
        _settingRepository = settingRepository,
        super();

  @override
  String get description =>
      "sync up setting to the remote default sync all git and zip";

  @override
  String get name => "sync";

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
          valueHelp: "git/zip",
        ),
      ];

  @override
  List<Flag> get provideFlags => [
        Flag(
          name: 'all',
          abbr: 'a',
          help: 'Sync all setting saved',
        ),
      ];

  @override
  Future<void> onCommandExecuted() async {
    final allFlag = getFlagAt(0);
    final sourceOption = getOptionAt(0);
    final nameOption = getOptionAt(1);
    bool isAllFlagEnable = allFlag.isFlagEnable(argResults: argResults);
    final source = sourceOption.getArgOption<String?>(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
    SourceType sourceType = SourceType.parse(source);
    final keys = await _settingRepository.getAllNameSettingsSaved();
    final use = await _settingRepository.getCurrentUse();
    if (isAllFlagEnable) {
      for (var key in keys) {
        await _syncWithSource(sourceType, key: key);
      }
      updateEndingMessage("Finished sync all setting");
      return;
    }
    if (SettingUtils.isUsingDefaultSetting(keysSetting: keys.toList())) {
      await _syncWithSource(sourceType);
      updateEndingMessage("Finished sync default setting");
      return;
    }
    if (use?.name?.isNotEmpty == true && name == null) {
      await _syncWithSource(sourceType, key: use!.name);
      updateEndingMessage("Finished sync current used setting: ${use.name}");
      return;
    }
    if (name?.isNotEmpty == true) {
      await _syncWithSource(sourceType, key: name);
      updateEndingMessage("Finished sync name: ");
      return;
    }
    updateEndingMessage("Exit sync");
  }

  Future<void> _syncWithSource(SourceType sourceType, {String? key}) async {
    if (sourceType == SourceType.git) {
      await _gitSettingManager.sync(name: key);
    } else if (sourceType == SourceType.zip) {
      await _zipSettingManager.sync(name: key);
    } else {
      await _gitSettingManager.sync(name: key);
      await _zipSettingManager.sync(name: key);
    }
  }
}
