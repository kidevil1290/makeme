import 'package:flutter/material.dart';

import '../utils/enums.dart';
import 'head_config.dart';

// Immutable snapshot of the user's avatar. Methods like addGrowth return a
// NEW Avatar, and UserProfile stores it and tells the UI to redraw it.
class Avatar {
  // Muscle level: 0 = average, 1 = small, 2 = medium, 3 = large.
  static const int maxLevel = 3;

  // For the starting muscle level of skinny/heavy builds:
  // The mean of all muscles from -1.0 up to 0.0 is the build transition,
  // -1.0 shows the full skinny/heavy body, -0.5 the halfway body, and 0.0 the average body.
  static const double transitionStart = -1.0;

  final String avatarName;
  final int weeklyGoal;
  final Gender gender;
  final BuildType build;
  final HeadConfig head;
  final Color skinColor;
  final Color hairColor;

  // Level of each trained muscle, up to maxLevel.
  // From 0.0 for average, 1.0 for athletic. From -1.0 for skinny/heavy while transitioning.
  final Map<BodyPartName, double> muscleGrowth;

  // Does not construct without all required data
  const Avatar({
    required this.avatarName,
    required this.weeklyGoal,
    required this.gender,
    required this.build,
    required this.head,
    required this.skinColor,
    required this.hairColor,
    this.muscleGrowth = const {},
  });

  // Contructor for new avatars at the start of their cycle.
  // Necessary for the implementation of the skinny/heavy builds.
  factory Avatar.start({
    required String avatarName,
    required int weeklyGoal,
    required Gender gender,
    required BuildType build,
    required HeadConfig head,
    required Color skinColor,
    required Color hairColor,
  }) {
    final bool transitions =
        build == BuildType.skinny || build == BuildType.heavy;
    final double startLevel = transitions ? transitionStart : (build == BuildType.athletic ? 1.0 : 0.0);
    return Avatar(
      avatarName: avatarName,
      weeklyGoal: weeklyGoal,
      gender: gender,
      build: build,
      head: head,
      skinColor: skinColor,
      hairColor: hairColor,
      muscleGrowth: {for (final part in BodyPartName.values) part: startLevel},
    );
  }

  // Returns the level of one muscle, or 0 if it has never been trained
  double growthOf(BodyPartName part) => muscleGrowth[part] ?? 0.0;

  // Gets mean level of all muscles (used for the skinny/heavy builds)
  double get meanGrowth {
    double total = 0.0;
    for (final part in BodyPartName.values) {
      total += growthOf(part);
    }
    return total / BodyPartName.values.length;
  }

  // Build transition step: the mean rounded down to the nearest 0.5:
  // -1.0 = full skinny/heavy, -0.5 = halfway, 0.0 = average.
  double get buildStep {
    final double step = (meanGrowth * 2).floor() / 2;
    return step.clamp(transitionStart, 0.0).toDouble();
  }

  // True once a skinny/heavy avatar has reached the average build.
  // Always true for average and athletic.
  bool get isBuildComplete => buildStep >= 0.0;

  // Level shown for an image region: the average of the muscles drawn on it
  // (biceps + triceps for upperArm, quads + glutes for thighs)
  double regionLevel(AvatarRegion region) {
    final parts = BodyPartName.values.where((p) => p.region == region);
    double total = 0.0;
    for (final part in parts) {
      total += growthOf(part);
    }
    return total / parts.length;
  }

  // Whole sprite level a region shows (level rounded down, 0 to maxLevel).
  // e.g. 1.9 shows level 1 and switches to level 2 at 2.0.
  int regionStep(AvatarRegion region) {
    return regionLevel(region).floor().clamp(0, maxLevel).toInt();
  }

  // Shared level g (the lowest whole level every region has reached).
  // So every region's border is drawn at this level so the layers line up.
  int get sharedLevel {
    int lowest = maxLevel;
    for (final region in AvatarRegion.values) {
      final int step = regionStep(region);
      if (step < lowest) lowest = step;
    }
    return lowest;
  }

  // True when every region has reached the highest level
  bool get isMaxed =>
      AvatarRegion.values.every((region) => regionStep(region) >= maxLevel);

  // Copy of this avatar with the growth map replaced
  Avatar copyWith({Map<BodyPartName, double>? muscleGrowth}) {
    return Avatar(
      avatarName: avatarName,
      weeklyGoal: weeklyGoal,
      gender: gender,
      build: build,
      head: head,
      skinColor: skinColor,
      hairColor: hairColor,
      muscleGrowth: muscleGrowth ?? this.muscleGrowth,
    );
  }

  // Returns a new Avatar with amount added to one muscle, kept between the lowest level (-1.0 while transitioning, otherwise 0.0) and maxLevel.
  // When this growth finishes a skinny/heavy transition, every muscle is reset to 0.0 so the average avatar starts levelling from scratch.
  Avatar addGrowth(BodyPartName part, double amount) {
    final bool transitioning = !isBuildComplete;
    final double lowest = transitioning ? transitionStart : 0.0;
    final double next = (growthOf(part) + amount)
        .clamp(lowest, maxLevel.toDouble())
        .toDouble();
    final Map<BodyPartName, double> updated = Map<BodyPartName, double>.from(
      muscleGrowth,
    );
    updated[part] = next;
    final Avatar grown = copyWith(muscleGrowth: updated);

    if (transitioning && grown.isBuildComplete) {
      return copyWith(
        muscleGrowth: {for (final p in BodyPartName.values) p: 0.0},
      );
    }
    return grown;
  }
}
