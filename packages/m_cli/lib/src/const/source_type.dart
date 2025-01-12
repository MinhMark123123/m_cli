enum SourceType {
  unknow(""),
  git("git"),
  zip("zip"),
  path("path");

  final String value;

  const SourceType(this.value);

  static parse(String? value) {
    if (value == null || value.isEmpty) return SourceType.unknow;
    return SourceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SourceType.unknow,
    );
  }
}
