import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/services/cycle_manager.dart';
import 'package:makeme/services/growth_simulator.dart';
import 'package:makeme/utils/enums.dart';

// 60 minute moderate sessions on exactly the days the goal asks for
SimProfile _onGoal(int goal) => SimProfile(
  name: 'on goal ($goal/week)',
  sessionsPerWeek: goal,
  minutes: 60,
  intensity: Intensity.moderate,
  routine: SimRoutines.pushPullLegs,
);

void main() {
  group('GrowthSimulator basics', () {
    test('runs day 0 to day 91', () {
      final run = GrowthSimulator.run(
        build: BuildType.average,
        profile: SimProfiles.onGoal,
      );

      expect(run.length, CycleManager.cycleDays + 1);
      expect(run.first.day, 0);
      expect(run.last.day, CycleManager.cycleDays);
    });

    test('sessions are spread over the week', () {
      expect(_onGoal(3).weekDays, [0, 2, 4]);
      expect(_onGoal(1).weekDays, [0]);
      expect(_onGoal(7).weekDays, [0, 1, 2, 3, 4, 5, 6]);
    });

    test('13 weeks of 3 sessions is 39 workouts, none on day 91', () {
      final run = GrowthSimulator.run(
        build: BuildType.average,
        profile: SimProfiles.onGoal,
      );

      expect(run[CycleManager.cycleDays - 1].sessionsDone, 39);
      expect(run.last.sessionsDone, 39);
    });

    test('growth comes from the real formula', () {
      // push day: 2.0 / 4 muscles = 0.5 each, 13 push days in 13 weeks
      // legs day: 2.0 / 3 muscles = 0.67 each (rounded), 13 leg days
      final avatar = GrowthSimulator.run(
        build: BuildType.average,
        profile: SimProfiles.onGoal,
      ).last.avatar;

      expect(avatar.growthOf(BodyPartName.pects), closeTo(6.5, 1e-9));
      expect(avatar.growthOf(BodyPartName.quads), closeTo(8.71, 1e-9));
    });
  });

  group('every build stays valid for the whole cycle', () {
    for (final build in BuildType.values) {
      for (final profile in SimProfiles.all) {
        for (final goal in [1, 3, 7]) {
          test('${build.name}, ${profile.name}, goal $goal', () {
            final run = GrowthSimulator.run(
              build: build,
              profile: profile,
              weeklyGoal: goal,
            );

            for (int i = 0; i < run.length; i++) {
              final sprites = run[i].sprites;

              // sprite files only exist for 0 <= g <= s <= 3
              expect(sprites.borderLevel, inInclusiveRange(0, Avatar.maxLevel));
              for (final region in AvatarRegion.values) {
                expect(
                  sprites.regionSprite(region),
                  inInclusiveRange(sprites.borderLevel, Avatar.maxLevel),
                );
              }
              if (sprites.transitioning) {
                expect(sprites.buildStage, anyOf(100, 50));
              }

              if (i == 0) continue;
              final before = run[i - 1];

              // the avatar only ever grows, never shrinks
              for (final part in BodyPartName.values) {
                expect(
                  run[i].avatar.growthOf(part),
                  greaterThanOrEqualTo(before.avatar.growthOf(part)),
                );
              }
              for (final region in AvatarRegion.values) {
                expect(
                  sprites.regionLevel(region),
                  greaterThanOrEqualTo(before.sprites.regionLevel(region)),
                );
              }
              expect(
                sprites.borderLevel,
                greaterThanOrEqualTo(before.sprites.borderLevel),
              );
              // a finished build transition never comes back
              if (!before.sprites.transitioning) {
                expect(sprites.transitioning, false);
              }
            }
          });
        }
      }
    }
  });

  group('build transition over the cycle', () {
    test('skinny and heavy pass through both stages before maxing', () {
      for (final build in [BuildType.skinny, BuildType.heavy]) {
        final run = GrowthSimulator.run(
          build: build,
          profile: SimProfiles.onGoal,
        );
        final stages = {
          for (final day in run)
            if (day.sprites.transitioning) day.sprites.buildStage,
        };
        final transitionEnds = run.firstWhere((d) => !d.sprites.transitioning);

        expect(stages, {100, 50}, reason: build.name);
        expect(
          transitionEnds.day,
          lessThan(GrowthSimulator.firstMaxedDay(run)!),
        );
      }
    });

    test('average and athletic never show a build body', () {
      for (final build in [BuildType.average, BuildType.athletic]) {
        final run = GrowthSimulator.run(
          build: build,
          profile: SimProfiles.onGoal,
        );

        expect(run.any((d) => d.sprites.transitioning), false);
      }
    });
  });

  group('91 day calibration', () {
    test('hitting your goal maxes every build inside the cycle', () {
      for (int goal = 1; goal <= 7; goal++) {
        final maxedDays = <int>{};

        for (final build in BuildType.values) {
          final run = GrowthSimulator.run(
            build: build,
            profile: _onGoal(goal),
            weeklyGoal: goal,
          );
          final maxed = GrowthSimulator.firstMaxedDay(run);

          expect(maxed, isNotNull, reason: '${build.name}, goal $goal');
          // week 9 to week 13: needs consistency, leaves slack before day 91
          expect(maxed!, inInclusiveRange(56, CycleManager.cycleDays - 1));
          // ascension is offered the day the avatar is maxed
          expect(run[maxed].canAscend, true);
          maxedDays.add(maxed);
        }

        // every build needs the same raw growth, so all max on the same day
        expect(maxedDays.length, 1, reason: 'goal $goal');
      }
    });

    test('training above the goal maxes earlier, but not instantly', () {
      for (final build in BuildType.values) {
        final onGoal = GrowthSimulator.firstMaxedDay(
          GrowthSimulator.run(build: build, profile: SimProfiles.onGoal),
        )!;
        final over = GrowthSimulator.firstMaxedDay(
          GrowthSimulator.run(build: build, profile: SimProfiles.overAchiever),
        )!;

        expect(over, lessThan(onGoal));
        expect(over, greaterThanOrEqualTo(28));
      }
    });

    test('training below the goal never maxes, ascends on day 91', () {
      for (final build in BuildType.values) {
        final run = GrowthSimulator.run(
          build: build,
          profile: SimProfiles.casual,
        );

        expect(GrowthSimulator.firstMaxedDay(run), isNull);
        expect(run.last.avatar.growthOf(BodyPartName.pects), greaterThan(0));
        expect(run[CycleManager.cycleDays - 1].canAscend, false);
        expect(run[CycleManager.cycleDays].canAscend, true);
      }
    });

    test('nobody can ascend on day 0', () {
      for (final build in BuildType.values) {
        for (final profile in SimProfiles.all) {
          final run = GrowthSimulator.run(build: build, profile: profile);

          expect(run.first.canAscend, false);
        }
      }
    });
  });
}
