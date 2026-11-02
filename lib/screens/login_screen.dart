import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';

class LoginScreen extends StatelessWidget
{
  const LoginScreen({super.key});

  static const _bg = Color(0xFFF4F7FD);
  static const _buttonBlue = Color(0xFF3F6FD8);
 
  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
 
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          child: Column(
            children: [
              // Illustration
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 320 / 240,
                  ),
                ),
              ),
 
              // Start button
              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed: () => manager.setScreen(Screens.habitlogger),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonBlue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: _buttonBlue.withOpacity(0.4),
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.play_arrow_rounded, size: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
