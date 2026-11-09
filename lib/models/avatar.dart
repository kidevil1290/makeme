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
  final double skinTone;

  final Map<BodyPartName, double> muscleGrowth;

  // Does not construct without all required data
  const Avatar({
    required this.gender,
    required this.build,
    required this.head,
    required this.skinTone,
    this.muscleGrowth = const {},
  });

  // Returns the muscles growth
  double growthOf(BodyPartName part) => muscleGrowth[part] ?? 0.0;

  // Copy of this avatar with the growth map replaced
  Avatar copyWith({Map<BodyPartName, double>? muscleGrowth}) {
    return Avatar(
      gender: gender,
      build: build,
      head: head,
      skinTone: skinTone,
      muscleGrowth: muscleGrowth ?? this.muscleGrowth,
    );
  }

  // Adds the body parts muscle growth
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
}
