import '../utils/enums.dart';

// How much an intensity level scales growth
extension IntensityMultiplier on Intensity {
  double get growthMultiplier => switch (this) {
    Intensity.light => 0.5,
    Intensity.moderate => 1.0,
    Intensity.heavy => 1.5,
  };
}

// Turns a workout into raw growth points for the avatar's muscles
//
//   total growth  = (minutes / 30) x intensity multiplier
//   per body part = total growth / number of selected body parts
//
// Example: 60 min, moderate, pects + back
//   total = (60 / 30) x 1.0 = 2.0  ->  1.0 for pects, 1.0 for back
//
// The numbers here and AvatarSprites.growthTarget have to be tuned together,
// because growthTarget decides how many of these points fill a muscle
class GrowthCalculator {
  static const double minutesPerUnit = 30;

  // CALIBRATION: raw growth a muscle needs to reach the max sprite level is
  //   target = targetPerGoalDay x weeklyGoal
  // so the goal the user picked sets the pace: a user who hits their own goal
  // with ~60 min moderate sessions (split across muscle groups) maxes every
  // muscle around week 10-12 of the 13 week cycle, with a few weeks of slack.
  // Training harder than the goal maxes earlier; training less than the goal
  // never maxes, and the avatar ascends at day 91 instead.
  // growth_calibration_test.dart checks this for every build and goal.
  static const double targetPerGoalDay = 2.0;

  static double targetFor(int weeklyGoal) {
    return weeklyGoal.clamp(1, 7).toInt() * targetPerGoalDay;
  }

  static double total({
    required int durationMinutes,
    required Intensity intensity,
  }) {
    final raw = (durationMinutes / minutesPerUnit) * intensity.growthMultiplier;
    return _round(raw);
  }

  static Map<BodyPartName, double> perPart({
    required double totalGrowth,
    required List<BodyPartName> bodyParts,
  }) {
    if (bodyParts.isEmpty) return {};
    final share = totalGrowth / bodyParts.length;
    return {for (final part in bodyParts) part: _round(share)};
  }

  // two decimals, so saved values stay short
  static double _round(double v) => (v * 100).round() / 100;
}
