import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/avatar_sprites.dart';
import '../services/cycle_manager.dart';
import '../services/growth_simulator.dart';
import '../services/screen_manager.dart';
import '../theme/theme.dart';
import '../utils/enums.dart';
import '../widgets/avatar_display.dart';
import '../models/avatar.dart';
import '../models/user_profile.dart';


// Developer tool (reached from the profile menu in debug builds).
// Replays a 91 day cycle for every build at once so the growth can be watched:
// drag the day slider or press play. It runs the same code as the app and as
// test/growth_calibration_test.dart, it only draws the result.
class GrowthDebugScreen extends StatefulWidget {
  const GrowthDebugScreen({super.key});

  @override
  State<GrowthDebugScreen> createState() => _GrowthDebugScreenState();
}

class _GrowthDebugScreenState extends State<GrowthDebugScreen> {
  static const List<BuildType> _allBuilds = BuildType.values;

  // The user's real avatar: gender, head and colors all come from it
  late final Avatar _base;

  SimProfile _profile = SimProfiles.onGoal;
  late int _goal;
  bool _myBuildOnly = false;
  int _day = 0;
  Timer? _timer;

  // One finished 91 day run per build, rebuilt only when a setting changes
  late Map<BuildType, List<DaySnapshot>> _runs;

  List<BuildType> get _builds => _myBuildOnly ? [_base.build] : _allBuilds;

  @override
  void initState() {
    super.initState();
    _base = context.read<UserProfile>().avatar!;
    _goal = _base.weeklyGoal;
    _runs = _simulate();
  }

    Map<BuildType, List<DaySnapshot>> _simulate() {
      return {
        for (final build in _builds)
          build: GrowthSimulator.run(
            base: _base,
            profile: _profile,
            build: build,
            weeklyGoal: _goal,
          ),
      };
    }

  void _resimulate(VoidCallback change) {
    setState(() {
      change();
      _runs = _simulate();
    });
  }

  void _togglePlay() {
    if (_timer != null) {
      _stop();
      return;
    }
    if (_day >= CycleManager.cycleDays) _day = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (_day >= CycleManager.cycleDays) {
        _stop();
        return;
      }
      setState(() => _day++);
    });
    setState(() {});
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<ScreenManager>().goBack(),
        ),
        title: const Text('Growth Simulator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _settings(),
            Expanded(child: _avatars()),
            _dayControls(),
          ],
        ),
      ),
    );
  }

  Widget _settings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          DropdownButton<SimProfile>(
            isExpanded: true,
            value: _profile,
            items: [
              for (final p in SimProfiles.all)
                DropdownMenuItem(value: p, child: Text(p.name)),
            ],
            onChanged: (p) {
              if (p != null) _resimulate(() => _profile = p);
            },
          ),
          Row(
            children: [
              const Text('Goal'),
              Expanded(
                child: Slider(
                  value: _goal.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_goal days/week',
                  onChanged: (v) => _resimulate(() => _goal = v.round()),
                ),
              ),
              Text('$_goal d/wk'),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Only my build')),
              Switch(
                value: _myBuildOnly,
                onChanged: (v) => _resimulate(() {
                  _myBuildOnly = v;
                  _day = _day.clamp(0, CycleManager.cycleDays);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // The builds in a row at the current day
  Widget _avatars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final builds = _builds;
        final double avatarWidth = (constraints.maxWidth / builds.length) - 12;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final build in builds)
              Expanded(child: _column(build, avatarWidth)),
          ],
        );
      },
    );
  }

  Widget _column(BuildType build, double avatarWidth) {
    final DaySnapshot snap = _runs[build]![_day];
    final AvatarSprites s = snap.sprites;
    final String stage =
        s.transitioning ? 'body ${s.buildStage}%' : 'g${s.borderLevel}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AvatarDisplay(
          avatar: snap.avatar,
          width: avatarWidth,
          height: avatarWidth * 2,
        ),
        const SizedBox(height: 6),
        Text(
          build.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(stage, style: const TextStyle(fontSize: 12)),
        Text(
          s.isMaxed ? 'MAXED' : 'growing',
          style: TextStyle(
            fontSize: 12,
            color: s.isMaxed ? Colors.green.shade800 : AppColors.header,
          ),
        ),
      ],
    );
  }

  Widget _dayControls() {
    final BuildType first = _builds.first;
    final DaySnapshot ref = _runs[first]![_day];
    final int? maxedOn = GrowthSimulator.firstMaxedDay(_runs[first]!);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_timer == null ? Icons.play_arrow : Icons.pause),
                onPressed: _togglePlay,
              ),
              Expanded(
                child: Slider(
                  value: _day.toDouble(),
                  min: 0,
                  max: CycleManager.cycleDays.toDouble(),
                  divisions: CycleManager.cycleDays,
                  label: 'day $_day',
                  onChanged: (v) {
                    _timer?.cancel();
                    setState(() {
                      _timer = null;
                      _day = v.round();
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            'Day $_day / ${CycleManager.cycleDays}   |   '
            '${ref.sessionsDone} workouts   |   '
            '${ref.canAscend ? "can ascend" : "cannot ascend yet"}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            maxedOn == null
                ? 'Never maxes within the cycle (ascends on day 91)'
                : 'All muscles maxed on day $maxedOn',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}