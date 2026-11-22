import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/user_data.dart';
import 'package:makeme/services/storage_service.dart';
import 'package:makeme/utils/enums.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:makeme/models/avatar_record.dart';

// Keeps the text in a map instead of on a device
class _MemoryStore implements TextStore {
  final Map<String, String> saved = {};

  @override
  Future<String?> read(String key) async => saved[key];

  @override
  Future<void> write(String key, String value) async {
    saved[key] = value;
  }
}

// Sample avatar
Avatar _avatar(String name) {
  return Avatar(
    avatarName: name,
    weeklyGoal: 3,
    gender: Gender.male,
    build: BuildType.athletic,
    head: const HeadConfig(),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
  );
}

AvatarRecord _record(String name) {
  return AvatarRecord(
    avatar: _avatar(name),
    startedAt: DateTime(2026, 8, 1),
    endedAt: DateTime(2026, 10, 31),
    weeksMet: 10,
    totalWeeks: 13,
  );
}

void main() {
  group('StorageService with a fake store', () {
    test('nothing saved yet loads as empty', () async {
      final service = StorageService(_MemoryStore());
      final data = await service.load();

      expect(data.avatar, isNull);
      expect(data.history, isEmpty);
      expect(data.cycleStart, isNull);
    });

    test('a saved UserData loads back the same', () async {
      final service = StorageService(_MemoryStore());
      final start = DateTime(2026, 11, 19, 23, 4);

      await service.save(
        UserData(
          avatar: _avatar('Current'),
          history: [_record('Old')],
          cycleStart: start,
        ),
      );

      final restored = await service.load();

      expect(restored.avatar?.avatarName, 'Current');
      expect(restored.history.first.avatar.avatarName, 'Old');
      expect(restored.cycleStart, start);
    });

    test('a new save replaces the previous one', () async {
      final service = StorageService(_MemoryStore());

      await service.save(UserData(avatar: _avatar('First')));
      await service.save(UserData(avatar: _avatar('Second')));
      final restored = await service.load();

      expect(restored.avatar?.avatarName, 'Second');
    });

    test('text that is not JSON loads as empty', () async {
      final store = _MemoryStore();
      store.saved[StorageService.storageKey] = 'not json';

      final data = await StorageService(store).load();

      expect(data.avatar, isNull);
    });

    test('an unreadable current avatar loads as empty', () async {
      final store = _MemoryStore();
      // valid JSON but avatar has none of its fields
      store.saved[StorageService.storageKey] = '{"avatar": {"broken": true}}';

      final data = await StorageService(store).load();

      expect(data.avatar, isNull);
    });

    test('saves under the storage key', () async {
      final store = _MemoryStore();

      await StorageService(store).save(UserData(avatar: _avatar('Current')));

      expect(store.saved.containsKey(StorageService.storageKey), true);
    });

    test('valid JSON that is not a map loads as empty', () async {
      final store = _MemoryStore();
      // a different failure from "not json": it decodes, then the cast fails
      store.saved[StorageService.storageKey] = '[1, 2, 3]';

      final data = await StorageService(store).load();

      expect(data.avatar, isNull);
    });
  });

  // Runs the real PrefsTextStore and SharedPreferencesAsync
  // Only the device storage under them is replaced by the package's in-memory storage
  group('StorageService with SharedPreferencesAsync', () {
    // A new empty storage before every test, so tests cannot affect each other
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('a saved UserData loads back through PrefsTextStore', () async {
      final service = StorageService();
      final start = DateTime(2026, 11, 19, 23, 4);

      await service.save(
        UserData(
          avatar: _avatar('Current'),
          history: [_record('Old')],
          cycleStart: start,
        ),
      );
      final restored = await service.load();

      expect(restored.avatar?.avatarName, 'Current');
      expect(restored.history.first.avatar.avatarName, 'Old');
      expect(restored.cycleStart, start);
    });

    test('PrefsTextStore reads back what it wrote', () async {
      final store = PrefsTextStore();

      await store.write('key', 'hello');

      expect(await store.read('key'), 'hello');
    });

    test('PrefsTextStore gives null for a key never written', () async {
      expect(await PrefsTextStore().read('key'), isNull);
    });

    test('damaged text in the real storage loads as empty', () async {
      // withData starts the storage with this text already saved
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            StorageService.storageKey: 'not json {',
          });

      final data = await StorageService().load();

      expect(data.avatar, isNull);
    });
  });
}
