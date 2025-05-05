import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shared_data.dart';

class LocalStorage {
  static const _key = 'shared_history';

  static Future<void> saveData(SharedData data) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadData();
    history.add(data);
    await prefs.setStringList(
      _key,
      history.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  static Future<void> saveAllData(List<SharedData> dataList) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = dataList.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_key, encodedList);
  }

  static Future<List<SharedData>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((e) => SharedData.fromJson(json.decode(e))).toList();
  }
}
