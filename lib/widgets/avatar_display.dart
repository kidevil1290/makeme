import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../models/avatar.dart';
import '../utils/asset_paths.dart';

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

  Widget _layer(String path, [double opacity = 1.0])
  {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        )
      )
      );
  }

  List<Widget> _muscle(BodyPartName part){
    final double growth = avatar.growthOf(part);

    String path(int stage) =>
      AssetPaths.bodyPart(avatar.gender, avatar.build, part, stage);

      return[
        _layer(path(0)),
        if(growth > 0 )
          _layer(path(2), (growth / 2).clamp(0.0, 1.0).toDouble()),
        if (growth > 2 )
          _layer(path(4), ((growth - 2) / 2).clamp(0.0, 1.0).toDouble()),
      ];
  }

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width: width,
    height: height,
    child:Stack(
      children: [
        for(final part in AssetPaths.bodyOrder)..._muscle(part),
        _layer(AssetPaths.head(avatar.gender, avatar.build)),
        for(final part in HeadPart.values)
        _layer(AssetPaths.headPart(part, avatar.head.optionFor(part))),
      ],
    )
  );
  }
}