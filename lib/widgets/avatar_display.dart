import 'package:flutter/material.dart';

import '../utils/enums.dart';
import '../models/avatar.dart';
import '../utils/asset_paths.dart';

// Draws an Avatar by stacking same-size transparent PNG layers
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

  // One full size layer. A missing file draws nothing instead of crashing
  Widget _layer(String path, [double opacity = 1.0, Color? tint]) {
    Widget image = Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
    if (tint != null) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.modulate),
        child: image,
      );
    }
    return Positioned.fill(
      child: Opacity(opacity: opacity, child: image),
    );
  }

  // Layers for one muscle.
  // Uses opacity layering for stages 0, 2 and 4
  // Tint colors it (used for skin)
  List<Widget> _muscle(BodyPartName part) {
    final double growth = avatar.growthOf(part);

    String path(int stage) =>
        AssetPaths.bodyPart(avatar.gender, avatar.build, part, stage);

    return [
      _layer(path(0), 1.0, avatar.skinColor),
      if (growth > 0)
        _layer(
          path(2),
          (growth / 2).clamp(0.0, 1.0).toDouble(),
          avatar.skinColor,
        ),
      if (growth > 2)
        _layer(
          path(4),
          ((growth - 2) / 2).clamp(0.0, 1.0).toDouble(),
          avatar.skinColor,
        ),
    ];
  }

  // The "..." unpacks each muscle's list of layers into this Stack
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final part in AssetPaths.bodyOrder) ..._muscle(part),
          _layer(
            AssetPaths.head(avatar.gender, avatar.build),
            1.0,
            avatar.skinColor,
          ),
          for (final part in HeadPart.values)
            _layer(
              AssetPaths.headPart(part, avatar.head.optionFor(part)),
              1.0,
              switch (part) {
                HeadPart.nose => avatar.skinColor,
                HeadPart.hair => avatar.hairColor,
                _ => null,
              },
            ),
        ],
      ),
    );
  }
}
