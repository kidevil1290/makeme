import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';

class HabitLogger extends StatelessWidget 
{
  const HabitLogger({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Habit Logger'),),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<ScreenManager>().goBack(),
            child: const Text('Back'),
        ),
      )
    );
  }
}