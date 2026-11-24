import 'package:flutter/material.dart';

import '../models/avatar.dart';
import '../models/avatar_sprites.dart';
import '../models/head_config.dart';
import '../models/workout_log.dart';
import '../utils/enums.dart';
import 'cycle_manager.dart';

// Muscle groups a simulated user rotates through, one group per session.
class SimRoutines {
  SimRoutines._();

  static const List<BodyPartName> push = [
    BodyPartName.pects,
    BodyPartName.shoulders,
    BodyPartName.triceps,
    BodyPartName.abs,
  ];
  static const List<BodyPartName> pull = [
    BodyPartName.lats,
    BodyPartName.traps,
    BodyPartName.biceps,
    BodyPartName.forearms,
  ];
  static const List<BodyPartName> legs = [
    BodyPartName.quads,
    BodyPartName.glutes,
    BodyPartName.calves,
  ];

  // Three-day rotation that covers all 11 muscles
  static const List<List<BodyPartName>> pushPullLegs = [push, pull, legs];

  // Every muscle in every session
  static final List<List<BodyPartName>> fullBody = [BodyPartName.values];
}

// A made-up user: how often, how long and how hard they train.
// Sessions are spread evenly over each week and rotate through [routine].
class SimProfile {
  final String name;
  final int sessionsPerWeek; // 1 to 7
  final int minutes;
  final Intensity intensity;
  final List<List<BodyPartName>> routine;

  const SimProfile({
    required this.name,
    required this.sessionsPerWeek,
    required this.minutes,
    required this.intensity,
    required this.routine,
  });

  // Which days of a 7 day week a session happens on, e.g. 3/week -> 0, 2, 4
  List<int> get weekDays => [
    for (int i = 0; i < sessionsPerWeek; i++) (i * 7) ~/ sessionsPerWeek,
  ];
}

// Ready-made profiles used by the debug screen and the calibration test
class SimProfiles {
  SimProfiles._();

  // Does exactly what a 3 days/week goal asks for (the default goal)
  static const SimProfile onGoal = SimProfile(
    name: '3x/week, 60 min, moderate (on goal)',
    sessionsPerWeek: 3,
    minutes: 60,
    intensity: Intensity.moderate,
    routine: SimRoutines.pushPullLegs,
  );

  static const SimProfile overAchiever = SimProfile(
    name: '5x/week, 60 min, moderate (over goal)',
    sessionsPerWeek: 5,
    minutes: 60,
    intensity: Intensity.moderate,
    routine: SimRoutines.pushPullLegs,
  );

  static const SimProfile casual = SimProfile(
    name: '1x/week, 30 min, light (under goal)',
    sessionsPerWeek: 1,
    minutes: 30,
    intensity: Intensity.light,
    routine: SimRoutines.pushPullLegs,
  );

  static final List<SimProfile> all = [onGoal, overAchiever, casual];
}

// The avatar at the end of one day of the cycle
class DaySnapshot {
  final int day; // 0 = the day the cycle started
  final Avatar avatar;
  final AvatarSprites sprites;
  final int sessionsDone;
  final bool canAscend;

  const DaySnapshot({
    required this.day,
    required this.avatar,
    required this.sprites,
    required this.sessionsDone,
    required this.canAscend,
  });
}

// Replays a whole 91 day cycle through the REAL app code: WorkoutLogEntry for
// the growth formula, Avatar.addGrowth for the log, AvatarSprites for the
// sprite levels and CycleManager for the ascension rule.
class GrowthSimulator {
  GrowthSimulator._();

  // UTC, so whole days never shift with daylight saving
  static final DateTime cycleStart = DateTime.utc(2026, 1, 1);

  // Fresh avatar (zero growth) that looks like [base], the user's real avatar.
  // [build] and [weeklyGoal] can override the base values for what-if runs.
  static Avatar newAvatar(
    Avatar base, {
    BuildType? build,
    int? weeklyGoal,
  }) {
    return Avatar.start(
      avatarName: base.avatarName,
      weeklyGoal: weeklyGoal ?? base.weeklyGoal,
      gender: base.gender,
      build: build ?? base.build,
      head: base.head,
      skinColor: base.skinColor,
      hairColor: base.hairColor,
    );
  }

  // One snapshot per day, day 0 up to and including [days] (default 91, the day
  // ascension is offered no matter what). Workouts only happen on days before
  // [days], because day 91 is the first day of the next cycle.
  static List<DaySnapshot> run({
    required Avatar base,
    required SimProfile profile,
    BuildType? build,
    int? weeklyGoal,
    int days = CycleManager.cycleDays,
  }) {
    final cycle = CycleManager()..startCycle(cycleStart);
    final sessionDays = profile.weekDays.toSet();

    var avatar = newAvatar(base, build: build, weeklyGoal: weeklyGoal);
    var sessions = 0;
    final snapshots = <DaySnapshot>[];

    for (int day = 0; day <= days; day++) {
      final date = cycleStart.add(Duration(days: day));

      if (day < days && sessionDays.contains(day % 7)) {
        final entry = WorkoutLogEntry(
          id: 'sim-$day',
          durationMinutes: profile.minutes,
          bodyParts: profile.routine[sessions % profile.routine.length],
          intensity: profile.intensity,
          createdAt: date,
        );
        for (final grown in entry.growthByPart.entries) {
          avatar = avatar.addGrowth(grown.key, grown.value);
        }
        sessions++;
      }

      cycle.update(avatar, date);
      snapshots.add(
        DaySnapshot(
          day: day,
          avatar: avatar,
          sprites: AvatarSprites(avatar),
          sessionsDone: sessions,
          canAscend: cycle.canAscend,
        ),
      );
    }
    return snapshots;
  }

  // First day every muscle was maxed, or null if it never happened
  static int? firstMaxedDay(List<DaySnapshot> run) {
    for (final snap in run) {
      if (snap.sprites.isMaxed) return snap.day;
    }
    return null;
  }
}