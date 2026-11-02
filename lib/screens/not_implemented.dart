import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/screen_manager.dart';
import '../utils/enums.dart';

class NotImplemented extends StatelessWidget {
  const NotImplemented({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<ScreenManager>().setScreen(Screens.home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Not Implemented Yet',
            style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
             Image.asset('assets/images/notImplemented.png', height: 400, ), 
          ],
        )      
        )
      );
  }
}
