enum Screens {
  login,
  home,
  habitLogger,
  avatarCreation,
  avatarSelection,
  notImplemented,
  workoutlog,
  template,
}

enum Gender { male, female }

// Starting build chosen in the initial survey.
// Skinny and heavy start every muscle at -1.0 then transition to average as the mean muscle level rises to 0.0:
// average starts at 0.0 and athletic at 1.0 (the small muscle level).
enum BuildType { heavy, skinny, average, athletic }

enum HeadPart {
  hair(3),
  eyes(3),
  nose(3),
  mouth(3);

  final int optionCount;
  const HeadPart(this.optionCount);
}

// The image layers the avatar body is drawn from.
// Each region has one sprite per (shared level, region level) pair.
enum AvatarRegion {
  abs,
  calves,
  forearms,
  lats,
  pects,
  shoulders,
  thighs,
  traps,
  upperArm,
}

// Muscles that can be trained in the workout logger.
// Each one grows the AvatarRegion it belongs to, so biceps and triceps are logged separately but both show on the upperArm layer.
// e.g. quads and glutes both show on the thighs layer.
enum BodyPartName {
  abs(AvatarRegion.abs),
  biceps(AvatarRegion.upperArm),
  calves(AvatarRegion.calves),
  forearms(AvatarRegion.forearms),
  glutes(AvatarRegion.thighs),
  lats(AvatarRegion.lats),
  pects(AvatarRegion.pects),
  quads(AvatarRegion.thighs),
  shoulders(AvatarRegion.shoulders),
  traps(AvatarRegion.traps),
  triceps(AvatarRegion.upperArm);

  final AvatarRegion region;
  const BodyPartName(this.region);
}

// How hard a work out was, scales growth
enum Intensity { light, medium, heavy }
