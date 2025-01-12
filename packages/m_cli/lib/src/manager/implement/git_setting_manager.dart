import 'dart:io';

import 'package:m_cli/src/const/prefs_key.dart';
import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/model/git_setting_data.dart';
import 'package:m_cli/src/manager/base_creator.dart';
import 'package:m_cli/src/util/file_utils.dart';
import 'package:m_cli_core/m_cli_core.dart';

class GitSettingManager extends BaseCreator {
  GitSettingManager({required super.settingRepository});

  Future<(String?, TextType?)> handleNewSetting({
    String? name,
    required GitSettingData setting,
  }) async {
    if (setting.url == null || setting.url!.isEmpty) {
      return (
        "You haven't input you remote link. Please try : m setup --source=git --link=<your remote link>",
        TextType.warn,
      );
    }
    final currentSetting = await settingRepository.getGitSetting(name: name);
    if (currentSetting != null) {
      String textCurrentConfig = composeTextSetting(currentSetting);
      var textOverwriteConfig =
          'Do you want to overwrite your old git config : $textCurrentConfig';
      final userConfirm = ConsoleUtils.echoConfirmYnN(
        message: textOverwriteConfig,
      );
      if (!userConfirm) {
        return (
          "Exit setup! The current setting keep using $textCurrentConfig",
          TextType.normal,
        );
      }
      await deleteSetting(name: name, force: true);
      return insertNewSetting(name: name, setting: setting);
    }
    return insertNewSetting(name: name, setting: setting);
  }

  Future<(String?, TextType?)> insertNewSetting({
    required String? name,
    required GitSettingData setting,
  }) async {
    await settingRepository.saveGitSetting(name: name, value: setting);
    if (name != null) {
      return (
        "Your new setting has saved \nname: $name \nconfig:${composeTextSetting(setting)}",
        TextType.success,
      );
    }
    return (
      "Your new setting has saved: ${composeTextSetting(setting)}",
      TextType.success,
    );
  }

  String composeTextSetting(GitSettingData textSetting) {
    var textCurrentConfig = "${textSetting.url}";
    if (textSetting.branch != null && textSetting.branch!.isNotEmpty) {
      textCurrentConfig = "$textCurrentConfig , branch: ${textSetting.branch}";
    }
    if (textSetting.commit != null && textSetting.commit!.isNotEmpty) {
      textCurrentConfig = "$textCurrentConfig , commit: ${textSetting.commit}";
    }
    return textCurrentConfig;
  }

  Future<GitSettingData?> getSetting({String? name}) async {
    final setting = settingRepository.getGitSetting(name: name);
    return setting;
  }

  Future<void> deleteSetting({String? name, bool force = false}) async {
    if (!force) {
      var text = 'Do you want to delete your old git config';
      final userConfirm = ConsoleUtils.echoConfirmYnN(
        message: text,
      );
      if (!userConfirm) {
        ConsoleUtils.echoText(message: "The current setting keep using");
        return;
      }
    }
    await settingRepository.removeSettingGit(name: name);
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.git,
    );
    final gitDir = Directory(dirPath);
    if (!gitDir.existsSync()) {
      gitDir.deleteSync(recursive: true);
    }
    ConsoleUtils.echoText(message: "Your git config has been deleted");
  }

  Future<void> sync({String? name}) async {
    final gitSetting = await getSetting(name: name);
    if (gitSetting == null && name != Keys.defaultKey) {
      ConsoleUtils.echoLineError("There are no git config $name");
    }
    if (gitSetting == null) {
      return;
    }
    ConsoleUtils.echoLine("Running sync git: ${gitSetting.url}");
    final dirPath = await FileUtils.getFileDir(
      name: name,
      type: SourceType.git,
    );
    final gitDir = Directory(dirPath);
    bool isFirstTime = false;
    if (!gitDir.existsSync()) {
      gitDir.createSync(recursive: true);
      isFirstTime = true;
      ConsoleUtils.echoLine("Create new dir: ${gitDir.path}");
    }
    final project = await gitDir.list().first;
    final workTree = [
      "--git-dir=${project.path}",
      "--work-tree=${project.path}",
    ];
    //
    try {
      if (!isFirstTime) {
        //move to path
        Process.runSync("git", ["fetch", "origin"]);
        Process.runSync(
          "git",
          [
            ...workTree,
            "pull",
            "origin",
          ],
        );
        ConsoleUtils.echoLineSucceed("Sync git succeed");
        return;
      }
      Process.runSync("git", [
        "clone",
        "${gitSetting.url}",
        gitDir.path,
      ]);
      ConsoleUtils.echoLineSucceed("Cloned project to: ${gitDir.path}");
      Process.runSync("git", [
        ...workTree,
        "fetch",
        "origin",
      ]);
      ConsoleUtils.echoLine("Fetched origin: ${project.path}");
      if (gitSetting.commit?.isNotEmpty == true) {
        Process.runSync("git", [
          ...workTree,
          "checkout",
          gitSetting.commit!,
        ]);
        ConsoleUtils.echoLine("Checkout commit: ${gitSetting.commit}");
        return;
      }
      if (gitSetting.branch?.isNotEmpty == true) {
        Process.runSync("git", [
          ...workTree,
          "checkout",
          gitSetting.branch!,
        ]);
        ConsoleUtils.echoLine("Checkout branch: ${gitSetting.branch}");
        Process.runSync("git", [
          ...workTree,
          "pull",
          "origin",
        ]);
        ConsoleUtils.echoLine(
          "Pull origin: ${gitSetting.branch} ${project.path}",
        );
      }
      ConsoleUtils.echoLineSucceed("Sync git succeed");
    } catch (e) {
      ConsoleUtils.echoLineError(
        "Failed execute git command. Please check if you haven't install git cli",
      );
    }
  }
}
