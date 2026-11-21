import '../utils/enums.dart';

// =====================================================
// Workout Log Entry
// =====================================================

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'bodyParts': bodyParts.map((e) => e.name).toList(),
      'intensity': intensity.name,
      'createdAt': createdAt.toIso8601String(),
      'templateUsed': templateUsed,
    };
  }
factory WorkoutLogEntry.fromJson(
  Map<String, dynamic> json,
) {
  final now = DateTime.now();

  return WorkoutLogEntry(
    // Old data may not contain an ID.
    id: json['id']?.toString() ??
        now.microsecondsSinceEpoch.toString(),

    // Duration
    durationMinutes:
        (json['durationMinutes'] as num?)?.toInt() ?? 0,

    // Body parts
    bodyParts: (json['bodyParts'] as List? ?? [])
    .map((e) => parseBodyPart(e.toString()))
    .whereType<BodyPartName>()
    .toList(),

    // Intensity
    intensity: Intensity.values.byName(
      json['intensity']?.toString() ??
          Intensity.medium.name,
    ),

    // Date
    createdAt: DateTime.tryParse(
          json['createdAt']?.toString() ?? '',
        ) ??
        now,

    // Template
    templateUsed: json['templateUsed']?.toString(),
  );
}
}

// =====================================================
// Workout Template
// =====================================================

class WorkoutTemplate {
  final String id;
  final String name;
  final List<BodyPartName> bodyParts;
  final Intensity intensity;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.bodyParts,
    required this.intensity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyParts': bodyParts.map((e) => e.name).toList(),
      'intensity': intensity.name,
    };
  }

  factory WorkoutTemplate.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyParts: (json['bodyParts'] as List)
          .map(
            (e) => BodyPartName.values.byName(e as String),
          )
          .toList(),
      intensity: Intensity.values.byName(
        json['intensity'] as String,
      ),
    );
  }
}

BodyPartName? parseBodyPart(String value) {
  for (final part in BodyPartName.values) {
    if (part.name.toLowerCase() == value.toLowerCase()) {
      return part;
    }
  }

  // Unknown body parts are skipped.
  return null;
}