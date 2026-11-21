import '../utils/enums.dart';

/// How much an intensity level scales growth.
/// NOTE: adjust the cases if your Intensity enum changes
/// (the class diagram says "moderate", the enum says "medium").
extension IntensityMultiplier on Intensity {
  double get growthMultiplier => switch (this) {
        Intensity.light => 0.5,
        Intensity.medium => 1.0,
        Intensity.heavy => 1.5,
      };
}

/// Workout growth calculation.
///
///   total growth = (minutes / 30) x intensity multiplier
///   per body part = total growth / number of selected body parts
///
/// Example: 60 min, medium, chest + back
///   total = (60 / 30) x 1.0 = 2.0  ->  1.0 for chest, 1.0 for back
class GrowthCalculator {
  static const double minutesPerUnit = 30;

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

  static double _round(double v) => (v * 100).round() / 100;
}

/// One saved workout in the history (the "WorkoutLog" in the class diagram).
/// Named WorkoutLogEntry so it doesn't clash with the WorkoutLog screen widget.
class WorkoutLogEntry {
  const WorkoutLogEntry({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.intensity,
    required this.bodyParts,
    required this.growthAmount,
    this.templateUsed,
  });

  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final Intensity intensity;
  final List<BodyPartName> bodyParts;
  final double growthAmount;
  final String? templateUsed;

  Map<BodyPartName, double> get growthByPart =>
      GrowthCalculator.perPart(totalGrowth: growthAmount, bodyParts: bodyParts);

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'durationMinutes': durationMinutes,
        'intensity': intensity.name,
        'bodyParts': bodyParts.map((p) => p.name).toList(),
        'growthAmount': growthAmount,
        'templateUsed': templateUsed,
      };

  factory WorkoutLogEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationMinutes: json['durationMinutes'] as int,
      intensity: Intensity.values.byName(json['intensity'] as String),
      bodyParts: (json['bodyParts'] as List)
          .map((p) => BodyPartName.values.byName(p as String))
          .toList(),
      growthAmount: (json['growthAmount'] as num).toDouble(),
      templateUsed: json['templateUsed'] as String?,
    );
  }
}

/// A reusable workout preset (no duration, per the class diagram).
class WorkoutTemplate {
  const WorkoutTemplate({
    required this.name,
    required this.bodyParts,
    required this.intensity,
  });

  final String name;
  final List<BodyPartName> bodyParts;
  final Intensity intensity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'bodyParts': bodyParts.map((p) => p.name).toList(),
        'intensity': intensity.name,
      };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      name: json['name'] as String,
      bodyParts: (json['bodyParts'] as List)
          .map((p) => BodyPartName.values.byName(p as String))
          .toList(),
      intensity: Intensity.values.byName(json['intensity'] as String),
    );
  }
}