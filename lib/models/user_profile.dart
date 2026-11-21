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

// Owns everything the user has: avatar, past avatars, workout history,
// templates and the cycle. Every change is saved through StorageService.
class UserProfile extends ChangeNotifier {
  final StorageService _storage;
  Avatar? _avatar;
  final CycleManager _cycle = CycleManager();
  final List<Avatar> _history = [];
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
  List<WorkoutLogEntry> get workoutHistory =>
      List.unmodifiable(_workoutHistory);
  List<WorkoutTemplate> get templates => List.unmodifiable(_templates);

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
      // a copy, to teh saved lists
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
          workoutHistory: List.of(_workoutHistory),
          templates: List.of(_templates),
          cycleStart: _cycle.cycleStart,
        ),
      );
    } catch (err) {
      debugPrint('Could not save: $err');
    }
  }
}
