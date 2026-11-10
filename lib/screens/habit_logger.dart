import 'package:flutter/material.dart';
import 'package:makeme/utils/enums.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';

class HabitLogger extends StatelessWidget {
  const HabitLogger({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();

    return Scaffold(
     appBar: AppBar(
        title: const Text('Habit log', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _HabitButton(
                label: 'Workout Log',
                onPressed: () => manager.setScreen(Screens.workoutlog),
              ),
              const SizedBox(height: 16),
              _HabitButton(
                label: 'Meal Log',
                onPressed: () => manager.setScreen(Screens.notImplemented),
              ),
              const SizedBox(height: 16),
              _HabitButton(
                label: 'Hydration Log',                onPressed: () => manager.setScreen(Screens.notImplemented),
              ),
              const SizedBox(height: 16),
              _HabitButton(
                label: 'Sleep Log',
                onPressed: () => manager.setScreen(Screens.notImplemented),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitButton extends StatelessWidget {
  const _HabitButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}