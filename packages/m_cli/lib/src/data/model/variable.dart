class Variable {
  String? key;
  String? prompt;
  String? defaultValue;
  bool? reCase;

  Variable({this.key, this.prompt, this.defaultValue, this.reCase});

  Variable.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    prompt = json['prompt'];
    defaultValue = json['default'];
    reCase = json['reCase'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['prompt'] = prompt;
    data['default'] = defaultValue;
    data['reCase'] = reCase;
    return data;
  }
}
