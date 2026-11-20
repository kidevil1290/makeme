import 'package:flutter/material.dart';

import 'avatar.dart';
import '../utils/enums.dart';
import '../models/head_config.dart';
import '../services/cycle_manager.dart';

// Owns the user's current avatar,
// history of past avatars  and the cycle
// Tells the UI when it changes.
class UserProfile extends ChangeNotifier {
  Avatar? _avatar;
  final CycleManager _cycle = CycleManager();
  final List<Avatar> _history =[];

   // Null until avatar creation is finished
  Avatar? get avatar => _avatar;
  bool get hasAvatar => _avatar != null;
  bool get canAscend => _cycle.canAscend;
  List<Avatar> get history => List.unmodifiable(_history);

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
    _avatar = Avatar.start(
      avatarName: avatarName,
      weeklyGoal: weeklyGoal,
      gender: gender,
      build: build,
      head: head,
      skinColor: skinColor,
      hairColor: hairColor,
    );
    _cycle.startCycle();
    notifyListeners();
  }

  // Adds growth to one muscle
  // Stores the NEW Avatar from Avatar.addGrowth and tells UI to redraw it
  // Checks if avatar can ascend
  void addGrowth(BodyPartName part, double amount) {
    final current = _avatar;
    if (current == null) return;

    _avatar = current.addGrowth(part, amount);
    _cycle.update(_avatar!);
    notifyListeners();
  }

  // Ends the current avatar and resets the cycle
  // and adds the avatar in history
  void ascend() {
    final current = _avatar;
    if (current != null)_history.add(current);
    _avatar = null;
    _cycle.reset();
    notifyListeners();
  }
}
