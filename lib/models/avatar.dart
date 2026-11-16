import 'package:flutter/material.dart';

import '../utils/enums.dart';
import 'head_config.dart';

// Immutable snapshot of the user's avatar. Methods like addGrowth return a
// NEW Avatar, and UserProfile stores it and tells the UI to redraw it.
class Avatar {
  // Max growth a muscle can reach
  static const double maxGrowth = 4.0;

  final Gender gender;
  final BuildType build;
  final HeadConfig head;
  final Color skinColor;
  final String avatarName;
  final int weeklyGoal;
  final Color hairColor;

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

  // Returns the growth of one muscle, or 0 if it has never been trained
  double growthOf(BodyPartName part) => muscleGrowth[part] ?? 0.0;

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

  // Returns a new Avatar with amount added to one muscle kept between 0 and max
  Avatar addGrowth(BodyPartName part, double amount) {
    final double next = (growthOf(part) + amount)
        .clamp(0.0, maxGrowth)
        .toDouble();
    final Map<BodyPartName, double> updated = Map<BodyPartName, double>.from(
      muscleGrowth,
    );
    updated[part] = next;
    return copyWith(muscleGrowth: updated);
  }

  // True when every muscle has reached max growth
  bool get isMaxed =>
      BodyPartName.values.every((part) => growthOf(part) >= maxGrowth);
}
