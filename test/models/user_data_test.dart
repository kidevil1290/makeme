import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/avatar.dart';
import 'package:makeme/models/head_config.dart';
import 'package:makeme/models/user_data.dart';
import 'package:makeme/utils/enums.dart';

// Sample avatar
Avatar _avatar(String name) {
  return Avatar(
    avatarName: name,
    weeklyGoal: 5,
    gender: Gender.male,
    build: BuildType.athletic,
    head: const HeadConfig(eyes: 2, nose: 1, mouth: 0, hair: 1),
    skinColor: const Color(0xFFC68642),
    hairColor: const Color(0xFF2B1B0E),
    muscleGrowth: {BodyPartName.pects: 2.5},
  );
}

// Goes through real JSON text, like storage will
UserData _roundTrip(UserData data) {
  final text = jsonEncode(data.toJson());
  return UserData.fromJson(jsonDecode(text) as Map<String, dynamic>);
}

void main() {
  group('UserData JSON', () {
    test('an empty UserData survives a round trip', () {
      final restored = _roundTrip(const UserData.empty());

      expect(restored.version, UserData.currentVersion);
      expect(restored.avatar, isNull);
      expect(restored.history, isEmpty);
      expect(restored.cycleStart, isNull);
    });

    test('a full UserData survives a round trip', () {
      // year, month, day, hour, minutes
      final start = DateTime(2026, 11, 19, 8, 30);
      final restored = _roundTrip(
        UserData(
          avatar: _avatar('Current'),
          history: [_avatar('Old')],
          cycleStart: start,
        ),
      );

      expect(restored.avatar?.avatarName, 'Current');
      expect(restored.history.length, 1);
      expect(restored.history.first.avatarName, 'Old');
      expect(restored.cycleStart, start);
    });

    test('an unreadable history record is skipped', () {
      final json = UserData(avatar: _avatar('Current')).toJson();
      json['history'] = [
        _avatar('Good').toJson(),
        {'broken': true},
      ];

      final restored = UserData.fromJson(json);

      expect(restored.history.length, 1);
      expect(restored.history.first.avatarName, 'Good');
    });

    test('a missing avatar loads as null', () {
      final json = UserData(avatar: _avatar('Current')).toJson();
      json.remove('avatar');

      expect(UserData.fromJson(json).avatar, isNull);
    });

    test('an unreadable current avatar throws', () {
      final json = const UserData.empty().toJson();
      json['avatar'] = {
        'broken': true,
      }; // replaces the avatar key with a map, makes it invalid

      expect(() => UserData.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('history keeps its order', () {
      final restored = _roundTrip(
        UserData(history: [_avatar('First'), _avatar('Second')]),
      );

      expect(restored.history.map((a) => a.avatarName), ['First', 'Second']);
    });

    test('a missing history loads as empty', () {
      final json = const UserData.empty().toJson();
      json.remove('history');

      expect(UserData.fromJson(json).history, isEmpty);
    });

    test('an unreadable date loads as null', () {
      final json = const UserData.empty().toJson();
      json['cycleStart'] = 'not a date';

      expect(UserData.fromJson(json).cycleStart, isNull);
    });
  });
}
