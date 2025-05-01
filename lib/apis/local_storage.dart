import 'package:hive/hive.dart';

class LocalStorageHive {
  static saveAllData(String token, String userId) async {
    final box = await Hive.openBox('app_data');
    await box.put('token', token);
    await box.put('userId', userId);
  }

  static Future<Map<String, String>> getAllData() async {
    final box = await Hive.openBox('app_data');
    return {'token': box.get('token'), 'userId': box.get('userId')};
  }

  static Future<void> clearAllData() async {
    final box = await Hive.openBox('app_data');
    await box.clear();
  }
}
