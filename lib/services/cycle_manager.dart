import '../models/avatar.dart';
import '../models/avatar_sprites.dart';

// UserProfile calls update() whenever the avatar changes
// Tracks the 91 day cycle (13 weeks) and decides when the avatar must ascend
class CycleManager {
  static const int cycleDays = 91;

  DateTime? _cycleStart;
  // Set by update(), because only a new workout can max the avatar
  bool _isMaxed = false;
  // A fixed "now" given by tests and the simulator; null means the real clock
  DateTime? _now;

  // Ascension is due when ALL of the avatar's muscles are maxed or 91 days have passed.
  // The day count is checked on every read, so day 91 arrives without a new workout
  bool get canAscend => _cycleStart != null && (_isMaxed || isComplete(_now));
  // True when ascension is due because every muscle region is at the top level
  bool get isMaxed => _cycleStart != null && _isMaxed;
  // UserProfile reads it to save
  DateTime? get cycleStart => _cycleStart;

  // Called after avatar creation
  void startCycle([DateTime? now]) {
    _cycleStart = now ?? DateTime.now();
    _isMaxed = false;
  }

  // Calculates how many whole days have elapsed since _cycleStart
  int daysElapsed([DateTime? now]) {
    final start = _cycleStart;
    if (start == null) return 0;
    return (now ?? DateTime.now()).difference(start).inDays;
  }

  // True once 91 days have passed since the cycle started
  bool isComplete([DateTime? now]) {
    return _cycleStart != null && daysElapsed(now) >= cycleDays;
  }

  // Checks the avatar again after its muscles changed
  void update(Avatar avatar, [DateTime? now]) {
    if (_cycleStart == null) return;
    _now = now;
    _isMaxed = AvatarSprites(avatar).isMaxed;
  }

  // For demos and testing.
  // Moves the start back 91 days so the cycle is over and ascension is due
  void forceComplete([DateTime? now]) {
    if (_cycleStart == null) return;
    _cycleStart = (now ?? DateTime.now()).subtract(
      const Duration(days: cycleDays),
    );
  }

  // Clears the cycle when user ascends
  void reset() {
    _cycleStart = null;
    _isMaxed = false;
    _now = null;
  }

  // Loads a saved cycle after app restarts
  // isMaxed is not saved, so it is recalculated here
  // No start date means no cycle, UserProfile must start a new one
  void restore(DateTime? start, Avatar? avatar, [DateTime? now]) {
    _cycleStart = start;
    _isMaxed = false;
    _now = now;
    if (avatar != null) update(avatar, now);
  }
}
