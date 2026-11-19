import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/utils/enums.dart';

// Sample of an Avatar
const _avatar = Avatar(
  avatarName: 'Shmuckatelee',
  weeklyGoal: 5,
  gender: Gender.male,
  build: BuildType.athletic,
  head: HeadConfig(eyes: 2, nose: 1, mouth: 0, hair: 1),
  skinColor: Color(0xFFC68642),
  hairColor: Color(0xFF2B1B0E),
  muscleGrowth: {BodyPartName.chest: 2.5, BodyPartName.legs: 1.0},
);

// Simulates save and load
// Goes through real JSON text, like storage will, so type problems show up
Avatar _roundTrip(Avatar avatar) {
  final text = jsonEncode(avatar.toJson());
  return Avatar.fromJson(jsonDecode(text) as Map<String, dynamic>);
}

void main() {
  group('Avatar JSON', () {
    test('survives a save and load roundtrip', () {
      final restored = _roundTrip(_avatar);

      expect(restored.avatarName, 'Shmuckatelee');
      expect(restored.weeklyGoal, 5);
      expect(restored.gender, Gender.male);
      expect(restored.build, BuildType.athletic);
      expect(restored.head.eyes, 2);
      expect(restored.head.hair, 1);
      expect(restored.growthOf(BodyPartName.chest), 2.5);
      expect(restored.growthOf(BodyPartName.legs), 1.0);
    });

    test('accepts whole numbers as growth values', () {
      final json = _avatar.toJson();
      json['MuscleGrowth'] = {'chest': 2, 'legs': 1};   // ints, not doubles

      final restored = Avatar.fromJson(json);

      expect(restored.growthOf(BodyPartName.chest), 2.0);
      expect(restored.growthOf(BodyPartName.legs), 1.0);
    });
    test('keeps the exact colors', () {
      final restored = _roundTrip(_avatar);

      expect(restored.skinColor.toARGB32(), 0xFFC68642);
      expect(restored.hairColor.toARGB32(), 0xFF2B1B0E);
    });

    test('saves enums by name and muscle map by muscle name', () {
      final json = _avatar.toJson();

      expect(json['gender'], 'male');
      expect(json['build'], 'athletic');
      expect(json['muscleGrowth'], {'chest': 2.5, 'legs': 1.0});
    });

    test('skips a muscle name that no longer exists', () {
      final json = _avatar.toJson();
      (json['muscleGrowth'] as Map<String, dynamic>)['horn'] = 3.0;  // adds horn into the JSON map

      final restored = Avatar.fromJson(json);

      expect(restored.growthOf(BodyPartName.chest), 2.5);
      expect(restored.growthOf(BodyPartName.legs), 1.0);
      expect(restored.muscleGrowth.length, 2);    // horn doesnt exist on the enum so it gets dropped
    });

    test('missing muscle map loads as an untrained avatar', () {
      final json = _avatar.toJson();
      json.remove('muscleGrowth');

      final restored = Avatar.fromJson(json);
      
      expect(restored.growthOf(BodyPartName.chest), 0.0);
    });

    test('a missing required field throws', () {
      final json = _avatar.toJson()..remove('gender');

      expect(() => Avatar.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
