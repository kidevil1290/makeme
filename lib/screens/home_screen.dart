import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';

class HomeScreen extends StatelessWidget 
{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final manager = context.read<ScreenManager>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          title: const Text('Home Screen')),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [ElevatedButton(onPressed: () => manager.setScreen(Screens.habitlogger),
                child: const Text('Habit Logger'),), const SizedBox(height: 12),
                ElevatedButton(onPressed: () => manager.setScreen(Screens.notImplemented),
                child: const Text('Avatar Editor')
              )],
            ),
          ),
      );
  }
}