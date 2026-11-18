import 'package:flutter/material.dart';

import '../models/avatar.dart';
import '../utils/asset_paths.dart';
import '../utils/enums.dart';

// Draws an Avatar by stacking same-size transparent sprite layers.
// The sprites are grayscale and get tinted here:
// skin layers with avatar.skinColor, hair with avatar.hairColor.
// The eyeballs are their own untinted layer under the head, so the whites of the eyes stay white.
// While a skinny/heavy build is still transitioning, the whole body comes from the build layers.
// After that, each muscle region uses the sprite for (shared level g, its own whole level s),
// so all region borders sit at level g.
// Muscles and builds change sprite in steps when a threshold is reached, rather than fading between sprites.
//
// Back to front: body, eyeballs, head (with holes for the face), the nose,
// mouth and eye-shape presets from HeadConfig, then hair with eyebrows.
class AvatarDisplay extends StatelessWidget {
  final Avatar avatar;
  final double width;
  final double height;

  const AvatarDisplay({
    super.key,
    required this.avatar,
    this.width = 200,
    this.height = 400,
  });

  // One full size layer, tinted with a color (null = not tinted).
  // A missing file draws nothing instead of crashing
  Widget _layer(String path, Color? tint) {
    final Widget image = Image.asset(
      path,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint == null ? null : BlendMode.modulate,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
    return Positioned.fill(child: image);
  }

  // Muscle layers at shared level g.
  // Each region shows the sprite for the last whole level it has reached:
  // A region at 1.9 still shows level 1 and jumps to level 2 at 2.0.
  // Sprites only exist for levels at or above g, so s never goes below it.
  List<Widget> _muscles(int g) {
    return [
      for (final region in AssetPaths.bodyOrder)
        _layer(
          AssetPaths.bodyLayer(
            avatar.gender,
            region,
            g,
            avatar.regionStep(region).clamp(g, Avatar.maxLevel).toInt(),
          ),
          avatar.skinColor,
        ),
    ];
  }

  // Body for a skinny/heavy build that has not reached average yet:
  // Like the muscles, it changes sprite in steps:
  // Avatar.buildStep is -1.0 (full build, 100 %) until the mean muscle level reaches -0.5,
  // then -0.5 (halfway build, 50 %) until it reaches 0.0, when the build is complete,
  // every muscle resets to 0.0 and the muscle layers take over.
  Widget _buildBody() {
    final int stage = (avatar.buildStep * -100).round(); // 100 or 50
    return _layer(
      AssetPaths.buildLayer(avatar.gender, avatar.build, stage),
      avatar.skinColor,
    );
  }

  // The "..." unpacks each list of layers into this stack depending on build.
  @override
  Widget build(BuildContext context) {
    final bool transitioning = !avatar.isBuildComplete;
    final int g = transitioning ? 0 : avatar.sharedLevel;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (transitioning) _buildBody() else ..._muscles(g),
          _layer(AssetPaths.eyes(avatar.gender), null),
          _layer(AssetPaths.head(avatar.gender, g), avatar.skinColor),
          for (final part in [HeadPart.nose, HeadPart.mouth, HeadPart.eyes])
            _layer(
              AssetPaths.facePart(
                avatar.gender,
                part,
                avatar.head.optionFor(part),
              ),
              avatar.skinColor,
            ),
          _layer(
            AssetPaths.hair(
              avatar.gender,
              avatar.head.optionFor(HeadPart.hair),
              g,
            ),
            avatar.hairColor,
          ),
        ],
      ),
    );
  }
}
