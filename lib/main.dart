import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/workout_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final workoutService = await WorkoutService.create();

  runApp(
    ChangeNotifierProvider<WorkoutService>.value(
      value: workoutService,
      child: const MakeMeApp(),
    ),
  );
}