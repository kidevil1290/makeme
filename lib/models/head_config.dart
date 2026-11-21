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

  // Copy with some parts changed, parts left out will keep their value
  HeadConfig copyWith({int? eyes, int? nose, int? mouth, int? hair}) {
    return HeadConfig(
      eyes: eyes ?? _eyes,
      nose: nose ?? _nose,
      mouth: mouth ?? _mouth,
      hair: hair ?? _hair,
    );
  }

  // Generic way to read any face part's option
  int optionFor(HeadPart part) {
    return switch (part) {
      HeadPart.eyes => eyes,
      HeadPart.nose => nose,
      HeadPart.mouth => mouth,
      HeadPart.hair => hair,
    };
  }

  // Returns a new HeadConfig with the given part changed to the given option.
  HeadConfig withOption(HeadPart part, int option) {
    return switch (part) {
      HeadPart.eyes => copyWith(eyes: option),
      HeadPart.nose => copyWith(nose: option),
      HeadPart.mouth => copyWith(mouth: option),
      HeadPart.hair => copyWith(hair: option),
    };
  }

  // Returns a map of the currently selected head options into a map
  Map<String, dynamic> toJson() {
    return {'eyes': _eyes, 'nose': _nose, 'mouth': _mouth, 'hair': _hair};
  }

  // builds a HeadConfig from a map from jsonDecode
  // missing keys default to 0 and out of range values are clamped
  factory HeadConfig.fromJson(Map<String, dynamic> json) {
    return HeadConfig(
      eyes: _optionFromJson(json['eyes'], HeadPart.eyes),
      nose: _optionFromJson(json['nose'], HeadPart.nose),
      mouth: _optionFromJson(json['mouth'], HeadPart.mouth),
      hair: _optionFromJson(json['hair'], HeadPart.hair),
    );
  }

  // Reads on saved option and clamps it into valid range
  // as a safeguard for corrupted values
  static int _optionFromJson(Object? raw, HeadPart part) {
    final value = (raw as int?) ?? 0;
    return value.clamp(0, part.optionCount - 1);
  }
}
