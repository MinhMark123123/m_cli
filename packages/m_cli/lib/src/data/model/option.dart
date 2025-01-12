class Option {
  String? key;
  String? prompt;
  String? path;

  Option({this.key, this.prompt, this.path});

  Option.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    prompt = json['prompt'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['prompt'] = prompt;
    data['path'] = path;
    return data;
  }
}