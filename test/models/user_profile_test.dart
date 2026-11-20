import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/user_data.dart';
import 'package:makeme/models/user_profile.dart';
import 'package:makeme/services/storage_service.dart';
import 'package:makeme/utils/enums.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

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

// A profile built the way main() builds it, from loaded data
UserProfile _profile([UserData data = const UserData.empty()]) {
  return UserProfile(storage: StorageService(), data: data);
}

void _create(UserProfile profile, String name) {
  profile.createAvatar(
    avatarName: name,
    weeklyGoal: 3,
    gender: Gender.male,
    build: BuildType.athletic,
    head: const HeadConfig(),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
  );
}

void main() {
  // A new empty storage before every test
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('UserProfile loading', () {
    test('no saved data starts with nothing', () {
      final profile = _profile();

      expect(profile.hasAvatar, false);
      expect(profile.history, isEmpty);
      expect(profile.canAscend, false);
    });

    test('restores the avatar, the history and the cycle', () {
      // started long ago, so the cycle is over and canAscend is true
      final profile = _profile(
        UserData(
          avatar: _avatar('Current'),
          history: [_avatar('Old')],
          cycleStart: DateTime(2020),
        ),
      );

      expect(profile.avatar?.avatarName, 'Current');
      expect(profile.history.length, 1);
      expect(profile.canAscend, true);
    });

    test('a saved avatar without a start date gets a new cycle', () async {
      _profile(UserData(avatar: _avatar('Current')));
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.cycleStart, isNotNull);
    });
  });

  group('UserProfile saving', () {
    test('createAvatar is saved with a start date', () async {
      final profile = _profile();

      _create(profile, 'Created');
      // the save runs in the background, so wait for it before loading
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.avatar?.avatarName, 'Created');
      expect(saved.cycleStart, isNotNull);
    });

    test('createAvatar does nothing when an avatar already exists', () {
      final profile = _profile();
      _create(profile, 'First');

      _create(profile, 'Second');

      expect(profile.avatar?.avatarName, 'First');
    });

    test('addGrowth is saved', () async {
      final profile = _profile();
      _create(profile, 'Created');

      profile.addGrowth(BodyPartName.pects, 1.5);
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.avatar?.growthOf(BodyPartName.pects), 1.5);
    });

    test('addGrowthAll saves every muscle', () async {
      final profile = _profile();
      _create(profile, 'Created');

      profile.addGrowthAll({BodyPartName.pects: 1.0, BodyPartName.quads: 2.0});
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.avatar?.growthOf(BodyPartName.pects), 1.0);
      expect(saved.avatar?.growthOf(BodyPartName.quads), 2.0);
    });

    test('addGrowthAll redraws only once', () {
      final profile = _profile();
      _create(profile, 'Created');
      var redraws = 0;
      profile.addListener(() => redraws++);

      profile.addGrowthAll({BodyPartName.pects: 1.0, BodyPartName.quads: 2.0});

      expect(redraws, 1);
    });

    test('ascend is saved: history is kept, cycle and avatar gone', () async {
      final profile = _profile();
      _create(profile, 'Created');

      profile.ascend();
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.avatar, isNull);
      expect(saved.history.single.avatarName, 'Created');
      expect(saved.cycleStart, isNull);
    });

    test('everything survives a restart', () async {
      final profile = _profile();
      _create(profile, 'Created');
      profile.addGrowth(BodyPartName.pects, 1.5);
      await pumpEventQueue();

      // a restart: load what was saved, then build a new profile from it
      final restarted = _profile(await StorageService().load());

      expect(restarted.avatar?.avatarName, 'Created');
      expect(restarted.avatar?.growthOf(BodyPartName.pects), 1.5);
    });
  });
}
