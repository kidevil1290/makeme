import 'package:flutter/material.dart';

import '../utils/asset_paths.dart';

// Draws the badge for an ascension level: badge01 at level 1, badge02 at level 2, ...
// The badges are 48x48 pixel art, so they are drawn at a whole multiple
// of 48 (scale) with FilterQuality.none to keep every pixel the same size
class AscensionBadge extends StatelessWidget {
  // Size of the badge art in pixels, one scale step
  static const double artSize = 48;

  final int level;
  final int scale;

  const AscensionBadge({super.key, required this.level, this.scale = 2});

  // A missing file draws nothing instead of crashing
  @override
  Widget build(BuildContext context) {
    final double size = artSize * scale;
    return Image.asset(
      AssetPaths.badge(level),
      width: size,
      height: size,
      // Without a fit, Image only shrinks pictures and never enlarges them,
      // so the 48 px art would stay 48 px inside a bigger box
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => SizedBox.square(dimension: size),
    );
  }
}
