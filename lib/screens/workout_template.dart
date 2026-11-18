
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/enums.dart';
import '../services/screen_manager.dart';
import '../screens/workout_model.dart';
import '../screens/workout_service.dart';
import '../screens/workoutlog_screen.dart';

/// Workout Template screen.
///   - Save: stores the template (same name = overwrite/edit)
///   - Load: bottom sheet to load into the form, use in the log, or delete
class WorkoutTemplateScreen extends StatefulWidget {
  const WorkoutTemplateScreen({super.key});

  @override
  State<WorkoutTemplateScreen> createState() => _WorkoutTemplateScreenState();
}

class _WorkoutTemplateScreenState extends State<WorkoutTemplateScreen> {
  final _nameController = TextEditingController();
  final Set<BodyPartName> _selectedBodyParts = {};
  Intensity? _intensity;

  @override
  void initState() {
    super.initState();
    // Rebuild so Save enables/disables as the user types.
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _selectedBodyParts.isNotEmpty &&
      _intensity != null;

  WorkoutTemplate _currentTemplate() => WorkoutTemplate(
        name: _nameController.text.trim(),
        bodyParts: _selectedBodyParts.toList(),
        intensity: _intensity!,
      );

  Future<void> _save() async {
    final service = context.read<WorkoutService>();
    final overwritten = await service.saveTemplate(_currentTemplate());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(overwritten ? 'Template updated' : 'Template saved'),
      ),
    );
  }

  void _loadIntoForm(WorkoutTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _selectedBodyParts
        ..clear()
        ..addAll(template.bodyParts);
      _intensity = template.intensity;
    });
  }

  void _openLoadSheet() {
    final service = context.read<WorkoutService>();
    final manager = context.read<ScreenManager>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListenableBuilder(
          listenable: service,
          builder: (context, child) {
            final templates = service.templates;
            if (templates.isEmpty) {
              return const SizedBox(
                height: 160,
                child: Center(child: Text('No saved templates yet')),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final t = templates[index];
                  final parts = t.bodyParts.map((p) => p.label).join(', ');
                  return ListTile(
                    title: Text(t.name),
                    subtitle: Text('$parts · ${t.intensity.label}'),
                    onTap: () {
                      _loadIntoForm(t);
                      Navigator.pop(sheetContext);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Use in Workout Log',
                          icon: const Icon(Icons.play_arrow_rounded),
                          onPressed: () {
                            service.applyTemplate(t);
                            Navigator.pop(sheetContext);
                            manager.setScreen(Screens.workoutlog);
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => service.deleteTemplate(t.name),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Keyboard overlays instead of squeezing the non-scrolling Column.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Workout Template'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.workoutlog),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template name
              Text('Template name', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Push day',
                  prefixIcon: Icon(Icons.edit_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),

              // Body parts (1 or multiple)
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

              // Intensity
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

              const Spacer(),

              // Load / Save
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _openLoadSheet,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text(
                          'Load',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _canSave ? _save : null,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}