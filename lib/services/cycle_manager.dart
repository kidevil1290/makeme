import '../models/avatar.dart';
import '../models/avatar_sprites.dart';

// UserProfile calls update() whenever the avatar changes
// Tracks the 91 day cycle (13 weeks) and decides when the avatar can ascend
class CycleManager {
  static const int cycleDays = 91;

  DateTime? _cycleStart;
  bool _canAscend = false;

  bool get canAscend => _canAscend;
  // UserProfile reads it to save
  DateTime? get cycleStart => _cycleStart;

  // Called after avatar creation
  void startCycle([DateTime? now]) {
    _cycleStart = now ?? DateTime.now();
    _canAscend = false;
  }

  // Calculates how many whole days have elapsed since _cycleStart
  int daysElapsed([DateTime? now]) {
    final start = _cycleStart;
    if (start == null) return 0;
    return (now ?? DateTime.now()).difference(start).inDays;
  }

  // True once 91 days have passed, checked against the clock each time
  // (canAscend is only recalculated in update, so it can be out of date)
  bool isComplete([DateTime? now]) {
    return _cycleStart != null && daysElapsed(now) >= cycleDays;
  }

  // Ascension is offered when ALL of the avatar's muscles are maxed or 91 days have passed
  void update(Avatar avatar, [DateTime? now]) {
    if (_cycleStart == null) return;
    _canAscend = AvatarSprites(avatar).isMaxed || daysElapsed(now) >= cycleDays;
  }

  // Clears the cycle when user ascends
  void reset() {
    _cycleStart = null;
    _canAscend = false;
  }

  // Loads a saved cycle after app restarts
  // canAscend is not saved, so it is recalculated here
  // No start date means no cycle, UserProfile must start a new one
  void restore(DateTime? start, Avatar? avatar, [DateTime? now]) {
    _cycleStart = start;
    _canAscend = false;
    if (avatar != null) update(avatar, now);
  }
}
