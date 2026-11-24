import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/avatar_record.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/workout_log.dart';
import 'package:makeme/utils/enums.dart';

// Every cycle in these tests starts on this day, at midnight.
// Day 0 is Nov 1, day 7 is Nov 8, and so on. The DateTime constructor rolls
// a day number past the end of the month over into the next month, so
// DateTime(2026, 11, 1 + 91) is Jan 31, 2027.
DateTime _day(int dayNumber, [int hour = 0]) {
  return DateTime(2026, 11, 1 + dayNumber, hour);
}

// Sample avatar, only the weekly goal matters for these tests
Avatar _avatar(int weeklyGoal) {
  return Avatar(
    avatarName: 'Test',
    weeklyGoal: weeklyGoal,
    gender: Gender.male,
    build: BuildType.average,
    head: const HeadConfig(),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
  );
}

// A workout on a given day of the cycle. The hour only matters for the test
// where two workouts happen on the same day. The id includes the hour so two
// workouts on one day stay different entries
WorkoutLogEntry _workout(int dayNumber, [int hour = 18]) {
  return WorkoutLogEntry(
    id: 'w$dayNumber-$hour',
    durationMinutes: 60,
    bodyParts: [BodyPartName.pects],
    intensity: Intensity.moderate,
    createdAt: _day(dayNumber, hour),
  );
}

// Finishes a cycle that started on day 0 and ended on endDay
AvatarRecord _finish({
  required int weeklyGoal,
  required int endDay,
  required List<WorkoutLogEntry> workouts,
}) {
  return AvatarRecord.finish(
    avatar: _avatar(weeklyGoal),
    startedAt: _day(0),
    endedAt: _day(endDay),
    workouts: workouts,
  );
}

void main() {
  group('AvatarRecord.finish', () {
    test('a full 91 day cycle that meets the goal every week is 13 of 13', () {
      // goal 3: trains on days 0, 2 and 4 of every week (13 weeks)
      final workouts = [
        for (var week = 0; week < 13; week++)
          for (final offset in [0, 2, 4]) _workout(week * 7 + offset),
      ];

      final record = _finish(weeklyGoal: 3, endDay: 91, workouts: workouts);

      expect(record.totalWeeks, 13);
      expect(record.weeksMet, 13);
    });

    test('no workouts means no weeks met', () {
      final record = _finish(weeklyGoal: 3, endDay: 91, workouts: []);

      expect(record.totalWeeks, 13);
      expect(record.weeksMet, 0);
    });

    test('two workouts on one day count as one training day', () {
      // goal 2. Week 0: two workouts on day 0 only, so 1 distinct day = not met.
      // Week 1: days 7 and 9 = 2 distinct days = met.
      final workouts = [
        _workout(0, 8),
        _workout(0, 18),
        _workout(7),
        _workout(9),
      ];

      final record = _finish(weeklyGoal: 2, endDay: 91, workouts: workouts);

      expect(record.weeksMet, 1);
    });

    test('reaching the goal exactly counts, one day short does not', () {
      // goal 3. Week 0: days 0, 1, 2 (exactly 3) = met.
      // Week 1: days 7, 8 (only 2) = not met.
      final workouts = [
        _workout(0),
        _workout(1),
        _workout(2),
        _workout(7),
        _workout(8),
      ];

      final record = _finish(weeklyGoal: 3, endDay: 91, workouts: workouts);

      expect(record.weeksMet, 1);
    });

    test('day 6 is the last day of week 0 and day 7 starts week 1', () {
      // goal 2. Days 0 and 6 share week 0 = met.
      final sameWeek = _finish(
        weeklyGoal: 2,
        endDay: 91,
        workouts: [_workout(0), _workout(6)],
      );
      // Days 6 and 7 are in different weeks, 1 day each = nothing met.
      final acrossBoundary = _finish(
        weeklyGoal: 2,
        endDay: 91,
        workouts: [_workout(6), _workout(7)],
      );

      expect(sameWeek.weeksMet, 1);
      expect(acrossBoundary.weeksMet, 0);
    });

    test('an early end counts only the whole weeks that passed', () {
      // Ended on day 50: 50 ~/ 7 = 7 whole weeks (days 0 to 48).
      // goal 1: one workout at the start of each of weeks 0 to 6 = 7 met.
      // Days 49 and 50 are in a partial week 7, so they do not count.
      final workouts = [
        for (var week = 0; week < 7; week++) _workout(week * 7),
        _workout(49),
        _workout(50),
      ];

      final record = _finish(weeklyGoal: 1, endDay: 50, workouts: workouts);

      expect(record.totalWeeks, 7);
      expect(record.weeksMet, 7);
    });

    test('workouts before the start or after the end are ignored', () {
      // goal 1, 13 weeks. Day -1 is before the cycle,
      // days 91 and 95 are after its last whole week.
      final workouts = [_workout(-1), _workout(91), _workout(95)];

      final record = _finish(weeklyGoal: 1, endDay: 91, workouts: workouts);

      expect(record.weeksMet, 0);
    });
  });
}