import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/enums.dart';
import '../services/screen_manager.dart';

/// Display labels for the enums ("biceps" -> "Biceps").
class WorkoutlogScreen extends StatelessWidget{
  const WorkoutlogScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final manager = context.read<ScreenManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.habitLogger),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            //Workout template
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => manager.setScreen(Screens.template),
                icon: const Icon(Icons.library_books_outlined),
                label: const Text(
                  'Workout Template',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
