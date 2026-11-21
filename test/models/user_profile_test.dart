import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/user_data.dart';
import 'package:makeme/models/user_profile.dart';
import 'package:makeme/models/workout_log.dart';
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

// Helper function to simulate recording a workout
WorkoutLogEntry _log(UserProfile profile, {DateTime? date}) {
  return profile.addWorkout(
    durationMinutes: 60,
    bodyParts: [BodyPartName.pects, BodyPartName.quads],
    intensity: Intensity.moderate,
    date: date,
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
}
