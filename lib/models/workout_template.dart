import '../utils/enums.dart';
import '../utils/body_parts.dart';

// A reusable workout preset: which muscles and how hard, but no duration
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

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyParts: readBodyParts(json['bodyParts']),
      intensity: Intensity.values.byName(json['intensity'] as String),
    );
  }
}
