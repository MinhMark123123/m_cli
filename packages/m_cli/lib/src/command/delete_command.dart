import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/manager/manager.dart';
import 'package:m_cli_core/m_cli_core.dart';

class DeleteCommand extends BaseCommand {
  final GitSettingManager _gitSettingManager;
  final ZipSettingManager _zipSettingManager;
  final PathSettingManager _pathSettingManager;

  DeleteCommand({
    required GitSettingManager gitSettingManager,
    required ZipSettingManager zipSettingManager,
    required PathSettingManager pathSettingManager,
  })  : _gitSettingManager = gitSettingManager,
        _zipSettingManager = zipSettingManager,
        _pathSettingManager = pathSettingManager,
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
  Future<void> onCommandExecuted() async {
    final sourceOption = getOptionAt(0);
    final nameOption = getOptionAt(1);
    final source = sourceOption.getArgOption<String?>(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
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
