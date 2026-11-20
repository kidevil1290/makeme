import 'avatar.dart';

// Everything the app saves, as one immutable snapshot
// It only holds data and converts itself to and from JSON
class UserData {
  // bump when the saved format changes
  static const int currentVersion = 1;

  final int version;
  final Avatar? avatar;
  final List<Avatar> history;
  final DateTime?
  cycleStart; // when the current cycle began, CycleManager keeps the live copy

  const UserData({
    this.version = currentVersion,
    this.avatar,
    this.history = const [],
    this.cycleStart,
  });

  // What a fresh install loads: no avatar, no history, no cycle
  const UserData.empty() : this();

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'avatar': avatar?.toJson(),
      // iterates through the List of history -> map of simple values -> List of Maps
      'history': history.map((a) => a.toJson()).toList(),
      'cycleStart': cycleStart?.toIso8601String(), // converts DateTime to format "2026-11-20T08:30:00.000"
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatar'] as Map<String, dynamic>?;
    final rawStart = json['cycleStart'] as String?;

    final history = <Avatar>[];
    for (final item in (json['history'] as List?) ?? const []) {
      try {
        history.add(Avatar.fromJson(item as Map<String, dynamic>));
      } catch (_) {
        // skips this record and keeps the rest
      }
    }

    return UserData(
      version: (json['version'] as int?) ?? currentVersion,
      // nothing is saved? then null, otherwise build the avatar
      avatar: rawAvatar == null ? null : Avatar.fromJson(rawAvatar),
      history: history,
      // returns null for unreadable text instead of throwing
      // safeguard for bad Date that could wipe all progress
      cycleStart: rawStart == null ? null : DateTime.tryParse(rawStart),
    );
  }
}
