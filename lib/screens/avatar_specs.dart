import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/screen_manager.dart';

class AvatarSpecs extends StatelessWidget {
  const AvatarSpecs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Specification')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<ScreenManager>().goBack(),
          child: const Text('Back'),
        ),
      ),
    );
  }
}
