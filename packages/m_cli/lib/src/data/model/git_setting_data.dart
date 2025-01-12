class GitSettingData {
  String? url;
  String? branch;
  String? commit;

  GitSettingData({this.url, this.branch, this.commit});

  GitSettingData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    branch = json['branch'];
    commit = json['commit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['branch'] = branch;
    data['commit'] = commit;
    return data;
  }

  GitSettingData copyWith({
    String? url,
    String? branch,
    String? commit,
  }) {
    return GitSettingData(
      url: url ?? this.url,
      branch: branch ?? this.branch,
      commit: commit ?? this.commit,
    );
  }

  String prettyText() {
    if (!(url?.isNotEmpty == true)) return "";
    var text = "git: $url";
    if (branch?.isNotEmpty == true) {
      text = "$text branch: $branch";
    }
    if (commit?.isNotEmpty == true) {
      text = "$text commit: $commit";
    }
    return text;
  }
}
