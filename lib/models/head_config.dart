import '../utils/enums.dart';

class HeadConfig {
  final int _eyes;
  final int _nose;
  final int _mouth;
  final int _hair;

  const HeadConfig({
    this._eyes = 0,
    this._nose = 0,
    this._mouth = 0,
    this._hair = 0,
  });

  int get eyes => _eyes;
  int get nose => _nose;
  int get mouth => _mouth;
  int get hair => _hair;

  //
  HeadConfig copyWith({int? eyes, int? nose, int? mouth, int? hair}) {
    return HeadConfig(
      eyes: eyes ?? _eyes,
      nose: nose ?? _nose,
      mouth: mouth ?? _mouth,
      hair: hair ?? _hair,
    );
  }

  int optionFor(HeadPart part) {
    return switch (part) {
      HeadPart.eyes => eyes,
      HeadPart.nose => nose,
      HeadPart.mouth => mouth,
      HeadPart.hair => hair,
    };
  }

  HeadConfig withOption(HeadPart part, int option) {
    return switch (part) {
      HeadPart.eyes => copyWith(eyes: option),
      HeadPart.nose => copyWith(nose: option),
      HeadPart.mouth => copyWith(mouth: option),
      HeadPart.hair => copyWith(hair: option),
    };
  }
}
