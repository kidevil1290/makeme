
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/enums.dart';
import '../services/screen_manager.dart';


class WorkoutTemplate extends  StatelessWidget{
  const WorkoutTemplate({super.key});

  @override
  Widget build(BuildContext context){
    final manager = context.read<ScreenManager>();

      return Scaffold(
        appBar: AppBar(
        title: const Text('Workout template'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => manager.setScreen(Screens.workoutlog),
        ),
      ),
      );

  }

}