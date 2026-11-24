import 'dart:async';

import 'package:flutter/material.dart';

import 'avatar.dart';
import '../utils/enums.dart';
import '../models/head_config.dart';
import '../services/cycle_manager.dart';
import '../services/storage_service.dart';
import '../models/user_data.dart';
import '../models/workout_log.dart';
import '../models/workout_template.dart';
import '../models/avatar_record.dart';
import '../models/avatar_sprites.dart';
import '../utils/asset_paths.dart';

// Owns everything the user has: avatar, finished cycles, workout history,
// templates, the cycle and the ascension level. Every change is saved through StorageService.
class UserProfile extends ChangeNotifier {
  // Highest ascension level: one badge per level, the last badge is the max
  static const int maxAscensionLevel = AssetPaths.badgeCount;

  final StorageService _storage;
  // 0 for the first avatar, +1 each time an avatar ascends.
  // Kept here, not on the Avatar, so the next avatar the user creates inherits it
  int _ascensionLevel = 0;
  Avatar? _avatar;
  final CycleManager _cycle = CycleManager();
  final List<AvatarRecord> _history = [];
  final List<WorkoutLogEntry> _workoutHistory = [];
  final List<WorkoutTemplate> _templates = [];
  // The template picked for the next workout, kept in memory only
  // because it is a temporary choice, not user data
  WorkoutTemplate? _pendingTemplate;

  UserProfile({
    required this._storage,
    UserData data = const UserData.empty(),
  }) {
    _avatar = data.avatar;
    _history.addAll(data.history);
    _workoutHistory.addAll(data.workoutHistory);
    _templates.addAll(data.templates);
    // clamped as a safeguard for a corrupted save
    _ascensionLevel = data.ascensionLevel.clamp(0, maxAscensionLevel);
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
  // CycleManager decides: the avatar is maxed or its 91 day cycle is over.
  // Home forces the ascension while this is true
  bool get canAscend => hasAvatar && _cycle.canAscend;
  // Why ascension is due: true for maxed muscles, false for the end of the cycle
  bool get isMaxed => hasAvatar && _cycle.isMaxed;
  List<AvatarRecord> get history => List.unmodifiable(_history);
  List<WorkoutLogEntry> get workoutHistory =>
      List.unmodifiable(_workoutHistory);
  List<WorkoutTemplate> get templates => List.unmodifiable(_templates);
  int get ascensionLevel => _ascensionLevel;

  // True when the next ascension will not raise the level (last badge reached)
  bool get atMaxAscension => _ascensionLevel >= maxAscensionLevel;

  // For demos and testing.
  // Ends the 91 day cycle now, so Home shows the "completed your cycle" dialog.
  // Saved like a real cycle end, so it also survives a restart
  void forceEndCycle() {
    if (_avatar == null) return;
    _cycle.forceComplete();
    _changed();
  }

  // For demos and testing.
  // Adds the growth AvatarSprites says is missing, so the avatar is maxed and
  // Home shows the "maximum muscle growth" dialog. The growth is saved,
  // so it also survives a restart
  void forceMaxed() {
    final current = _avatar;
    if (current == null) return;
    if (!_applyGrowth(AvatarSprites(current).growthToMax())) return;
    _changed();
  }

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

  // Changes the avatar and the cycle but does not save or redraw
  // Returns false when there was nothing to change
  bool _applyGrowth(Map<BodyPartName, double> amounts) {
    final current = _avatar;
    if (current == null || amounts.isEmpty) return false;

    var updated = current;
    for (final entry in amounts.entries) {
      updated = updated.addGrowth(entry.key, entry.value);
    }

    _avatar = updated;
    _cycle.update(updated);
    return true;
  }

  // Records a workout, grows the muscles it trained, then saves once.
  WorkoutLogEntry addWorkout({
    required int durationMinutes,
    required List<BodyPartName> bodyParts,
    required Intensity intensity,
    DateTime? date,
    String? templateUsed,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError('Duration must be greater than zero');
    }
    if (bodyParts.isEmpty) {
      throw ArgumentError('At least one body part is required');
    }

    final now = DateTime.now();
    final entry = WorkoutLogEntry(
      id: now.microsecondsSinceEpoch.toString(),
      durationMinutes: durationMinutes,
      // a copy, so the caller's list cannot change the saved workout
      bodyParts: List.of(bodyParts),
      intensity: intensity,
      createdAt: date ?? now,
      templateUsed: templateUsed,
    );

    _workoutHistory.add(entry);
    _applyGrowth(entry.growthByPart);
    _changed();
    return entry;
  }

  WorkoutTemplate addTemplate({
    required String name,
    required List<BodyPartName> bodyParts,
    required Intensity intensity,
  }) {
    if (name.trim().isEmpty || bodyParts.isEmpty) {
      throw ArgumentError('Template name and body parts are required');
    }

    final template = WorkoutTemplate(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      bodyParts: List.of(bodyParts),
      intensity: intensity,
    );

    _templates.add(template);
    _changed();
    return template;
  }

  void deleteTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    // a deleted template cannot stay picked for the next workout
    if (_pendingTemplate?.id == id) _pendingTemplate = null;
    _changed();
  }

  // Not saved, so no _changed(): only the UI needs to hear about these
  void setPendingTemplate(WorkoutTemplate template) {
    _pendingTemplate = template;
    notifyListeners();
  }

  // Hands over the picked template once and forgets it
  // No notifyListeners: nothing displays it, and this is called while
  // the log screen is being built, where notifying would cause an error
  WorkoutTemplate? takePendingTemplate() {
    final template = _pendingTemplate;
    _pendingTemplate = null;
    return template;
  }

  // Saves the finished avatar as a record in history, raises the ascension
  // level by 1 (up to the max) for the next avatar, then clears the avatar
  // and resets the cycle. Home calls it when canAscend is true
  void ascend() {
    final current = _avatar;
    if (current != null) {
      if (_ascensionLevel < maxAscensionLevel) _ascensionLevel++;
      final now = DateTime.now();
      _history.add(
        AvatarRecord.finish(
          avatar: current,
          startedAt: _cycle.cycleStart ?? now,
          endedAt: now,
          workouts: _workoutHistory,
        ),
      );
    }
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
          // copies, so a later change to these lists cannot change this save
          history: List.of(_history),
          workoutHistory: List.of(_workoutHistory),
          templates: List.of(_templates),
          cycleStart: _cycle.cycleStart,
          ascensionLevel: _ascensionLevel,
        ),
      );
    } catch (err) {
      debugPrint('Could not save: $err');
    }
  }
}
