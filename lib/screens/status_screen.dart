import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../models/user_profile.dart';
import '../models/workout_log.dart';
import '../utils/enums.dart';


// -------------------------------------------------------------
// Date formatting
// -------------------------------------------------------------

const _weekdays = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

const _months = [
  'January', 'February', 'March', 'April',
  'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

String _dateLabel(DateTime date) {
  return '${_months[date.month - 1].substring(0, 3)} '
      '${date.day}, ${date.year} '
      '(${_weekdays[date.weekday - 1]})';
}

String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '${remainingMinutes}m';
  }

  if (remainingMinutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remainingMinutes}m';
}

// -------------------------------------------------------------
// Status Screen
// -------------------------------------------------------------

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() =>
      _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late DateTime _visibleMonth;

  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = null;
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();

    return _visibleMonth.year == now.year &&
        _visibleMonth.month == now.month;
  }

  // Change displayed month
  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );

      _selectedDay = null;
    });
  }

  // Select a day
  void _selectDay(DateTime date) {
    setState(() {
      _selectedDay = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();

    final history =
        context.watch<UserProfile>().workoutHistory;

    final textTheme = Theme.of(context).textTheme;

    // Group workouts by calendar date
    final byDay =
        <DateTime, List<WorkoutLogEntry>>{};

    for (final entry in history) {
      final date = entry.createdAt.toLocal();

      final dayKey = DateTime(
        date.year,
        date.month,
        date.day,
      );

      byDay.putIfAbsent(
        dayKey,
        () => [],
      ).add(entry);
    }

    // Get workouts for selected date
    final selectedEntries = _selectedDay == null
        ? <WorkoutLogEntry>[]
        : [...?byDay[_selectedDay]]
          ..sort(
            (a, b) =>
                a.createdAt.compareTo(b.createdAt),
          );

    // Calendar calculations
    final leadingBlanks =
        _visibleMonth.weekday - 1;

    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            manager.setScreen(Screens.home);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // -----------------------------------------
              // Header
              // -----------------------------------------

              Text(
                'Workout Log History',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------------------
              // Calendar
              // -----------------------------------------

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    children: [
                      // Month navigation
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                            ),
                            onPressed: () =>
                                _changeMonth(-1),
                          ),

                          Expanded(
                            child: Text(
                              '${_months[_visibleMonth.month - 1]} '
                              '${_visibleMonth.year}',
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                            ),
                            onPressed: _isCurrentMonth
                                ? null
                                : () => _changeMonth(1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Weekday labels
                      Row(
                        children: [
                          for (final day in _weekdays)
                            Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: textTheme.bodySmall
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Calendar grid
                      GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),

                        children: [
                          for (
                            var i = 0;
                            i < leadingBlanks;
                            i++
                          )
                            const SizedBox.shrink(),

                          for (
                            var day = 1;
                            day <= daysInMonth;
                            day++
                          )
                            _buildDayCell(
                              DateTime(
                                _visibleMonth.year,
                                _visibleMonth.month,
                                day,
                              ),
                              today,
                              byDay,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------
              // Selected Day Workout Logs
              // -----------------------------------------

              if (_selectedDay != null) ...[
                Text(
                  _dateLabel(_selectedDay!),
                  style: textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                if (selectedEntries.isEmpty)
                  const _EmptyDay()
                else
                  for (
                    var i = 0;
                    i < selectedEntries.length;
                    i++
                  )
                    _WorkoutCard(
                      entry: selectedEntries[i],
                      number:
                          selectedEntries.length > 1
                              ? i + 1
                              : null,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------
  // Calendar Day Cell
  // -------------------------------------------

  Widget _buildDayCell(
    DateTime date,
    DateTime today,
    Map<DateTime, List<WorkoutLogEntry>> byDay,
  ) {
    return _DayCell(
      day: date.day,
      isToday: date == today,
      isSelected: date == _selectedDay,
      hasLog: byDay.containsKey(date),
      onTap: () => _selectDay(date),
    );
  }
}

// -------------------------------------------------------------
// Day Cell Widget
// -------------------------------------------------------------

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasLog,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasLog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final BorderSide ring = isSelected
        ? BorderSide(
            color: colors.onSurface,
            width: 2,
          )
        : isToday
            ? BorderSide(
                color: colors.primary,
                width: 2,
              )
            : BorderSide.none;

    return Padding(
      padding: const EdgeInsets.all(3),

      child: Material(
        color: hasLog
            ? colors.primary
            : Colors.transparent,
        shape: CircleBorder(side: ring),

        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,

          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight:
                    hasLog || isToday || isSelected
                        ? FontWeight.w800
                        : FontWeight.normal,
                color: hasLog
                    ? colors.onPrimary
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Empty Day Widget
// -------------------------------------------------------------

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),

        child: Center(
          child: Text(
            'No workouts logged on this day',
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Workout Card
// -------------------------------------------------------------

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.entry,
    this.number,
  });

  final WorkoutLogEntry entry;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final valueStyle =
        textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Workout number
            if (number != null) ...[
              Text(
                'Workout $number',
                style: textTheme.titleSmall
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),
            ],

            // Duration and Intensity
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _InfoBlock(
                    label: 'Duration',
                    child: Text(
                      formatDuration(
                        entry.durationMinutes,
                      ),
                      style: valueStyle,
                    ),
                  ),
                ),

                Expanded(
                  child: _InfoBlock(
                    label: 'Intensity',
                    child: Text(
                      entry.intensity.name,
                      style: valueStyle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Body Parts
            _InfoBlock(
              label: 'Body Parts',

              child: Wrap(
                spacing: 6,
                runSpacing: 6,

                children: [
                  for (final part in entry.bodyParts)
                    Chip(
                      label: Text(part.name),
                      visualDensity:
                          VisualDensity.compact,
                    ),
                ],
              ),
            ),

            // Template information
            if (entry.templateUsed != null) ...[
              const SizedBox(height: 12),

              Text(
                'Template: ${entry.templateUsed}',
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Information Block
// -------------------------------------------------------------

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),

            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),

        const SizedBox(height: 6),

        child,
      ],
    );
  }
}