import 'enums.dart';

// Builds every sprite file path in one place
// screens dont need to type paths
// Sprites are lossless WebP at 1x/2x/3x for different screen resolutions (automatically picked by Flutter)
class AssetPaths {
  AssetPaths._();

  static const String _root = 'assets/sprites';
  static const String _ext = 'webp';

  // The order for layering, back to front
  static const List<AvatarRegion> bodyOrder = [
    AvatarRegion.abs,
    AvatarRegion.calves,
    AvatarRegion.forearms,
    AvatarRegion.lats,
    AvatarRegion.pects,
    AvatarRegion.shoulders,
    AvatarRegion.thighs,
    AvatarRegion.traps,
    AvatarRegion.upperArm,
  ];

  // Percent stages rendered for the skinny and heavy builds, highest first.
  // 0% is the average body itself (the muscle layers at shared level 0).
  static const List<int> buildStages = [100, 50];

  // One muscle region at shared level g and region level s (where g <= s).
  // e.g. assets/sprites/male_shoulders_g0_s3.webp
  static String bodyLayer(Gender gender, AvatarRegion region, int g, int s) {
    return '$_root/${gender.name}_${region.name}_g${g}_s$s.$_ext';
  }

  // Whole body (without head) for a skinny/heavy build stage
  // e.g. assets/sprites/male_heavy_50.webp
  static String buildLayer(Gender gender, BuildType build, int stage) {
    return '$_root/${gender.name}_${build.name}_$stage.$_ext';
  }

  // Head, matched to shared level g so the neck lines up.
  // The eye openings and the face are transparent holes that the eyes layer and the face presets fill.
  // e.g. assets/sprites/male_head_g1.webp
  static String head(Gender gender, int g) {
    return '$_root/${gender.name}_head_g$g.$_ext';
  }

  // Eyeballs only, drawn under the head and NOT tinted.
  // The same for every level.
  // e.g. assets/sprites/male_eyes.webp
  static String eyes(Gender gender) {
    return '$_root/${gender.name}_eyes.$_ext';
  }

  // Face presets: nose, mouth and eye shape, one layer each,
  // drawn over the head. Option 0 is the default shape. The same for every level with skin tinted.
  // e.g. assets/sprites/male_face_nose_1.webp
  static String facePart(Gender gender, HeadPart part, int option) {
    assert(part != HeadPart.hair, 'hair uses AssetPaths.hair');
    return '$_root/${gender.name}_face_${part.name}_$option.$_ext';
  }

  // Hair style option (with eyebrows) at shared level g.
  // The back of the hair is cut where the neck and shoulders cover it, which changes with g.
  // e.g. assets/sprites/female_hair_2_g1.webp
  static String hair(Gender gender, int option, int g) {
    return '$_root/${gender.name}_hair_${option}_g$g.$_ext';
  }

  // Number of ascension badges in assets/badges (badge01 to badge16).
  // Also the highest ascension level, see UserProfile.maxAscensionLevel
  static const int badgeCount = 16;

  // Badge for an ascension level from 1 to badgeCount, two digit number.
  // e.g. assets/badges/badge03.png
  static String badge(int level) {
    final int n = level.clamp(1, badgeCount);
    return 'assets/badges/badge${n.toString().padLeft(2, '0')}.png';
  }
}
