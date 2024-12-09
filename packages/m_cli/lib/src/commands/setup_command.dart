import 'package:m_cli/src/data/data.dart';
import 'package:m_cli_core/m_cli_core.dart';

class SetupCommand extends BaseCommand {
  final SettingRepository settingRepository;

  SetupCommand({required this.settingRepository}) : super();

  @override
  List<CommandOption> get provideOptions => [
        CommandOption(
          name: "git",
          help: "link of source git",
          valueHelp: "url",
        ),
        CommandOption(
          name: "link",
          help: "Link to download the zip resource",
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
      ];

  @override
  String get description => "Setup the data source of the template you want to";

  @override
  String get name => "setUp";

  @override
  Future<void> onCommandExecuted() async {
    // git
    final gitOption = getOptionAt(0);
    final branchOption = getOptionAt(3);
    final commitOption = getOptionAt(4);

    final git = gitOption.getArgOption<String?>(argResults: argResults);
    final branch = branchOption.getArgOption<String?>(argResults: argResults);
    final commit = commitOption.getArgOption<String?>(argResults: argResults);
    if (git != null && git.isNotEmpty) {
      final currentGitSetting = await settingRepository.getGitSetting();
      final gitSetting = GitSettingData(
        url: git,
        branch: branch,
        commit: commit,
      );
      await settingRepository.saveGitSetting(gitSetting);
      return;
    }
    // zip
    final zipOption = getOptionAt(1);
    final zipLinkDownload = zipOption.getArgOption<String?>(
      argResults: argResults,
    );
    //folder
    final folderOption = getOptionAt(2);
    final folderPath = folderOption.getArgOption<String?>(
      argResults: argResults,
    );

    updateEndingMessage(
      "You haven't input any source. Please try to add some source by git or provide zip link download or ",
    );
  }
}
