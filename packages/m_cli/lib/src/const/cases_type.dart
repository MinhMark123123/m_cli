import 'package:m_cli/src/util/string_util.dart';

enum CaseType {
  camel,
  pascal,
  snake,
  constant,
  kebab,
  dot,
  path,
  title,
  header,
  lower,
  uper,
  sentence;

  String convert(String input) {
    switch (this) {
      case CaseType.camel:
        return StringUtil.toCamelCase(input);

      case CaseType.pascal:
        return StringUtil.toPascalCase(input);
      case CaseType.snake:
        return StringUtil.toSnakeCase(input);
      case CaseType.constant:
        return StringUtil.toConstantCase(input);
      case CaseType.kebab:
        return StringUtil.toKebabCase(input);
      case CaseType.dot:
        return StringUtil.toDotCase(input);
      case CaseType.path:
        return StringUtil.toPathCase(input);
      case CaseType.title:
        return StringUtil.toTitleCase(input);
      case CaseType.header:
        return StringUtil.toHeaderCase(input);
      case CaseType.lower:
        return StringUtil.toLowerCase(input);
      case CaseType.uper:
        return StringUtil.toUpperCase(input);
      case CaseType.sentence:
        return StringUtil.toSentenceCase(input);
    }
  }

  static List<String> converts(String input) {
    return CaseType.values.map((e) => e.convert(input)).toList();
  }
}
