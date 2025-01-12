class StringUtil {
  StringUtil._();
  static String composePattern(String input) => '''\${$input}''';

  /// Converts a string to camelCase
  static String toCamelCase(String input) {
    final words = _splitWords(input);
    return words.first.toLowerCase() +
        words.skip(1).map((word) => _capitalize(word)).join('');
  }

  /// Converts a string to PascalCase
  static String toPascalCase(String input) {
    return _splitWords(input).map((word) => _capitalize(word)).join('');
  }

  /// Converts a string to snake_case
  static String toSnakeCase(String input) {
    return _splitWords(input).map((word) => word.toLowerCase()).join('_');
  }

  /// Converts a string to CONSTANT_CASE
  static String toConstantCase(String input) {
    return _splitWords(input).map((word) => word.toUpperCase()).join('_');
  }

  /// Converts a string to kebab-case
  static String toKebabCase(String input) {
    return _splitWords(input).map((word) => word.toLowerCase()).join('-');
  }

  /// Converts a string to dot.case
  static String toDotCase(String input) {
    return _splitWords(input).map((word) => word.toLowerCase()).join('.');
  }

  /// Converts a string to path/case
  static String toPathCase(String input) {
    return _splitWords(input).map((word) => word.toLowerCase()).join('/');
  }

  /// Converts a string to Title Case
  static String toTitleCase(String input) {
    return _splitWords(input).map((word) => _capitalize(word)).join(' ');
  }

  /// Converts a string to Header-Case
  static String toHeaderCase(String input) {
    return _splitWords(input).map((word) => _capitalize(word)).join('-');
  }

  /// Converts a string to lowercase
  static String toLowerCase(String input) {
    return input.toLowerCase();
  }

  /// Converts a string to UPPERCASE
  static String toUpperCase(String input) {
    return input.toUpperCase();
  }

  /// Converts a string to Sentence case
  static String toSentenceCase(String input) {
    final words = _splitWords(input);
    if (words.isEmpty) return '';
    final firstWord = _capitalize(words.first);
    final remainingWords =
        words.skip(1).map((word) => word.toLowerCase()).join(' ');
    return '$firstWord $remainingWords';
  }

  /// Splits the input into words based on common delimiters
  static List<String> _splitWords(String input) {
    final pattern = RegExp(r'[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\d+');
    return pattern.allMatches(input).map((match) => match.group(0)!).toList();
  }

  /// Capitalizes the first letter of a word
  static String _capitalize(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
