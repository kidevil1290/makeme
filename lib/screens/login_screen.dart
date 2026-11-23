import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../theme/theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Optional photo background. Drop an image at this path and declare it under
  // flutter: assets: in pubspec.yaml and it is drawn behind everything.
  // If the file is missing the gradient is shown instead, so nothing crashes.
  static const String backgroundImage = 'assets/images/login_bg.webp';

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ScreenManager>();

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
              child: Column(
                children: [
                  // Sign up button (top)
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () =>
                          manager.setScreen(Screens.notImplemented),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.buttonBlue,
                        backgroundColor: AppColors.white,
                        side: const BorderSide(
                          color: AppColors.buttonBlue,
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Title + illustration
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'MakeMe',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.header,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const SizedBox(height: 24),
                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 320 / 240,
                            child: CustomPaint(
                              painter: _StretchIllustrationPainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () =>
                          manager.setScreen(Screens.avatarSelection),
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
        ],
      ),
    );
  }
}

// Gradient + soft circles, with an optional photo on top of the gradient
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF4F7FD),
                AppColors.background,
                Color(0xFFB4C7F0),
              ],
            ),
          ),
        ),
        CustomPaint(painter: _BubblesPainter()),
        Image.asset(
          LoginScreen.backgroundImage,
          fit: BoxFit.cover,
          // no image file yet: just show the gradient
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final soft = Paint()..color = AppColors.white.withValues(alpha: 0.45);
    final tint = Paint()..color = AppColors.blue.withValues(alpha: 0.12);

    canvas.drawCircle(Offset(w * 0.9, h * 0.12), w * 0.38, soft);
    canvas.drawCircle(Offset(w * 0.05, h * 0.42), w * 0.30, tint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.78), w * 0.42, tint);
    canvas.drawCircle(Offset(w * 0.1, h * 0.92), w * 0.25, soft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// A simple dumbbell on a soft circle
class _StretchIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    canvas.drawCircle(
      center,
      h * 0.46,
      Paint()..color = AppColors.white.withValues(alpha: 0.65),
    );

    final navy = Paint()..color = AppColors.header;
    final blue = Paint()..color = AppColors.blue;

    // bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w * 0.62, height: h * 0.05),
        Radius.circular(h * 0.025),
      ),
      navy,
    );

    // plates: big blue one, smaller navy one outside it, on both sides
    for (final side in const [-1.0, 1.0]) {
      _plate(canvas, Offset(center.dx + side * w * 0.17, center.dy),
          w * 0.07, h * 0.36, blue);
      _plate(canvas, Offset(center.dx + side * w * 0.26, center.dy),
          w * 0.06, h * 0.25, navy);
    }
  }

  void _plate(Canvas canvas, Offset c, double pw, double ph, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: pw, height: ph),
        Radius.circular(pw * 0.4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
