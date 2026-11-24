import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/user_data.dart';
import 'package:makeme/models/user_profile.dart';
import 'package:makeme/models/workout_log.dart';
import 'package:makeme/services/cycle_manager.dart';
import 'package:makeme/services/storage_service.dart';
import 'package:makeme/utils/enums.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:makeme/models/avatar_record.dart';

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

// Sample finished cycle
AvatarRecord _record(String name) {
  return AvatarRecord(
    avatar: _avatar(name),
    startedAt: DateTime(2026, 8, 1),
    endedAt: DateTime(2026, 10, 31),
    weeksMet: 10,
    totalWeeks: 13,
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

// Helper function to simulate recording a workout
WorkoutLogEntry _log(UserProfile profile) {
  return profile.addWorkout(
    durationMinutes: 60,
    bodyParts: [BodyPartName.pects, BodyPartName.quads],
    intensity: Intensity.moderate,
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
      expect(profile.workoutHistory, isEmpty);
      expect(profile.templates, isEmpty);
      expect(profile.canAscend, false);
    });

    test('restores the avatar, the history and the cycle', () {
      // started long ago, so the cycle is over and canAscend is true
      final profile = _profile(
        UserData(
          avatar: _avatar('Current'),
          history: [_record('Old')],
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

    test('ascend is saved: history is kept, cycle and avatar gone', () async {
      final profile = _profile();
      _create(profile, 'Created');

      profile.ascend();
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.avatar, isNull);
      expect(saved.history.single.avatar.avatarName, 'Created');
      expect(saved.cycleStart, isNull);
    });

    test('everything survives a restart', () async {
      final profile = _profile();
      _create(profile, 'Created');
      profile.addWorkout(
        durationMinutes: 45,
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.moderate,
      );
      profile.addTemplate(
        name: 'Push day',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );
      await pumpEventQueue();

      // a restart: load what was saved, then build a new profile from it
      final restarted = _profile(await StorageService().load());

      expect(restarted.avatar?.avatarName, 'Created');
      expect(restarted.avatar?.growthOf(BodyPartName.pects), 1.5);
      expect(restarted.workoutHistory.single.durationMinutes, 45);
      expect(restarted.templates.single.name, 'Push day');
    });
  });

  group('addWorkout', () {
    test('grows the trained muscles', () {
      final profile = _profile();
      _create(profile, 'Created');

      _log(profile);

      expect(profile.avatar?.growthOf(BodyPartName.pects), 1.0);
      expect(profile.avatar?.growthOf(BodyPartName.quads), 1.0);
      expect(profile.avatar?.growthOf(BodyPartName.abs), 0.0);
    });

    test('saves the workout and the growth together', () async {
      final profile = _profile();
      _create(profile, 'Created');

      _log(profile);
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(saved.workoutHistory.single.durationMinutes, 60);
      expect(saved.avatar?.growthOf(BodyPartName.pects), 1.0);
    });

    test('redraws only once', () {
      final profile = _profile();
      _create(profile, 'Created');
      var redraws = 0;
      profile.addListener(() => redraws++);

      _log(profile);

      expect(redraws, 1);
    });

    test('a zero duration throws and changes nothing', () {
      final profile = _profile();
      _create(profile, 'Created');

      expect(
        () => profile.addWorkout(
          durationMinutes: 0,
          bodyParts: [BodyPartName.pects],
          intensity: Intensity.light,
        ),
        throwsArgumentError,
      );
      expect(profile.workoutHistory, isEmpty);
    });

    test('no body parts throws and changes nothing', () {
      final profile = _profile();
      _create(profile, 'Created');

      expect(
        () => profile.addWorkout(
          durationMinutes: 30,
          bodyParts: [],
          intensity: Intensity.light,
        ),
        throwsArgumentError,
      );
      expect(profile.workoutHistory, isEmpty);
    });
  });

  group('templates', () {
    test('addTemplate saves a trimmed name', () async {
      final profile = _profile();

      profile.addTemplate(
        name: '  Push day  ',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(profile.templates.single.name, 'Push day');
      expect(saved.templates.single.name, 'Push day');
    });

    test('a blank name or no body parts throws', () {
      final profile = _profile();

      expect(
        () => profile.addTemplate(
          name: '   ',
          bodyParts: [BodyPartName.pects],
          intensity: Intensity.heavy,
        ),
        throwsArgumentError,
      );
      expect(
        () => profile.addTemplate(
          name: 'Empty',
          bodyParts: [],
          intensity: Intensity.heavy,
        ),
        throwsArgumentError,
      );
      expect(profile.templates, isEmpty);
    });

    test('deleteTemplate removes it and saves', () async {
      final profile = _profile();
      final template = profile.addTemplate(
        name: 'Push day',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );

      profile.deleteTemplate(template.id);
      await pumpEventQueue();
      final saved = await StorageService().load();

      expect(profile.templates, isEmpty);
      expect(saved.templates, isEmpty);
    });

    test('deleting the picked template clears the pending one', () {
      final profile = _profile();
      final template = profile.addTemplate(
        name: 'Push day',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );
      profile.setPendingTemplate(template);

      profile.deleteTemplate(template.id);

      expect(profile.takePendingTemplate(), isNull);
    });
  });

  group('takePendingTemplate', () {
    test('hands over the template once, then nothing', () {
      final profile = _profile();
      final template = profile.addTemplate(
        name: 'Push day',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );
      profile.setPendingTemplate(template);

      expect(profile.takePendingTemplate()?.id, template.id);
      expect(profile.takePendingTemplate(), isNull);
    });

    test('does not notify listeners', () {
      final profile = _profile();
      final template = profile.addTemplate(
        name: 'Push day',
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.heavy,
      );
      profile.setPendingTemplate(template);
      var redraws = 0;
      profile.addListener(() => redraws++);

      profile.takePendingTemplate();

      expect(redraws, 0);
    });
  });

  group('ascension', () {
    // A profile whose avatar has every muscle at the growth target
    // (athletic, goal 3 -> target 6.0), so it is maxed
    UserProfile maxedProfile([int level = 0]) {
      final maxed = _avatar('Maxed').copyWith(
        muscleGrowth: {for (final part in BodyPartName.values) part: 6.0},
      );
      return _profile(
        UserData(
          avatar: maxed,
          cycleStart: DateTime.now(),
          ascensionLevel: level,
        ),
      );
    }

    // An avatar that never maxed, created the given number of days ago
    UserProfile agedProfile(int days) {
      return _profile(
        UserData(
          avatar: _avatar('Aged'),
          cycleStart: DateTime.now().subtract(Duration(days: days)),
        ),
      );
    }

    test('a new user starts at ascension level 0', () {
      final profile = _profile();
      _create(profile, 'Created');

      expect(profile.ascensionLevel, 0);
    });

    test('a fresh avatar is not maxed and cannot ascend', () {
      final profile = _profile();
      _create(profile, 'Created');

      expect(profile.isMaxed, false);
      expect(profile.canAscend, false);
    });

    test('a maxed avatar must ascend', () {
      final profile = maxedProfile();

      expect(profile.isMaxed, true);
      expect(profile.canAscend, true);
    });

    test('logging a workout that maxes the avatar makes it ascend', () {
      final profile = _profile();
      _create(profile, 'Created');

      // 4 h heavy on one muscle = 12 points, past the 6.0 target
      for (final part in BodyPartName.values) {
        profile.addWorkout(
          durationMinutes: 240,
          bodyParts: [part],
          intensity: Intensity.heavy,
        );
      }

      expect(profile.isMaxed, true);
      expect(profile.canAscend, true);
    });

    test('an avatar must ascend after 91 days without maxing', () {
      final profile = agedProfile(CycleManager.cycleDays);

      expect(profile.isMaxed, false);
      expect(profile.canAscend, true);
    });

    test('an avatar cannot ascend on day 90 without maxing', () {
      expect(agedProfile(CycleManager.cycleDays - 1).canAscend, false);
    });

    test('a due ascension is still due after a restart', () async {
      final profile = agedProfile(CycleManager.cycleDays);
      profile.addWorkout(
        durationMinutes: 30,
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.light,
      );
      await pumpEventQueue();

      final restarted = _profile(await StorageService().load());

      expect(restarted.canAscend, true);
    });

    test('ascend raises the level and the next avatar keeps it', () {
      final profile = maxedProfile();

      profile.ascend();
      _create(profile, 'Next');

      expect(profile.ascensionLevel, 1);
      expect(profile.canAscend, false);
      expect(profile.avatar?.avatarName, 'Next');
      expect(profile.avatar?.growthOf(BodyPartName.pects), 0.0);
      expect(profile.history.single.avatar.avatarName, 'Maxed');
    });

    test('ascending after 91 days raises the level', () {
      final profile = agedProfile(CycleManager.cycleDays);

      profile.ascend();

      expect(profile.ascensionLevel, 1);
      expect(profile.history.single.avatar.avatarName, 'Aged');
    });

    test('ascend without an avatar does not raise the level', () {
      final profile = _profile();

      profile.ascend();

      expect(profile.ascensionLevel, 0);
    });

    test('at the last badge the avatar still ascends but keeps the level', () {
      final profile = maxedProfile(UserProfile.maxAscensionLevel);

      expect(profile.canAscend, true);
      expect(profile.atMaxAscension, true);

      profile.ascend();

      expect(profile.ascensionLevel, UserProfile.maxAscensionLevel);
      expect(profile.history.single.avatar.avatarName, 'Maxed');
    });

    test('the ascension level survives a restart', () async {
      final profile = maxedProfile();
      profile.ascend();
      await pumpEventQueue();

      final restarted = _profile(await StorageService().load());

      expect(restarted.ascensionLevel, 1);
    });

    test('a corrupted level is clamped into range', () {
      final profile = _profile(const UserData(ascensionLevel: 99));

      expect(profile.ascensionLevel, UserProfile.maxAscensionLevel);
    });

    test('forceMaxed maxes the avatar and survives a restart', () async {
      final profile = _profile();
      _create(profile, 'Created');
      profile.addWorkout(
        durationMinutes: 30,
        bodyParts: [BodyPartName.pects],
        intensity: Intensity.light,
      );
      final double pectsBefore = profile.avatar!.growthOf(BodyPartName.pects);

      profile.forceMaxed();
      await pumpEventQueue();
      final restarted = _profile(await StorageService().load());

      expect(profile.isMaxed, true);
      expect(profile.canAscend, true);
      expect(profile.avatar!.growthOf(BodyPartName.pects) > pectsBefore, true);
      expect(restarted.isMaxed, true);
      expect(restarted.canAscend, true);
    });

    test('forceEndCycle ends the cycle and survives a restart', () async {
      final profile = _profile();
      _create(profile, 'Created');

      profile.forceEndCycle();
      await pumpEventQueue();
      final restarted = _profile(await StorageService().load());

      expect(profile.canAscend, true);
      expect(profile.isMaxed, false);
      expect(restarted.canAscend, true);
    });
  });
}
