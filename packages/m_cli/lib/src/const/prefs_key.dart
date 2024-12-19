class Keys {
  Keys._();

  static const defaultKey = "default";
  static const use = "use";

  static String getKeyName(String? name) => name ?? defaultKey;
}
