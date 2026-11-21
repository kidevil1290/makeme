import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/enums.dart';
import '../screens/workout_model.dart';

/// Handles workout logging, growth calculation, templates and history.
/// Stored on-device with shared_preferences. To move to a server later,
/// replace the _load/_save* methods; the screens won't need to change.
/// 

class WorkoutService extends ChangeNotifier {
  WorkoutService._(this._prefs);

  static const _historyKey = 'workout_history';
  static const _templatesKey = 'workout_templates';

  final SharedPreferences _prefs;
  final List<WorkoutLogEntry> _history = [];
  final List<WorkoutTemplate> _templates = [];
  WorkoutTemplate? _pendingTemplate;

  /// Called for every body part when a workout is confirmed.
  /// Hook this to your avatar, e.g.
  ///   service.onGrowth = (part, amount) => profile.addGrowth(part, amount);
  void Function(BodyPartName part, double amount)? onGrowth;

  static Future<WorkoutService> create() async {
    final service = WorkoutService._(await SharedPreferences.getInstance());
    service._load();
    return service;
  }

  // ------------------------------------------------------------- getters

  /// Newest first.
  List<WorkoutLogEntry> get history => List.unmodifiable(_history);
  List<WorkoutTemplate> get templates => List.unmodifiable(_templates);

  int get totalWorkouts => _history.length;
  int get totalMinutes =>
      _history.fold(0, (sum, e) => sum + e.durationMinutes);
  double get totalGrowth =>
      _history.fold(0.0, (sum, e) => sum + e.growthAmount);

  /// Summed growth for every body part (0 if never trained).
  Map<BodyPartName, double> get growthByPart {
    final totals = {for (final p in BodyPartName.values) p: 0.0};
    for (final entry in _history) {
      for (final e in entry.growthByPart.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value;
      }
    }
    return totals;
  }

  // ------------------------------------------------------- workout log

  /// Calculates growth, saves the entry to history and notifies listeners.
  Future<WorkoutLogEntry> confirmWorkout({
    required int durationMinutes,
    required List<BodyPartName> bodyParts,
    required Intensity intensity,
    String? templateUsed,
  }) async {
    final now = DateTime.now();
    final entry = WorkoutLogEntry(
      id: now.microsecondsSinceEpoch.toString(),
      timestamp: now,
      durationMinutes: durationMinutes,
      intensity: intensity,
      bodyParts: List.of(bodyParts),
      growthAmount: GrowthCalculator.total(
        durationMinutes: durationMinutes,
        intensity: intensity,
      ),
      templateUsed: templateUsed,
    );

    _history.insert(0, entry);
    for (final e in entry.growthByPart.entries) {
      onGrowth?.call(e.key, e.value);
    }
    notifyListeners();
    await _saveHistory();
    return entry;
  }

  // --------------------------------------------------------- templates

  /// Adds a template, or replaces one with the same name (case-insensitive).
  /// Returns true if an existing template was overwritten.
  Future<bool> saveTemplate(WorkoutTemplate template) async {
    final key = template.name.trim().toLowerCase();
    final index =
        _templates.indexWhere((t) => t.name.trim().toLowerCase() == key);
    final overwritten = index >= 0;
    if (overwritten) {
      _templates[index] = template;
    } else {
      _templates.add(template);
    }
    _templates.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    notifyListeners();
    await _saveTemplates();
    return overwritten;
  }

  Future<void> deleteTemplate(String name) async {
    final key = name.trim().toLowerCase();
    _templates.removeWhere((t) => t.name.trim().toLowerCase() == key);
    notifyListeners();
    await _saveTemplates();
  }

  /// Marks a template to pre-fill the Workout Log screen.
  void applyTemplate(WorkoutTemplate template) => _pendingTemplate = template;

  /// Returns the applied template once, then clears it.
  WorkoutTemplate? takePendingTemplate() {
    final template = _pendingTemplate;
    _pendingTemplate = null;
    return template;
  }

  // ------------------------------------------------------- persistence

  void _load() {
    _history
      ..clear()
      ..addAll(_decodeList(_historyKey, WorkoutLogEntry.fromJson))
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _templates
      ..clear()
      ..addAll(_decodeList(_templatesKey, WorkoutTemplate.fromJson))
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<T> _decodeList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    final result = <T>[];
    try {
      for (final item in jsonDecode(raw) as List) {
        try {
          result.add(fromJson(item as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Skipping unreadable item in $key: $e');
        }
      }
    } catch (e) {
      debugPrint('Could not read $key: $e');
    }
    return result;
  }

  Future<void> _saveHistory() => _prefs.setString(
        _historyKey,
        jsonEncode(_history.map((e) => e.toJson()).toList()),
      );

  Future<void> _saveTemplates() => _prefs.setString(
        _templatesKey,
        jsonEncode(_templates.map((t) => t.toJson()).toList()),
      );
}