import 'avatar.dart';
import 'workout_log.dart';
import 'workout_template.dart';
import 'avatar_record.dart';

// Everything the app saves, as one immutable snapshot
// It only holds data and converts itself to and from JSON
class UserData {
  // bump when the saved format changes
  static const int currentVersion = 1;

  final int version;
  final Avatar? avatar;
  // finished cycles, one record for each ascension
  final List<AvatarRecord> history;
  // every logged workout, UserProfile keeps oldest first
  final List<WorkoutLogEntry> workoutHistory;
  // user's saved workout templates
  final List<WorkoutTemplate> templates;
  // when the current cycle began, CycleManager keeps the live copy
  final DateTime? cycleStart;
  // how many times the user has ascended, carried over to the next avatar
  final int ascensionLevel;
  // true once the "you can ascend" dialog was shown for the current avatar
  final bool ascendPromptShown;

  const UserData({
    this.version = currentVersion,
    this.avatar,
    this.history = const [],
    this.workoutHistory = const [],
    this.templates = const [],
    this.cycleStart,
    this.ascensionLevel = 0,
    this.ascendPromptShown = false,
  });

  // What a fresh install loads: no avatar, no history, no cycle
  const UserData.empty() : this();

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'avatar': avatar?.toJson(),
      // iterates through the List of history -> map of simple values -> List of Maps
      'history': history.map((a) => a.toJson()).toList(),
      'workoutHistory': workoutHistory.map((w) => w.toJson()).toList(),
      'templates': templates.map((t) => t.toJson()).toList(),
      // converts DateTime to format "2026-11-20T08:30:00.000"
      'cycleStart': cycleStart?.toIso8601String(),
      'ascensionLevel': ascensionLevel,
      'ascendPromptShown': ascendPromptShown,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar'] as Map<String, dynamic>?;
    final rawStart = json['cycleStart'] as String?;

    return UserData(
      version: (json['version'] as int?) ?? currentVersion,
      // nothing is saved? then null, otherwise build the avatar
      avatar: rawAvatar == null ? null : Avatar.fromJson(rawAvatar),
      history: _readList(json['history'], AvatarRecord.fromJson),
      workoutHistory: _readList(
        json['workoutHistory'],
        WorkoutLogEntry.fromJson,
      ),
      templates: _readList(json['templates'], WorkoutTemplate.fromJson),
      // returns null for unreadable text instead of throwing
      // safeguard for bad Date that could wipe all progress
      cycleStart: rawStart == null ? null : DateTime.tryParse(rawStart),
      // saves from before ascension levels existed have no value: start at 0
      ascensionLevel: (json['ascensionLevel'] as int?) ?? 0,
      // missing means the dialog was never shown
      ascendPromptShown: (json['ascendPromptShown'] as bool?) ?? false,
    );
  }

  // Generic helper function that reads a saved list and skips
  // any entry that cannot be read
  static List<T> _readList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = <T>[];
    for (final item in (raw as List?) ?? const []) {
      try {
        items.add(fromJson(item as Map<String, dynamic>));
      } catch (_) {
        // skips this entry and keeps the rest
      }
    }
    return items;
  }
}
