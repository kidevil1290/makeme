import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/workout_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('STEP 1: Flutter initialized');

  try {
    debugPrint('STEP 2: Creating WorkoutService');

    final workoutService = await WorkoutService.create();

    debugPrint('STEP 3: WorkoutService created');

    runApp(
      ChangeNotifierProvider<WorkoutService>.value(
        value: workoutService,
        child: const MakeMeApp(),
      ),
    );

    debugPrint('STEP 4: runApp called');
  } catch (error, stackTrace) {
    debugPrint('STARTUP ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}