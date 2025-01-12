import 'package:hive/hive.dart';

class DataManager {
  Future<G?> excute<G>({required Future<G> Function(Box box) executor}) async {
    final box = await Hive.openBox('data');
    final result = await executor.call(box);
    await box.close();
    if (result == null) return Future<G?>.value(null);
    return result;
  }

  Future<Box> getBox() async {
    return Hive.openBox('data');
  }

  Future<void> saveString({required String key, required String value}) async {
    final result = await excute(executor: (box) => box.put(key, value));
    return result;
  }

  Future<String?> getString({required String key, String? defaultValue}) async {
    final result = await excute<String?>(
      executor: (box) => Future.value(box.get(key, defaultValue: defaultValue)),
    );
    return result;
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
    final result = Set<String>.from(box.keys);
    await box.close();
    return result;
  }
}
