import 'package:args/command_runner.dart';
import 'package:m_cli/src/command/command.dart';
import 'package:m_cli/src/data/data.dart';
import 'package:m_cli/src/data/data_manager.dart';
import 'package:m_cli/src/manager/manager.dart';

void main(List<String> arguments) async {
  final settingRepository = SettingRepository(manager: DataManager());
  final gitSettingManager = GitSettingManager(
    settingRepository: settingRepository,
  );
  final zipSettingManager = ZipSettingManager(
    settingRepository: settingRepository,
  );
  final pathSettingManager = PathSettingManager(
    settingRepository: settingRepository,
  );
  var runner = CommandRunner(
    'badge-test',
    'CLI arc supporter generator test coverage badge',
  )
    ..addCommand(
      SetupCommand(
        gitSettingManager: gitSettingManager,
        zipSettingManager: zipSettingManager,
        pathSettingManager: pathSettingManager,
      ),
    )
    ..addCommand(
      SyncComand(
        gitSettingManager: gitSettingManager,
        zipSettingManager: zipSettingManager,
        settingRepository: settingRepository,
      ),
    )
    ..addCommand(
      DeleteCommand(
        gitSettingManager: gitSettingManager,
        zipSettingManager: zipSettingManager,
        pathSettingManager: pathSettingManager,
      ),
    )
    ..addCommand(
      ListCommand(settingRepository: settingRepository),
    )
    ..addCommand(
      UseComand(settingRepository: settingRepository),
    )
    ..addCommand(
      CreateCommand(
        settingRepository: settingRepository,
        gitSettingManager: gitSettingManager,
        zipSettingManager: zipSettingManager,
        pathSettingManager: pathSettingManager,
      ),
    )
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Noisy logging, including all shell commands executed.',
    );
  await runner.run(arguments);
}
