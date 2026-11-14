import 'package:flutter/material.dart';

import 'avatar.dart';
import '../utils/enums.dart';
import '../models/head_config.dart';

// Owns the user's current avatar and tells the UI when it changes.
class UserProfile extends ChangeNotifier {
  Avatar? _avatar;

  Avatar? get avatar => _avatar;

  bool get hasAvatar => _avatar != null;

  // Null until avatar creation is finished
  // Writes only once: does nothing if an avatar already exists
  // Meant to be called once, when avatar creation is finished
  void createAvatar({
    required String avatarName,
    required int weeklyGoal,
    required Gender gender,
    required BuildType build,
    required HeadConfig head,
    required Color skinColor,
    required Color hairColor,
  }) {
    if (_avatar != null) return;
    _avatar = Avatar(
      avatarName: avatarName,
      weeklyGoal: weeklyGoal,
      gender: gender,
      build: build,
      head: head,
      skinColor: skinColor,
      hairColor: hairColor,
    );
    notifyListeners();
  }

  // Adds growth to one muscle
  // Stores the NEW Avatar from Avatar.addGrowth and tells UI to redraw it
  void addGrowth(BodyPartName part, double amount) {
    final current = _avatar;
    if (current == null) return;

    _avatar = current.addGrowth(part, amount);
    notifyListeners();
  }
}
