enum Screens { login, home, habitLogger, avatarSpecs, notImplemented, signup}

enum Gender { male, female }

enum BuildType { skinny, average, athletic, heavy }

enum HeadPart
{
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

enum Intensity { light, medium, heavy }
