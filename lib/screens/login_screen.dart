import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';
import 'package:makeme/theme/theme.dart';

class LoginScreen extends StatelessWidget
{
  const LoginScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();
 
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
        child: Column(
          children: [
            // Sign up button (top)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => manager.setScreen(Screens.notImplemented),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.buttonBlue,
                  side: const BorderSide(color: AppColors.buttonBlue, width: 1.5),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Illustration
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 320 / 240,
                  child: CustomPaint(painter: _StretchIllustrationPainter()),
                ),
              ),
            ),
 
              // Start button
              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed: () => manager.setScreen(Screens.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.buttonBlue.withOpacity(0.4),
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

class _StretchIllustrationPainter extends CustomPainter
{
  @override
  void paint(Canvas canvas, Size size) {
    // drawing code
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 
