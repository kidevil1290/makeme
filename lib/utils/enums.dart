enum Screens { login, home, habitLogger, avatarSpecs, notImplemented }

enum Gender { male, female }

enum BuildType { skinny, average, athletic, heavy }

// Face parts for the user to customize. 
// Number is amount of presets which is saved into HeadPart
enum HeadPart {
  hair(3),
  eyes(3),
  nose(3),
  mouth(3);

  final int optionCount;
  const HeadPart(this.optionCount);
}

enum BodyPartName {
  head,
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  legs,
}

// How hard a work out was, scales growth
enum Intensity { light, medium, heavy }
