import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/enums.dart';
import '../models/workoutlog.dart';

// =====================================================
// Workout Service
// =====================================================

class WorkoutService extends ChangeNotifier {
  static const String _historyKey = 'workout_history';
  static const String _templatesKey = 'workout_templates';

  final SharedPreferences _prefs;

  final List<WorkoutLogEntry> _history = [];
  final List<WorkoutTemplate> _templates = [];

  WorkoutTemplate? _pendingTemplate;

  void Function(BodyPartName, double)? onGrowth;

  WorkoutService._(this._prefs) {
    _loadHistory();
    _loadTemplates();
  }

  // ===================================================
  // Initialization
  // ===================================================

  static Future<WorkoutService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutService._(prefs);
  }

  // ===================================================
  // Getters
  // ===================================================

  List<WorkoutLogEntry> get history =>
      List.unmodifiable(_history);

  List<WorkoutTemplate> get templates =>
      List.unmodifiable(_templates);

  WorkoutTemplate? get pendingTemplate =>
      _pendingTemplate;

  int get totalWorkoutTime {
    return _history.fold<int>(
      0,
      (sum, entry) => sum + entry.durationMinutes,
    );
  }

  // ===================================================
  // Load Workout History
  // ===================================================

  void _loadHistory() {
    final saved = _prefs.getString(_historyKey);

    if (saved == null) return;

    final decoded = jsonDecode(saved) as List;

    _history
      ..clear()
      ..addAll(
        decoded.map(
          (e) => WorkoutLogEntry.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        ),
      );

    _sortHistory();
    notifyListeners();
  }

  // ===================================================
  // Save Workout History
  // ===================================================

  Future<void> _saveHistory() async {
    final encoded = jsonEncode(
      _history.map((e) => e.toJson()).toList(),
    );

    final saved = await _prefs.setString(
      _historyKey,
      encoded,
    );

    if (!saved) {
      throw StateError('Failed to save workout history');
    }
  }

  void _sortHistory() {
    _history.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
  }

  // ===================================================
  // Add Workout Log
  // ===================================================

  Future<WorkoutLogEntry> addWorkout({
    required int durationMinutes,
    required List<BodyPartName> bodyParts,
    required Intensity intensity,
    DateTime? date,
    String? templateUsed,
  }) async {
    if (durationMinutes <= 0) {
      throw ArgumentError(
        'Duration must be greater than zero',
      );
    }

    if (bodyParts.isEmpty) {
      throw ArgumentError(
        'At least one body part is required',
      );
    }

    final now = DateTime.now();

    final entry = WorkoutLogEntry(
      id: now.microsecondsSinceEpoch.toString(),
      durationMinutes: durationMinutes,
      bodyParts: List.of(bodyParts),
      intensity: intensity,
      createdAt: date ?? now,
      templateUsed: templateUsed,
    );

    _history.add(entry);
    _sortHistory();

    try {
      await _saveHistory();
    } catch (_) {
      _history.removeWhere((e) => e.id == entry.id);
      rethrow;
    }

    notifyListeners();

    return entry;
  }

  // ===================================================
  // Get Workout by ID
  // ===================================================

  WorkoutLogEntry? getById(String id) {
    for (final entry in _history) {
      if (entry.id == id) {
        return entry;
      }
    }

    return null;
  }

  // ===================================================
  // Get Workout History by Date
  // ===================================================

  List<WorkoutLogEntry> getLogsForDate(DateTime date) {
    return _history.where((entry) {
      return entry.createdAt.toLocal().year == date.year &&
          entry.createdAt.toLocal().month == date.month &&
          entry.createdAt.toLocal().day == date.day;
    }).toList();
  }

  // ===================================================
  // Delete Workout Log
  // ===================================================

  Future<void> deleteWorkout(String id) async {
    final previous = List<WorkoutLogEntry>.of(_history);

    _history.removeWhere((entry) => entry.id == id);

    try {
      await _saveHistory();
    } catch (_) {
      _history
        ..clear()
        ..addAll(previous);
      rethrow;
    }

    notifyListeners();
  }

  // ===================================================
  // Clear Workout History
  // ===================================================

  Future<void> clearHistory() async {
    final previous = List<WorkoutLogEntry>.of(_history);

    _history.clear();

    try {
      await _saveHistory();
    } catch (_) {
      _history.addAll(previous);
      rethrow;
    }

    notifyListeners();
  }

  // ===================================================
  // Load Workout Templates
  // ===================================================

  void _loadTemplates() {
    final saved = _prefs.getString(_templatesKey);

    if (saved == null) return;

    final decoded = jsonDecode(saved) as List;

    _templates
      ..clear()
      ..addAll(
        decoded.map(
          (e) => WorkoutTemplate.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        ),
      );

    notifyListeners();
  }

  // ===================================================
  // Save Workout Templates
  // ===================================================

  Future<void> _saveTemplates() async {
    final encoded = jsonEncode(
      _templates.map((e) => e.toJson()).toList(),
    );

    final saved = await _prefs.setString(
      _templatesKey,
      encoded,
    );

    if (!saved) {
      throw StateError('Failed to save workout templates');
    }
  }

  // ===================================================
  // Add Workout Template
  // ===================================================

  Future<WorkoutTemplate> addTemplate({
    required String name,
    required List<BodyPartName> bodyParts,
    required Intensity intensity,
  }) async {
    if (name.trim().isEmpty || bodyParts.isEmpty) {
      throw ArgumentError(
        'Template name and body parts are required',
      );
    }

    final template = WorkoutTemplate(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      name: name.trim(),
      bodyParts: List.of(bodyParts),
      intensity: intensity,
    );

    _templates.add(template);

    try {
      await _saveTemplates();
    } catch (_) {
      _templates.removeWhere(
        (e) => e.id == template.id,
      );
      rethrow;
    }

    notifyListeners();

    return template;
  }

  // ===================================================
  // Delete Workout Template
  // ===================================================

  Future<void> deleteTemplate(String id) async {
    final previous = List<WorkoutTemplate>.of(
      _templates,
    );

    _templates.removeWhere(
      (template) => template.id == id,
    );

    try {
      await _saveTemplates();
    } catch (_) {
      _templates
        ..clear()
        ..addAll(previous);
      rethrow;
    }

    if (_pendingTemplate?.id == id) {
      _pendingTemplate = null;
    }

    notifyListeners();
  }

  // ===================================================
  // Pending Template
  // ===================================================

  void setPendingTemplate(WorkoutTemplate template) {
    _pendingTemplate = template;
    notifyListeners();
  }

  void clearPendingTemplate() {
    _pendingTemplate = null;
    notifyListeners();
  }
}