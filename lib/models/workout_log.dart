import '../utils/enums.dart';
import '../utils/body_parts.dart';
import 'growth_calculator.dart';

class WorkoutLogEntry {
  final String id;
  final int durationMinutes;
  final List<BodyPartName> bodyParts;
  final Intensity intensity;
  final DateTime createdAt;

  final String? templateUsed;

  const WorkoutLogEntry({
    required this.id,
    required this.durationMinutes,
    required this.bodyParts,
    required this.intensity,
    required this.createdAt,
    this.templateUsed,
  });

  // The growth points this workout gives each muscle
  // Computed from the fields above, so it always matches the log
  Map<BodyPartName, double> get growthByPart {
    return GrowthCalculator.perPart(
      totalGrowth: GrowthCalculator.total(
        durationMinutes: durationMinutes,
        intensity: intensity,
      ),
      bodyParts: bodyParts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      // enums are saved by name, so reordering the enum cannot scramble old saves
      'bodyParts': bodyParts.map((e) => e.name).toList(),
      'intensity': intensity.name,
      'createdAt': createdAt.toIso8601String(),
      'templateUsed': templateUsed,
    };
  }

  // A missing or unreadable field throws,
  // and UserData then skips this one entry
  factory WorkoutLogEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutLogEntry(
      id: json['id'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      bodyParts: readBodyParts(json['bodyParts']),
      intensity: Intensity.values.byName(json['intensity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      templateUsed: json['templateUsed'] as String?,
    );
  }
}
