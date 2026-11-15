import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/enums.dart';
import '../services/screen_manager.dart';

//display labels with enum
String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
extension BodyPartNameLabel on BodyPartName {
  String get label => _capitalize(name);
}
extension IntensityLabel on Intensity {
  String get label => _capitalize(name);
}

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}
final List<int> kDurationOptions = [5, for (var m = 10; m <= 120; m += 10) m];


class WorkoutLog extends StatefulWidget {
  const WorkoutLog({super.key});
 
  @override
  State<WorkoutLog> createState() => _WorkoutLogState();
}
 
class _WorkoutLogState extends State<WorkoutLog> {
  int? _durationMinutes;
  final _durationController = TextEditingController();
  final Set<BodyPartName> _selectedBodyParts = {};
  Intensity? _intensity;
 
  @override
  void initState() {
    super.initState();
    // Rebuild so the Save button enables/disables as the user types.
    _durationController.addListener(() => setState(() {}));
  }
 
  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
 
  bool get _canSave =>
      (_durationMinutes ?? 0) > 0 &&
      _selectedBodyParts.isNotEmpty &&
      _intensity != null;
 
  void _save() {
    // TODO: persist the log entry (database / API).
    final entry = (
      durationMinutes: _durationMinutes!,
      bodyParts: _selectedBodyParts.toList(),
      intensity: _intensity!,
    );
    debugPrint('Workout saved: $entry');
 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout logged')),
    );
 
    setState(() {
      _durationController.clear();
      _selectedBodyParts.clear();
      _intensity = null;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
    final textTheme = Theme.of(context).textTheme;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 1. Duration (5 min to 2 hours)
              Text('Duration', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _durationMinutes,
                isExpanded: true,
                menuMaxHeight: 320,
                hint: const Text('Select duration'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                items: [
                  for (final minutes in kDurationOptions)
                    DropdownMenuItem(
                      value: minutes,
                      child: Text(formatDuration(minutes)),
                    ),
                ],
                onChanged: (value) => setState(() => _durationMinutes = value),
              ),
              const SizedBox(height: 24),
  
              // 2. Body parts (1 or multiple)
              Text('Body parts', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Select one or more', style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final part in BodyPartName.values)
                    FilterChip(
                      label: Text(part.label),
                      selected: _selectedBodyParts.contains(part),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBodyParts.add(part);
                          } else {
                            _selectedBodyParts.remove(part);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
  
              // 3. Intensity
              Text('Intensity', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Intensity>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [
                    for (final level in Intensity.values)
                      ButtonSegment(value: level, label: Text(level.label)),
                  ],
                  selected: _intensity == null ? <Intensity>{} : {_intensity!},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _intensity = selection.isEmpty ? null : selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
  
              // Save
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  child: const Text(
                    'Save Workout',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
  
              // 4. Workout template
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => manager.setScreen(Screens.template),
                  label: const Text(
                    'Workout Template',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              ],
            ),
        ),
      ),
    );
  }
}
 