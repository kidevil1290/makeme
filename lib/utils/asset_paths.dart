import 'enums.dart';

// Builds every sprite file path in one place
// screens dont need to type paths
class AssetPaths {
  AssetPaths._();

  static const String _root = 'assets/sprites';
  // The order for layering. back to front
  static const List<BodyPartName> bodyOrder = [
    BodyPartName.back,
    BodyPartName.legs,
    BodyPartName.core,
    BodyPartName.chest,
    BodyPartName.shoulders,
    BodyPartName.biceps,
    BodyPartName.triceps,
    BodyPartName.forearms,
  ];

  // e.g. assets/sprites/eyes_1.png
  static String headPart(HeadPart part, int option) {
    return '$_root/${part.name}_$option.png';
  }

  // e.g. assets/sprites/male_athletic_head.png
  static String head(Gender gender, BuildType build) {
    return '$_root/${gender.name}_${build.name}_head.png';
  }

  // e.g. assets/sprites/male_athletic_chest_2.png
  static String bodyPart(
    Gender gender,
    BuildType build,
    BodyPartName part,
    int stage,
  ) {
    return '$_root/${gender.name}_${build.name}_${part.name}_$stage.png';
  }
}
