import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../screens/workoutlog_screen.dart'; // formatDuration, BodyPartNameLabel
import '../screens/workout_service.dart';
import '../screens/workout_model.dart';


/// Max growth a single body part can reach (used for the overall % only).
const double kMaxGrowthPerPart = 2.0;

/// How many of the 5 intensity bars are filled.
extension _IntensityBarCount on Intensity {
        int get bars => switch (this) {
        Intensity.light => 1,
        Intensity.medium => 3,
        Intensity.heavy => 5,
      };
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Nov 13, 2026 (Fri)"
String _dateLabel(DateTime d) =>
    '${_months[d.month - 1]} ${d.day}, ${d.year} (${_weekdays[d.weekday - 1]})';

/// "09:05"
String _timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Status screen: summary at the top, workout history below. Scrollable.
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
    final service = context.watch<WorkoutService>();
    final history = service.history;

    // Overall growth as % of the maximum across all body parts.
    final cappedTotal = service.growthByPart.values.fold(
      0.0,
      (sum, v) => sum + (v > kMaxGrowthPerPart ? kMaxGrowthPerPart : v),
    );
    final percent =
        cappedTotal / (BodyPartName.values.length * kMaxGrowthPerPart) * 100;

    // Row 0 = summary, row 1 = header, then one row per workout
    // (or a single "empty" row).
    final itemCount = history.isEmpty ? 3 : history.length + 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.home),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SummaryCard(
                totalTime: formatDuration(service.totalMinutes),
                totalGrowth: '+${percent.toStringAsFixed(0)}%',
              );
            }
            if (index == 1) return const _HistoryHeader();
            if (history.isEmpty) return const _EmptyHistory();
            return _EntryCard(entry: history[index - 2]);
          },
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- summary

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalTime, required this.totalGrowth});

  final String totalTime;
  final String totalGrowth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.schedule,
                  label: 'Total Workout Time',
                  value: totalTime,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.trending_up,
                  label: 'Total Growth',
                  value: totalGrowth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 6),
                Text(label, style: textTheme.titleSmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Log History',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('Your past workout logs', style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No workouts logged yet')),
      ),
    );
  }
}

// ----------------------------------------------------------- entry card

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final WorkoutLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 22, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateLabel(entry.timestamp),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const Divider(height: 24),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        icon: Icons.schedule,
                        label: 'Workout Duration',
                        child: Text(
                          formatDuration(entry.durationMinutes),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _Metric(
                        icon: Icons.layers_outlined,
                        label: 'Body Parts',
                        child: _BodyPartChips(parts: entry.bodyParts),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _Metric(
                        icon: Icons.bar_chart,
                        label: 'Intensity',
                        child: _IntensityBars(filled: entry.intensity.bars),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// First body part as a chip, plus "+N" when more were trained.
class _BodyPartChips extends StatelessWidget {
  const _BodyPartChips({required this.parts});

  final List<BodyPartName> parts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final extra = parts.length - 1;

    Widget chip(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        chip(parts.first.label),
        if (extra > 0) chip('+$extra'),
      ],
    );
  }
}

/// 5 rising bars; [filled] of them are highlighted.
class _IntensityBars extends StatelessWidget {
  const _IntensityBars({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 5; i++)
          Container(
            width: 9,
            height: 12.0 + i * 4,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: i < filled ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

// -------------------------------------------------------- detail sheet

void _showDetails(BuildContext context, WorkoutLogEntry entry) {
  final textTheme = Theme.of(context).textTheme;

  Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateLabel(entry.timestamp),
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(_timeLabel(entry.timestamp), style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            row('Duration', formatDuration(entry.durationMinutes)),
            row('Intensity', entry.intensity.label),
            row('Total growth', '+${entry.growthAmount.toStringAsFixed(2)}'),
            if (entry.templateUsed != null)
              row('Template', entry.templateUsed!),
            const Divider(height: 32),
            Text('Growth by body part', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final e in entry.growthByPart.entries)
              row(e.key.label, '+${e.value.toStringAsFixed(2)}'),
          ],
        ),
      ),
    ),
  );
}