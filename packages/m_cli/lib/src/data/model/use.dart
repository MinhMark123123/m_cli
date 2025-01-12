import 'package:m_cli/src/const/source_type.dart';

class Use {
  final String? name;
  final SourceType? source;

  const Use({
    required this.name,
    required this.source,
  });

  factory Use.fromJson(Map<String, dynamic> json) {
    return Use(
      name: json['name'],
      source: SourceType.parse(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['source'] = source?.value;
    return data;
  }
}
