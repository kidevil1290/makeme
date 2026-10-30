import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';

class AvatarEditor extends StatelessWidget 
{
  const AvatarEditor({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Avatar Editor'),),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<ScreenManager>().setScreen(Screens.home),
            child: const Text('Back to Home'),
        )
      ),
    );
  }
}