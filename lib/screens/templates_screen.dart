import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../models/workout_template.dart';
import '../models/user_profile.dart';
import '../theme/theme.dart';

class WorkoutTemplateScreen extends StatefulWidget {
  const WorkoutTemplateScreen({super.key});

  @override
  State<WorkoutTemplateScreen> createState() => _WorkoutTemplateScreenState();
}

class _WorkoutTemplateScreenState extends State<WorkoutTemplateScreen> {
  final TextEditingController _nameController = TextEditingController();

  final Set<BodyPartName> _selectedBodyParts = {};

  Intensity? _intensity;
  bool _isSaving = false;

  // ==========================================
  // Initialization
  // ==========================================

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  // ==========================================
  // Validation
  // ==========================================

  bool get _canSave {
    return !_isSaving &&
        _nameController.text.trim().isNotEmpty &&
        _selectedBodyParts.isNotEmpty &&
        _intensity != null;
  }

  // ==========================================
  // Format Enum Label
  // ==========================================

  String _formatLabel(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1);
  }

  // ==========================================
  // Save Template
  // ==========================================

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final service = context.read<UserProfile>();

      final template = service.addTemplate(
        name: _nameController.text.trim(),
        bodyParts: _selectedBodyParts.toList(),
        intensity: _intensity!,
      );

      if (!mounted) return;

      service.setPendingTemplate(template);

      context.read<ScreenManager>().setScreen(Screens.workoutlog);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save template: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================
  // Load Template into Form
  // ==========================================

  void _loadIntoForm(WorkoutTemplate template) {
    setState(() {
      _nameController.text = template.name;

      _selectedBodyParts
        ..clear()
        ..addAll(template.bodyParts);

      _intensity = template.intensity;
    });
  }

  // ==========================================
  // Delete Template
  // ==========================================

  Future<void> _deleteTemplate(WorkoutTemplate template) async {
    final service = context.read<UserProfile>();

    try {
      service.deleteTemplate(template.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Template deleted')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete template: $error')),
      );
    }
  }

  // ==========================================
  // Apply Template to Workout Log
  // ==========================================

  void _applyTemplate(WorkoutTemplate template) {
    final service = context.read<UserProfile>();
    final manager = context.read<ScreenManager>();

    service.setPendingTemplate(template);
    manager.setScreen(Screens.workoutlog);
  }

  // ==========================================
  // Open Load Template Sheet
  // ==========================================

  void _openLoadSheet() {
    final service = context.read<UserProfile>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
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
                    final template = templates[index];

                    final parts = template.bodyParts
                        .map((part) => _formatLabel(part.name))
                        .join(', ');

                    final intensity = _formatLabel(template.intensity.name);

                    return ListTile(
                      title: Text(template.name),
                      subtitle: Text('$parts · $intensity'),

                      // Load selected template
                      onTap: () {
                        _loadIntoForm(template);
                        Navigator.pop(sheetContext);
                      },

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Use template
                          IconButton(
                            tooltip: 'Use in Workout Log',
                            icon: const Icon(Icons.play_arrow_rounded),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _applyTemplate(template);
                            },
                          ),

                          // Delete template
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              _deleteTemplate(template);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================
  // Build Screen
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: const Text('Workout Template'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            manager.setScreen(Screens.workoutlog);
          },
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================
              // Template Name
              // ==================================

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

              // ==================================
              // Body Parts
              // ==================================
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
                      label: Text(_formatLabel(part.name)),
                      selected: _selectedBodyParts.contains(part),
                      selectedColor: AppColors.buttonBlue,
                      checkmarkColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: _selectedBodyParts.contains(part)
                            ? AppColors.white
                            : null,
                        fontWeight: _selectedBodyParts.contains(part)
                            ? FontWeight.w600
                            : null,
                      ),
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

              // ==================================
              // Intensity
              // ==================================
              Text('Intensity', style: textTheme.titleMedium),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Intensity>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.buttonBlue,
                    selectedForegroundColor: AppColors.white,
                  ),
                  segments: [
                    for (final level in Intensity.values)
                      ButtonSegment<Intensity>(
                        value: level,
                        label: Text(_formatLabel(level.name)),
                      ),
                  ],
                  selected: _intensity == null ? <Intensity>{} : {_intensity!},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _intensity = selection.isEmpty ? null : selection.first;
                    });
                  },
                ),
              ),

              // ==================================
              // Push Buttons to Bottom
              // ==================================
              const Spacer(),

              // ==================================
              // Load / Save Buttons
              // ==================================
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
