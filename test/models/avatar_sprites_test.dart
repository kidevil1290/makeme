import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/avatar_sprites.dart';
import 'package:makeme/models/growth_calculator.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/utils/enums.dart';

// Sample avatar. Every muscle gets [all] raw growth, then [only] overrides
// single muscles. weeklyGoal 3 means a muscle maxes at 6.0 raw growth.
Avatar _avatar(
  BuildType build, {
  double all = 0.0,
  Map<BodyPartName, double> only = const {},
  int weeklyGoal = 3,
}) {
  return Avatar(
    avatarName: 'Tester',
    weeklyGoal: weeklyGoal,
    gender: Gender.male,
    build: build,
    head: const HeadConfig(),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
    muscleGrowth: {
      for (final part in BodyPartName.values) part: all,
      ...only,
    },
  );
}

void main() {
  final double target = GrowthCalculator.targetFor(3);

  group('AvatarSprites starting look', () {
    test('athletic starts at level 1 everywhere', () {
      final sprites = AvatarSprites(_avatar(BuildType.athletic));

      expect(sprites.transitioning, false);
      expect(sprites.borderLevel, 1);
      for (final region in AvatarRegion.values) {
        expect(sprites.regionStep(region), 1);
      }
    });

    test('average starts at level 0 everywhere', () {
      final sprites = AvatarSprites(_avatar(BuildType.average));

      expect(sprites.transitioning, false);
      expect(sprites.borderLevel, 0);
      for (final region in AvatarRegion.values) {
        expect(sprites.regionStep(region), 0);
      }
    });

    test('skinny and heavy start on their full build body', () {
      for (final build in [BuildType.skinny, BuildType.heavy]) {
        final sprites = AvatarSprites(_avatar(build));

        expect(sprites.transitioning, true);
        expect(sprites.buildStage, 100);
        expect(sprites.borderLevel, 0);
      }
    });

    test('nobody starts maxed', () {
      for (final build in BuildType.values) {
        expect(AvatarSprites(_avatar(build)).isMaxed, false);
      }
    });
  });

  group('AvatarSprites growth to level', () {
    test('half the target is halfway between the start and max level', () {
      // athletic: 1 + (3 - 1) * 0.5 = 2, average: 0 + 3 * 0.5 = 1.5
      final athletic = AvatarSprites(
        _avatar(BuildType.athletic, all: target / 2),
      );
      final average = AvatarSprites(_avatar(BuildType.average, all: target / 2));

      expect(athletic.regionLevel(AvatarRegion.pects), 2.0);
      expect(athletic.regionStep(AvatarRegion.pects), 2);
      expect(average.regionLevel(AvatarRegion.pects), 1.5);
      expect(average.regionStep(AvatarRegion.pects), 1);
    });

    test('every build reaches max at the same raw growth', () {
      for (final build in BuildType.values) {
        final sprites = AvatarSprites(_avatar(build, all: target));

        expect(sprites.isMaxed, true, reason: build.name);
        expect(sprites.borderLevel, Avatar.maxLevel);
      }
    });

    test('growth past the target changes nothing', () {
      final sprites = AvatarSprites(
        _avatar(BuildType.average, all: target * 10),
      );

      expect(sprites.regionLevel(AvatarRegion.abs), 3.0);
      expect(sprites.isMaxed, true);
    });

    test('a region shows the mean of its two muscles', () {
      // biceps maxed, triceps untrained: (3 + 0) / 2 = 1.5 -> step 1
      final sprites = AvatarSprites(
        _avatar(BuildType.average, only: {BodyPartName.biceps: target}),
      );

      expect(sprites.regionLevel(AvatarRegion.upperArm), 1.5);
      expect(sprites.regionStep(AvatarRegion.upperArm), 1);
      expect(sprites.regionSprite(AvatarRegion.upperArm), 1);
      // the rest of the body is still level 0, so the border stays at 0
      expect(sprites.borderLevel, 0);
    });

    test('one muscle short of max is not maxed', () {
      final almost = _avatar(
        BuildType.athletic,
        all: target,
        only: {BodyPartName.triceps: 0.0},
      );

      expect(AvatarSprites(almost).isMaxed, false);
    });
  });

  group('AvatarSprites weekly goal', () {
    test('the same growth fills a muscle faster for a lower goal', () {
      final goal1 = AvatarSprites(
        _avatar(BuildType.average, all: 2.0, weeklyGoal: 1),
      );
      final goal7 = AvatarSprites(
        _avatar(BuildType.average, all: 2.0, weeklyGoal: 7),
      );

      expect(goal1.growthTarget, 2.0);
      expect(goal1.isMaxed, true);
      expect(goal7.growthTarget, 14.0);
      expect(goal7.isMaxed, false);
    });
  });

  group('AvatarSprites build transition', () {
    test('skinny goes 100% -> 50% -> muscle layers as it grows', () {
      // at target 6.0: 0.3 -> mean level about -0.8, 1.0 -> about -0.3,
      // 1.6 -> above 0
      final early = AvatarSprites(_avatar(BuildType.skinny, all: 0.3));
      final middle = AvatarSprites(_avatar(BuildType.skinny, all: 1.0));
      final done = AvatarSprites(_avatar(BuildType.skinny, all: 1.6));

      expect(early.transitioning, true);
      expect(early.buildStage, 100);
      expect(middle.transitioning, true);
      expect(middle.buildStage, 50);
      expect(done.transitioning, false);
      expect(done.borderLevel, 0);
    });

    test('heavy follows the same steps as skinny', () {
      expect(AvatarSprites(_avatar(BuildType.heavy, all: 0.3)).buildStage, 100);
      expect(AvatarSprites(_avatar(BuildType.heavy, all: 1.0)).buildStage, 50);
      expect(
        AvatarSprites(_avatar(BuildType.heavy, all: 1.6)).transitioning,
        false,
      );
    });

    test('training one muscle does not finish the transition', () {
      // the transition depends on the mean of ALL muscles
      final sprites = AvatarSprites(
        _avatar(BuildType.skinny, only: {BodyPartName.pects: target}),
      );

      expect(sprites.transitioning, true);
    });
  });

  group('AvatarSprites sprite levels', () {
    test('a region sprite is never below the shared border level', () {
      final sprites = AvatarSprites(
        _avatar(BuildType.average, all: target / 2, only: {BodyPartName.abs: 0}),
      );

      // abs lags behind, so the shared level is its level, not the others
      expect(sprites.borderLevel, 0);
      for (final region in AvatarRegion.values) {
        expect(sprites.regionSprite(region), greaterThanOrEqualTo(0));
        expect(sprites.regionSprite(region), lessThanOrEqualTo(Avatar.maxLevel));
      }
      expect(sprites.regionSprite(AvatarRegion.pects), 1);
    });
  });
}
