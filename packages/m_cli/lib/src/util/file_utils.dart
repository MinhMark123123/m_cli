import 'dart:convert';
import 'dart:io';
import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/const/prefs_key.dart';
import 'package:http/http.dart' as http;
import 'package:m_cli_core/m_cli_core.dart';

class FileUtils {
  FileUtils._();

  static Future<String> readStringFromPath({required String path}) async {
    var resource = File(path);
    var string = await resource.readAsString(encoding: utf8);
    return string;
  }

  /// Get the user's home directory
  static String getHomeDirectory() {
    if (Platform.isMacOS || Platform.isLinux) {
      // macOS and Linux: Use the HOME environment variable
      final home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) {
        throw Exception(
          'Unable to determine the home directory on this platform.',
        );
      }
      return home;
    } else if (Platform.isWindows) {
      // Windows: Use the USERPROFILE environment variable
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null || userProfile.isEmpty) {
        throw Exception(
          'Unable to determine the home directory on this platform.',
        );
      }
      return userProfile;
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}',
      );
    }
  }

  static Directory getProjectDir() {
    final homePath = getHomeDirectory();
    final projectDirPath = [homePath, ".m_cli"].join(Platform.pathSeparator);
    final dir = Directory(projectDirPath);
    if (!dir.existsSync()) {
      dir.create(recursive: true);
    }
    return dir;
  }

  static String getHivePath() {
    final projectDir = FileUtils.getProjectDir().path;
    return [projectDir, "_db"].join(Platform.pathSeparator);
  }

  static Future<String> getFileDir({
    String? name,
    required SourceType type,
  }) async {
    final docDir = getProjectDir();
    final folderName = Keys.getKeyName(name);
    return <String>[docDir.path, folderName, type.name]
        .join(Platform.pathSeparator);
  }

  static Future<String> getCreateDir({
    String? name,
    required SourceType type,
    String? localPath,
  }) async {
    final dirPath = await getFileDir(name: name, type: type);
    return <String>[
      localPath ?? dirPath,
      "create",
    ].join(Platform.pathSeparator);
  }
  static String getMetadataPath({required String srcPath}){
    return  [
      srcPath,
      "metadata.json",
    ].join(Platform.pathSeparator);
  }

  static void copyDirectorySync({
    required Directory source,
    required Directory destination,
    String? replacePath,
    (bool, bool) Function(File)? onConflictCondition,
  }) {
    bool overwriteAll = false;

    /// create destination folder if not exist
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    for (var entity in source.listSync(recursive: true)) {
      final relativePath = entity.path.replaceFirst(source.path, '');
      final newPath = destination.path + relativePath;
      if (entity is Directory) {
        // Create subdirectory in the destination
        final newDirectory = Directory(newPath);
        if (!newDirectory.existsSync()) {
          newDirectory.createSync(recursive: true);
        }
      } else if (entity is File) {
        // Copy the file to the destination directory
        final newFile = File(newPath);
        if (newFile.existsSync() && onConflictCondition != null) {
          if (overwriteAll) {
            newFile.deleteSync();
            newFile.createSync(recursive: true);
            entity.copySync(newFile.path);
            ConsoleUtils.echoTextLine(messageLine: "overwrite ${newFile.path}");
          } else {
            final userConfirm = onConflictCondition.call(newFile);
            overwriteAll = userConfirm.$1;
            final overwrite = userConfirm.$2;
            if (overwrite) {
              newFile.deleteSync();
              newFile.createSync(recursive: true);
              entity.copySync(newFile.path);
              ConsoleUtils.echoTextLine(messageLine: "overwrite ${newFile.path}");
            }
          }
        } else {
          newFile.createSync(recursive: true);
          entity.copySync(newFile.path);
          ConsoleUtils.echoTextLine(messageLine: "create ${newFile.path}");
        }
      }
    }
  }

  static String writeTextFile({required String path, required String content}) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(content);
    return file.path;
  }

  static bool existsFilePath(String path, [bool reset = false]) {
    if (path.contains('.')) {
      return File(path).existsSync();
    }
    return Directory(path).existsSync();
  }

  static void deleteFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
      return;
    }
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static Future<String> downloadFile({
    required String url,
    required String path,
  }) async {
    final response = await http.get(Uri.parse(url));
    final filePath = path;
    final isExist = existsFilePath(filePath);
    if (isExist) {
      deleteFile(filePath);
    }
    await File(filePath).writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
