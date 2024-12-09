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
}
