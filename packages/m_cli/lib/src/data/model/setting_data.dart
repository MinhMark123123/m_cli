import 'package:m_cli/src/const/source_type.dart';
import 'package:m_cli/src/data/model/git_setting_data.dart';

class SettingData {
  GitSettingData? git;
  String? zip;
  String? path;

  SettingData({this.git, this.zip, this.path});

  SettingData.fromJson(Map<String, dynamic> json) {
    git = json['git'] == null
        ? null
        : GitSettingData.fromJson(json['git'] as Map<String, dynamic>);
    zip = json['zip'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['git'] = git?.toJson();
    data['zip'] = zip;
    data['path'] = path;
    return data;
  }

  SettingData copyWith({
    GitSettingData? git,
    String? zip,
    String? path,
  }) {
    return SettingData(
      git: git ?? this.git,
      zip: zip ?? this.zip,
      path: path ?? this.path,
    );
  }

  SourceType getAvailableSource() {
    if (git != null) return SourceType.git;
    if (zip?.isNotEmpty == true) return SourceType.zip;
    if (path?.isNotEmpty != true) return SourceType.path;
    return SourceType.git;
  }
}

extension SettingDataExtensions on SettingData {
  String prettyText() {
    var textPretty = "";
    if (git != null && git!.url?.isNotEmpty == true) {
      textPretty = "git : ${git?.url}";
      if (git!.branch?.isNotEmpty == true) {
        textPretty = "$textPretty branch: ${git?.branch}";
      }
      if (git!.commit?.isNotEmpty == true) {
        textPretty = "$textPretty commit: ${git?.commit}";
      }
    }
    if (textPretty.isNotEmpty) {
      textPretty = "$textPretty\n";
    }
    if (zip?.isNotEmpty == true) {
      textPretty = "${textPretty}zip: $zip\n";
    }
    if (path?.isNotEmpty == true) {
      textPretty = "${textPretty}path: $path\n";
    }
    return textPretty;
  }
}
