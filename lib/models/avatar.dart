import 'package:flutter/material.dart';

import '../utils/enums.dart';
import 'head_config.dart';

// Immutable snapshot of the user's avatar. Methods like addGrowth return a
// NEW Avatar, and UserProfile stores it and tells the UI to redraw it.
// muscleGrowth is the raw workout log: it starts at 0 and only ever grows, so
// the log stays consistent for the whole cycle. AvatarSprites translates it into
// the sprite levels the avatar is drawn with (see models/avatar_sprites.dart).
class Avatar {
  // Muscle level: 0 = average, 1 = small, 2 = medium, 3 = large.
  static const int maxLevel = 3;

  final String avatarName;
  final int weeklyGoal;
  final Gender gender;
  final BuildType build;
  final HeadConfig head;
  final Color skinColor;
  final Color hairColor;

  // Raw growth logged for each muscle. Starts at 0.0 and only increases;
  // AvatarSprites maps it (together with build) to the displayed level.
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

  // Constructor for new avatars at the start of their cycle.
  // Every build starts with an empty (0.0) log; the starting appearance comes
  // from the build in AvatarSprites, not from the stored growth.
  factory Avatar.start({
    required String avatarName,
    required int weeklyGoal,
    required Gender gender,
    required BuildType build,
    required HeadConfig head,
    required Color skinColor,
    required Color hairColor,
  }) {
    return Avatar(
      avatarName: avatarName,
      weeklyGoal: weeklyGoal,
      gender: gender,
      build: build,
      head: head,
      skinColor: skinColor,
      hairColor: hairColor,
      muscleGrowth: {for (final part in BodyPartName.values) part: 0.0},
    );
  }

  // Returns the raw growth of one muscle, or 0 if it has never been trained
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

  // Returns a new Avatar with amount added to one muscle's raw log.
  // The log only grows (kept at or above 0) and is never reset, so the user's
  // logging stays consistent for the whole cycle.
  Avatar addGrowth(BodyPartName part, double amount) {
    final double next = (growthOf(part) + amount).clamp(0.0, double.infinity);
    final Map<BodyPartName, double> updated = Map<BodyPartName, double>.from(
      muscleGrowth,
    );
    updated[part] = next;
    return copyWith(muscleGrowth: updated);
  }
}
