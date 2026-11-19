import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/head_config.dart';

void main() {
  // puts related tests under one name in the output
  group('HeadConfig JSON', () {
    test('survives a save and load round trip', () {
      const original = HeadConfig(eyes: 2, nose: 1, mouth: 0, hair: 1);

      final text = jsonEncode(original.toJson());

      final restored = HeadConfig.fromJson(
        jsonDecode(text) as Map<String, dynamic>,
      );

      // expect(actual, expected/matcher): fails if they differ
      expect(restored.eyes, 2);
      expect(restored.nose, 1);
      expect(restored.mouth, 0);
      expect(restored.hair, 1);
    });

    test('uses the field names as keys', () {
      // comparing two maps and checks every key and value
      // nose and mouth uses their default value
      expect(const HeadConfig(eyes: 2, hair: 1).toJson(), {
        'eyes': 2,
        'nose': 0,
        'mouth': 0,
        'hair': 1,
      });
    });

    test('missing keys fall back to 0', () {
      // an old or damaged save may not contain every key
      final restored = HeadConfig.fromJson({'eyes': 2});
      expect(restored.eyes, 2);
      expect(restored.nose, 0);
      expect(restored.mouth, 0);
      expect(restored.hair, 0);
    });

    test('corrupted options are clamped to a valid range', () {
      // loading retrieved values that are out of range
      final restored = HeadConfig.fromJson({
        'eyes': 7,
        'nose': -2,
        'mouth': 3,
        'hair': 1,
      });

      expect(restored.eyes, 2);
      expect(restored.nose, 0);
      expect(restored.mouth, 2);
      expect(restored.hair, 1);
    });
  });
}
