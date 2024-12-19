import 'package:hive/hive.dart';

class DataManager {
  BoxCollection? _collection;

  Future<CollectionBox> getBox() async {
    _collection ??= await BoxCollection.open(
      'dataBox', // Name of your database
      {'data'}, // Names of your boxes
      path: './', // Path where to store your boxes
    );
    final box = await _collection!.openBox("data");
    return box;
  }

  Future<void> saveString({required String key, required String value}) async {
    final box = await getBox();
    return await box.put(key, value);
  }

  Future<String?> getString({required String key, String? defaultValue}) async {
    final box = await getBox();
    return await box.get(key) ?? defaultValue;
  }

  Future<void> delete({required String key}) async {
    final box = await getBox();
    await box.delete(key);
  }

  Future<void> deleteAll() async {
    final box = await getBox();
    await box.clear();
  }

  Future<Set<String>> getAllKeys() async {
    final box = await getBox();
    return Set<String>.from(await box.getAllKeys());
  }
}
