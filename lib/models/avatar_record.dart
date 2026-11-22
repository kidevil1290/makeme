import 'avatar.dart';
import 'workout_log.dart';

// Record of an avatar as it ended and how the cycle went
// Snapshot after user ascends and never changes
class AvatarRecord {
  final Avatar avatar;
  // when the cycle started and ended
  final DateTime startedAt;
  final DateTime endedAt;
  // weeks counted in 7 day blocks from startedAt when the avatar was created
  // compares to the users weeklyGoal
  final int weeksMet;
  // weeks the cycle last: 13 for a full cycle, fewer if the avatar
  // maxed and ascended early
  // does not count partial weeks
  final int totalWeeks;

  const AvatarRecord({
    required this.avatar,
    required this.startedAt,
    required this.endedAt,
    required this.weeksMet,
    required this.totalWeeks,
  });

  factory AvatarRecord.finish({
    required Avatar avatar,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<WorkoutLogEntry> workouts,
  }) {
    final int startDay = _dayNumber(startedAt);
    // only whole weeks count
    // the ~/ drops the decimal from the operation
    final int totalWeeks = (_dayNumber(endedAt) - startDay) ~/ 7;
    // for each week the set of days the user trained on
    // A set, so two workouts on one day count as one day
    final Map<int, Set<int>> daysPerWeek = {};
    for (final workout in workouts) {
      final int day = _dayNumber(workout.createdAt) - startDay;
      final int week = day ~/ 7;

      if (day < 0 || week >= totalWeeks) continue;
      daysPerWeek.putIfAbsent(week, () => {}).add(day);
    }

    // Counts the weeks where the distinct training days
    // reach the weeklyGoal
    var weeksMet = 0;
    for (final days in daysPerWeek.values) {
      if (days.length >= avatar.weeklyGoal) weeksMet++;
    }

    return AvatarRecord(
      avatar: avatar,
      startedAt: startedAt,
      endedAt: endedAt,
      weeksMet: weeksMet,
      totalWeeks: totalWeeks,
    );
  }

  // The calendar as a whole number so time doesn't matter
  static int _dayNumber(DateTime date) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(1970)).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'weeksMet': weeksMet,
      'totalWeeks': totalWeeks,
    };
  }

  // Strict like WorkoutLogEntry: a missing or unreadable field throws,
  // and UserData then skips this one record and keeps the others
  factory AvatarRecord.fromJson(Map<String, dynamic> json) {
    return AvatarRecord(
      avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      weeksMet: json['weeksMet'] as int,
      totalWeeks: json['totalWeeks'] as int,
    );
  }
}
