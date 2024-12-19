import 'package:m_cli/src/data/model/variable.dart';

class Metadata {
  String? name;
  String? description;
  List<Variable>? variables;

  Metadata({this.name, this.description, this.variables});

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    if (json['variables'] != null) {
      variables = <Variable>[];
      json['variables'].forEach((v) {
        variables!.add(Variable.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    if (variables != null) {
      data['variables'] = variables!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
