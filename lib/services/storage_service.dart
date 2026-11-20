import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data.dart';

// Reads and writes text under a key
// Exists for unit testing and keeps the package out of StorageService
abstract class TextStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

// The real store: the device's own key-value storage
// read is getString and write is setString on the package's SharedPreferencesAsync
class PrefsTextStore implements TextStore {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}

// Saves and loads the whole UserData as one JSON text
// The only place with async code. The conversion itself is synchronous
// only reading and writing the storage takes time
class StorageService {
  // The one key the whole UserData is saved under
  // Changing it would orphan every existing save
  static const String storageKey = 'user_data';

  final TextStore _store;

  // No argument uses the real device storage
  StorageService([TextStore? store]) : _store = store ?? PrefsTextStore();

  // First launch or anything unreadable gives an empty UserData,
  // so the app always starts
  // Damaged text stays in storage until the next save replaces it
  Future<UserData> load() async {
    try {
      final text = await _store.read(storageKey);
      if (text == null) return const UserData.empty();

      final json = jsonDecode(text) as Map<String, dynamic>;
      return UserData.fromJson(json);
    } catch (err) {
      debugPrint('Could not load saved data, starting empty: $err');
      return const UserData.empty();
    }
  }

  // Replaces the previous save with this snapshot
  Future<void> save(UserData data) async {
    await _store.write(storageKey, jsonEncode(data.toJson()));
  }
}
