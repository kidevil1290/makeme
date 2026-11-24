import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/services/cycle_manager.dart';
import 'package:makeme/utils/enums.dart';
import 'package:makeme/models/growth_calculator.dart';

// Same date as the UserData tests
final _start = DateTime(2026, 11, 19, 8, 30);

// Raw growth that maxes a muscle for the sample avatar (weekly goal 3)
final double _target = GrowthCalculator.targetFor(3);

// Sample avatar with all muscles maxed
Avatar _avatar({bool maxed = false}) {
  return Avatar(
    avatarName: 'Tester',
    weeklyGoal: 3,
    gender: Gender.male,
    build: BuildType.athletic,
    head: const HeadConfig(),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
    muscleGrowth: maxed
        ? {
            for (final part in BodyPartName.values)
              part: _target,
          }
        : {},
  );
}

void main() {
  group('CycleManager restore', () {
    test('puts the saved start date back', () {
      final cycle = CycleManager();

      cycle.restore(_start, _avatar());

      expect(cycle.cycleStart, _start);
    });

    test('canAscend turns true on the last day of the cycle', () {
      final cycle = CycleManager();
      final lastDay = _start.add(const Duration(days: CycleManager.cycleDays));
      final dayBefore = lastDay.subtract(const Duration(days: 1));

      cycle.restore(_start, _avatar(), dayBefore);
      expect(cycle.canAscend, false);

      cycle.restore(_start, _avatar(), lastDay);
      expect(cycle.canAscend, true);
    });

    test('canAscend is true for a maxed avatar on day 0', () {
      final cycle = CycleManager();

      cycle.restore(_start, _avatar(maxed: true), _start);
      expect(cycle.canAscend, true);
    });

    test('no saved cycle and no avatar leaves nothing running', () {
      final cycle = CycleManager();

      cycle.restore(null, null);
      expect(cycle.cycleStart, isNull);
      expect(cycle.canAscend, false);
    });

    test('an avatar without a start date cannot ascend', () {
      final cycle = CycleManager();

      cycle.restore(null, _avatar(maxed: true));
      expect(cycle.canAscend, false);
    });
  });

  group('CycleManager basic functionality', () {
    test('startCycle records the start date', () {
      final cycle = CycleManager();

      cycle.startCycle(_start);
      expect(cycle.cycleStart, _start);
    });

    test('reset clears the cycle', () {
      final cycle = CycleManager();
      cycle.restore(_start, _avatar(maxed: true), _start);

      cycle.reset();

      expect(cycle.cycleStart, isNull);
      expect(cycle.canAscend, false);
    });
  });

  group('CycleManager update', () {
    test('follows the avatar after startCycle', () {
      final cycle = CycleManager();
      cycle.startCycle(_start);

      cycle.update(_avatar(), _start);
      expect(cycle.canAscend, false);

      cycle.update(_avatar(maxed: true), _start);
      expect(cycle.canAscend, true);
    });

    test('one muscle short of max does not ascend', () {
      final cycle = CycleManager();
      cycle.startCycle(_start);

      final almostMaxed = _avatar().copyWith(
        muscleGrowth: {
          for (final part in BodyPartName.values.skip(1))
            part: _target,
        },
      );

      cycle.update(almostMaxed, _start);
      expect(cycle.canAscend, false);
    });

    test('day 91 counts with the real clock even without a new update', () {
      final cycle = CycleManager();
      final longAgo = DateTime.now().subtract(
        const Duration(days: CycleManager.cycleDays),
      );
      cycle.startCycle(longAgo);

      // no update() call: canAscend still sees the cycle is over
      expect(cycle.canAscend, true);
      expect(cycle.isMaxed, false);
    });

    test('a maxed avatar reports isMaxed', () {
      final cycle = CycleManager();
      cycle.startCycle(_start);

      cycle.update(_avatar(maxed: true), _start);
      expect(cycle.isMaxed, true);
    });

    test('checks edge case before 91', () {
      final cycle = CycleManager();
      cycle.startCycle(_start);

      final almostDone = _start
          .add(const Duration(days: CycleManager.cycleDays))
          .subtract(const Duration(minutes: 1));

      cycle.update(_avatar(), almostDone);
      expect(cycle.canAscend, false);
    });
  });
}
