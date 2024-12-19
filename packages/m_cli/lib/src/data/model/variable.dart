class Variable {
  String? key;
  String? prompt;
  String? defaultValue;

  Variable({this.key, this.prompt, this.defaultValue});

  Variable.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    prompt = json['prompt'];
    defaultValue = json['default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['prompt'] = prompt;
    data['default'] = defaultValue;
    return data;
  }
}
