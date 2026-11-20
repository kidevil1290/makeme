import 'dart:async';

import 'package:flutter/material.dart';

import 'avatar.dart';
import '../utils/enums.dart';
import '../models/head_config.dart';
import '../services/cycle_manager.dart';
import '../services/storage_service.dart';
import '../models/user_data.dart';

// Owns the user's current avatar,
// the history of past avatars, and the cycle.
// Tells the UI when it changes and saves after every change
class UserProfile extends ChangeNotifier {
  final StorageService _storage;
  Avatar? _avatar;
  final CycleManager _cycle = CycleManager();
  final List<Avatar> _history = [];

  UserProfile({
    required this._storage,
    UserData data = const UserData.empty(),
  }) {
    _avatar = data.avatar;
    _history.addAll(data.history);
    _cycle.restore(data.cycleStart, data.avatar);

    // An avatar with no cycle could never ascend, for example when the saved
    // date was unreadable, so a new cycle starts now
    final current = _avatar;
    if (current != null && _cycle.cycleStart == null) {
      _cycle.startCycle();
      _cycle.update(current);
      // a constructor cannot await, so the save runs in the background
      // saves the new date now, not at the next change
      unawaited(_save());
    }
  }

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
    _changed();
  }

  // Adds growth to one muscle
  void addGrowth(BodyPartName part, double amount) {
    addGrowthAll({part: amount});
  }

  // Batch the addGrowth to several muscles at once
  // One save and one redraw for the whole workout log
  // Each Avatar.addGrowth returns a NEW Avatar, so updated is passed along
  // and only the final one is stored
  void addGrowthAll(Map<BodyPartName, double> amounts) {
    final current = _avatar;
    if (current == null || amounts.isEmpty) return;

    var updated = current;
    for (final entry in amounts.entries) {
      updated = updated.addGrowth(entry.key, entry.value);
    }

    _avatar = updated;
    _cycle.update(updated);
    _changed();
  }

  // Ends the current avatar and resets the cycle
  // and adds the avatar in history
  void ascend() {
    final current = _avatar;
    if (current != null) _history.add(current);
    _avatar = null;
    _cycle.reset();
    _changed();
  }

  // Every change goes through here: save it, then tell the UI
  void _changed() {
    // not awaited: the redraw should not wait for the disk
    unawaited(_save());
    notifyListeners();
  }

  // The snapshot is built right away, before any waiting,
  // so a later change cannot sneak into this save
  Future<void> _save() async {
    try {
      await _storage.save(
        UserData(
          avatar: _avatar,
          // a copy, so the saved list cannot change afterwards
          history: List.of(_history),
          cycleStart: _cycle.cycleStart,
        ),
      );
    } catch (err) {
      debugPrint('Could not save: $err');
    }
  }
}
