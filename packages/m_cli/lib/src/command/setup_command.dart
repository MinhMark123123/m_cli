import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/model/git_setting_data.dart';
import 'package:m_cli/src/manager/manager.dart';
import 'package:m_cli_core/m_cli_core.dart';

class SetupCommand extends BaseCommand {
  final GitSettingManager _gitSettingManager;
  final ZipSettingManager _zipSettingManager;
  final PathSettingManager _pathSettingManager;

  SetupCommand({
    required GitSettingManager gitSettingManager,
    required ZipSettingManager zipSettingManager,
    required PathSettingManager pathSettingManager,
  })  : _gitSettingManager = gitSettingManager,
        _zipSettingManager = zipSettingManager,
        _pathSettingManager = pathSettingManager,
        super();

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "source",
          help: "source type of the resource template",
          valueHelp: "git/zip/folder",
          isMandatory: true,
        ),
        CommandOption(
          name: "url",
          help: "The Url of the source",
          valueHelp: "url",
        ),
        CommandOption(
          name: "folder",
          help: "help",
          valueHelp: "path",
        ),
        CommandOption(
          name: "branch",
          help: "Branch of source",
          valueHelp: "branchName",
        ),
        CommandOption(
          name: "commit",
          help: "The Commit hash you want to point to",
          valueHelp: "commitHash",
        ),
        CommandOption(
          name: "name",
          help: "The name of the saved template to use.",
          valueHelp: "your setting name",
        ),
      ];

  @override
  String get description => "Setup the data source of the template you want to";

  @override
  String get name => "setup";

  @override
  Future<void> onCommandExecuted() async {
    final sourceOption = getOptionAt(0);
    final nameOption = getOptionAt(5);
    final source = sourceOption.getArgOption<String?>(argResults: argResults);
    final name = nameOption.getArgOption<String?>(argResults: argResults);
    SourceType sourceType = SourceType.parse(source);
    switch (sourceType) {
      case SourceType.git:
        return _handleGitSetup(name: name);
      case SourceType.zip:
        return _handleZipSetup(name: name);
      case SourceType.path:
        return _handlePatSetup(name: name);
      case SourceType.unknow:
        updateEndingMessage(
          "You haven't input any source! please try m setup --source=<git/zip/folder>",
          type: TextType.error,
        );
        return;
    }
  }

  Future<void> _handleGitSetup({String? name}) async {
    final linkOptions = getOptionAt(1);
    final branchOption = getOptionAt(3);
    final commitOption = getOptionAt(4);
    final link = linkOptions.getArgOption<String?>(argResults: argResults);
    final branch = branchOption.getArgOption<String?>(argResults: argResults);
    final commit = commitOption.getArgOption<String?>(argResults: argResults);
    final gitSetting = GitSettingData(
      url: link,
      branch: branch,
      commit: commit,
    );
    final lastMessage = await _gitSettingManager.handleNewSetting(
      name: name,
      setting: gitSetting,
    );
    updateEndingMessage(lastMessage.$1, type: lastMessage.$2);
  }

  Future<void> _handleZipSetup({String? name}) async {
    final linkOptions = getOptionAt(1);
    final linkDownload = linkOptions.getArgOption<String?>(
      argResults: argResults,
    );
    final lastMessage = await _zipSettingManager.handleNewSetting(
      name: name,
      setting: linkDownload,
    );
    updateEndingMessage(lastMessage.$1, type: lastMessage.$2);
  }

  Future<void> _handlePatSetup({String? name}) async {
    final pathOptions = getOptionAt(2);
    final path = pathOptions.getArgOption<String?>(
      argResults: argResults,
    );
    final lastMessage =
        await _pathSettingManager.handleNewSetting(name: name, setting: path);
    updateEndingMessage(lastMessage.$1, type: lastMessage.$2);
  }
}
