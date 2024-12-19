import 'package:m_cli/src/data/setting_repository.dart';
import 'package:m_cli/src/manager/manager.dart';
import 'package:m_cli/src/util/setting_utils.dart';
import 'package:m_cli_core/m_cli_core.dart';

class CreateCommand extends BaseCommand {
  final GitSettingManager _gitSettingManager;
  final ZipSettingManager _zipSettingManager;
  final PathSettingManager _pathSettingManager;
  final SettingRepository _settingRepository;

  CreateCommand({
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
  String get description =>
      "Create command with the template you have created and setting";

  @override
  String get name => "create";

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "output",
          help: "The name of the saved template to use.",
          valueHelp: "path",
        ),
      ];

  @override
  Future<void> onCommandExecuted() async {
    final outputOption = getOptionAt(0);
    final outputPath = outputOption.getArgOption<String?>(
      argResults: argResults,
    );
    final use = await _settingRepository.getCurrentUse();
    final keys = await _settingRepository.getAllNameSettingsSaved();
    if (keys.isEmpty) {
      updateEndingMessage(
        "No setting founded. Please setup first",
        type: TextType.warn,
      );
      return;
    }
    if (SettingUtils.isUsingDefaultSetting(keysSetting: keys.toList())) {
      await _handleSetting(keysSetting: keys.first, outputPath: outputPath);
      return;
    }
    if (use?.name?.isNotEmpty == true) {
      await _handleSetting(keysSetting: use!.name!, outputPath: outputPath);
      return;
    }
    updateEndingMessage(
      "You has multiple settings! You must select which setting used first. Try m use <your_setting_name>",
    );
  }

  Future<void> _handleSetting({
    required String keysSetting,
    String? outputPath,
  }) async {
    final setting = await _settingRepository.getSettingData(name: keysSetting);
    if (setting?.git != null) {
      final result = await _gitSettingManager.create(
        key: keysSetting,
        outputPath: outputPath,
      );
      updateEndingMessage(result.$1, type: result.$2);
      return;
    }
    if (setting?.zip != null) {
      final result = await _zipSettingManager.create(
        key: keysSetting,
        outputPath: outputPath,
      );
      updateEndingMessage(result.$1, type: result.$2);

      return;
    }
    if (setting?.path != null) {
      final result = await _pathSettingManager.create(
        key: keysSetting,
        outputPath: outputPath,
      );
      updateEndingMessage(result.$1, type: result.$2);
      return;
    }
  }
}
