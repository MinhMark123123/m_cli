import 'dart:convert';
import 'dart:io';
import 'package:m_cli/src/const/cases_type.dart';
import 'package:m_cli/src/data/model/metadata.dart';
import 'package:m_cli/src/data/setting_repository.dart';
import 'package:m_cli/src/util/file_utils.dart';
import 'package:m_cli/src/util/string_util.dart';
import 'package:m_cli_core/m_cli_core.dart';

abstract class BaseCreator {
  final SettingRepository _settingRepository;

  BaseCreator({required SettingRepository settingRepository})
      : _settingRepository = settingRepository;

  SettingRepository get settingRepository => _settingRepository;

  Future<(String, TextType?)> create({
    required String key,
    String? outputPath,
  }) async {
    final setting = await settingRepository.getSettingData(name: key);
    if (setting == null) return ("No setting found", TextType.error);
    final dirPath = await FileUtils.getFileDir(
      name: key,
      type: setting.getAvailableSource(),
    );
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return ("Setting haven't sync yet", TextType.error);
    }
    final createDirPath = await FileUtils.getCreateDir(
      name: key,
      type: setting.getAvailableSource(),
    );
    final createFolder = Directory(createDirPath);
    if (!createFolder.existsSync()) {
      return ("No create folder founded! Please setup", TextType.error);
    }
    final destinationDir = Directory(outputPath ?? "");
    try {
      final templateSelection = await readCreateSelections(
        createDir: createFolder,
      );
      final result = await excutedCreate(
        source: Directory(templateSelection),
        destination: destinationDir,
      );
      return result;
    } catch (e, __) {
      if (e is ReadCreateSelectionException) {
        return (e.message, TextType.error);
      }
      return ("Ops! Create Failed", TextType.error);
    }
  }

  Future<String> readCreateSelections({required Directory createDir}) async {
    final folderList = createDir.listSync();
    final metadataList = folderList
        .map(
          (e) => [e.path, "metadata.json"].join(Platform.pathSeparator),
        )
        .toList();
    metadataList.removeWhere((path) => !File(path).existsSync());
    final optionsMetadata = await Future.wait(metadataList.map((e) async {
      return await readMetadata(e);
    }));
    final optionTitles = optionsMetadata.map((e) => e.name ?? "").toList();
    final selections = ConsoleUtils.echoListOption(
      message:
          'Available templates (use key-up/key-down to navigate, space to select):',
      options: optionTitles,
      isMultipleChoice: false,
    );
    if (selections.isEmpty) {
      ConsoleUtils.echoText(message: "You haven't select any option");
      throw ReadCreateSelectionException("User didn't pick any option");
    }
    final selection = selections.first;
    final indexSelected = optionTitles.indexOf(selection);
    if (indexSelected == -1) {
      throw ReadCreateSelectionException("Selected value index invalid");
    }
    return metadataList[indexSelected].replaceAll("/metadata.json", "");
  }

  Future<(String, TextType)> excutedCreate({
    required Directory source,
    required Directory destination,
  }) async {
    //copy template
    FileUtils.copyDirectorySync(source: source, destination: destination);
    final metadataPath =
        [destination.path, "metadata.json"].join(Platform.pathSeparator);
    final metadata = await readMetadata(metadataPath);
    Map<String, String> variablesMap = {};
    if (metadata.variables?.isNotEmpty == true) {
      for (var e in metadata.variables!) {
        if (e.prompt?.isNotEmpty == true && e.key?.isNotEmpty == true) {
          final input = ConsoleUtils.echoAndRead(
                messageOut: e.prompt ?? "",
                allowNullOrEmptyInput: e.defaultValue?.isNotEmpty == true,
              ) ??
              e.defaultValue;
          variablesMap[e.key!] = input!;
        }
      }
    }
    if (variablesMap.isNotEmpty) {
      _composeContent(variablesMap, destination);
    }
    //delete config data
    deleteUneededContent(metadataPath, destination);
    //print out result
    return ("Create succeed at: ${destination.path}", TextType.success);
  }

  void deleteUneededContent(String metadataPath, Directory destination) {
    FileUtils.deleteFile(metadataPath);
    final listFile = destination.listSync(recursive: true);
    for (var entity in listFile) {
      if (entity is File && entity.path.endsWith(".keep")) {
        FileUtils.deleteFile(entity.path);
      }
    }
  }

  void _composeContent(
    Map<String, String> variablesMap,
    Directory destination,
  ) {
    Map<String, String> variablesMapExtend = {};
    for (var key in variablesMap.values) {
      final listKeys = CaseType.converts(key);
      final values = CaseType.converts(variablesMap[key]!);
      for (var index = 0; index < listKeys.length; index++) {
        variablesMapExtend[listKeys[index]] = values[index];
      }
    }
    final entities = destination.listSync(recursive: true);
    //edit file content
    for (var entity in entities) {
      if (entity is File) {
        var content = entity.readAsStringSync();
        var filePath = entity.path;
        for (var key in variablesMapExtend.values) {
          content = content.replaceAll(
            StringUtil.composePattern(key),
            variablesMapExtend[key]!,
          );
          filePath = filePath.replaceAll(
            StringUtil.composePattern(key),
            variablesMapExtend[key]!,
          );
        }
        if (filePath != entity.path) {
          ConsoleUtils.echoLine(messageLine: "write new file: $filePath");
          FileUtils.writeTextFile(path: filePath, content: content);
          ConsoleUtils.echoLine(messageLine: "delete: ${entity.path}");
          FileUtils.deleteFile(entity.path);
        }
      }
    }
    for (var entity in entities) {
      if (entity is Directory) {
        var dirPath = entity.path;
        for (var key in variablesMapExtend.values) {
          dirPath = dirPath.replaceAll(
            StringUtil.composePattern(key),
            variablesMapExtend[key]!,
          );
        }
        if (dirPath != entity.path) {
          ConsoleUtils.echoLine(messageLine: "write new dir: $dirPath");
          if (!Directory(dirPath).existsSync()) {
            Directory(dirPath).createSync(recursive: true);
          }
          ConsoleUtils.echoLine(messageLine: "delete: ${entity.path}");
          FileUtils.deleteFile(entity.path);
        }
      }
    }
  }

  Future<Metadata> readMetadata(String pathFile) async {
    final metadataRaw = await FileUtils.readStringFromPath(path: pathFile);
    final metadataJson = jsonDecode(metadataRaw);
    return Metadata.fromJson(metadataJson);
  }

  List<String> extractKeys(String template) {
    final regex = RegExp(r'\$\{(\w+)\}'); // Matches ${key}
    return regex.allMatches(template).map((match) => match.group(1)!).toList();
  }

  bool isKeyValid(String key, List<String> validKeys) {
    return validKeys.contains(key);
  }
}

class ReadCreateSelectionException implements Exception {
  final String message;

  ReadCreateSelectionException(this.message);

  @override
  String toString() {
    return message;
  }
}
