import '../models/avatar.dart';
import '../models/avatar_sprites.dart';

// UserProfile calls update() whenever the avatar changes
// Tracks the 91 day cycle (13 weeks) and decides when the avatar can ascend
class CycleManager {
  static const int cycleDays = 91;

  DateTime? _cycleStart;
  bool _canAscend = false;

  bool get canAscend => _canAscend;

  // Called once after avatar creation
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
}
