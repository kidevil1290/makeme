import '../utils/enums.dart';
import 'avatar.dart';
import 'growth_calculator.dart';

// Translates an avatar's raw muscleGrowth log into the sprite levels AvatarDisplay draws.
// muscleGrowth is the untampered workout log (raw points that only ever increase);
// this class maps it to the displayed level without changing the stored data.
// level = baseline + (maxLevel - baseline) * clamp(raw / growthTarget, 0, 1),
// so every build reaches g3/s3 once a muscle's raw growth reaches growthTarget.
class AvatarSprites {
  final Avatar avatar;
  const AvatarSprites(this.avatar);

  // Raw growth that maps a muscle to the max sprite level.
  // Comes from the avatar's weekly goal, see GrowthCalculator.targetFor.
  double get growthTarget => GrowthCalculator.targetFor(avatar.weeklyGoal);

  // Starting display level per build: athletic begins a level ahead, skinny/heavy
  // a level behind (the build-body transition), average at 0.
  double get _baseline => switch (avatar.build) {
        BuildType.athletic => 1.0,
        BuildType.skinny || BuildType.heavy => -1.0,
        BuildType.average => 0.0,
      };

  // Translated display level of one muscle: baseline -> maxLevel as raw -> growthTarget.
  double _levelOf(BodyPartName part) {
    final double f = (avatar.growthOf(part) / growthTarget).clamp(0.0, 1.0);
    return _baseline + (Avatar.maxLevel - _baseline) * f;
  }

  // Mean translated level of a region's muscles
  // (biceps + triceps for upperArm, quads + glutes for thighs).
  double regionLevel(AvatarRegion region) {
    final parts = BodyPartName.values.where((p) => p.region == region);
    double total = 0.0;
    for (final part in parts) {
      total += _levelOf(part);
    }
    return total / parts.length;
  }

  // Whole sprite level a region shows (its mean level rounded down, 0 to maxLevel).
  int regionStep(AvatarRegion region) {
    return regionLevel(region).floor().clamp(0, Avatar.maxLevel).toInt();
  }

  // Mean translated level of ALL muscles, used for the skinny/heavy transition.
  double get _meanLevel {
    double total = 0.0;
    for (final part in BodyPartName.values) {
      total += _levelOf(part);
    }
    return total / BodyPartName.values.length;
  }

  // Build transition step: the mean rounded down to the nearest 0.5.
  double get _buildStep => (_meanLevel * 2).floor() / 2;

  // True while a skinny/heavy build has not reached the average build yet.
  bool get transitioning => _meanLevel < 0;

  // Build-body stage while transitioning: 100 (full) or 50 (halfway).
  int get buildStage => (_buildStep.clamp(-1.0, 0.0) * -100).round();

  // Shared level g: the lowest whole level every region has reached, so every
  // region's border is drawn at this level and the layers line up.
  int get sharedLevel {
    int lowest = Avatar.maxLevel;
    for (final region in AvatarRegion.values) {
      final int step = regionStep(region);
      if (step < lowest) lowest = step;
    }
    return lowest;
  }

  // Border level g the body, head and hair layers share.
  // 0 during the build transition, otherwise the shared level.
  int get borderLevel => transitioning ? 0 : sharedLevel;

  // Interior level s for one region: its own whole level, never below g.
  int regionSprite(AvatarRegion region) {
    return regionStep(region).clamp(borderLevel, Avatar.maxLevel).toInt();
  }

  // True when every region has reached the highest level (used by CycleManager).
  bool get isMaxed =>
      AvatarRegion.values.every((region) => regionStep(region) >= Avatar.maxLevel);
}
