import '../utils/enums.dart';
import 'head_config.dart';

class Avatar{
  final Gender gender;
  final BuildType build;
  final HeadConfig head;
  final double skinTone;

  final Map<BodyPartName, int> muscleStages;

  const Avatar({
    required this.gender,
    required this.build,
    required this.head,
    required this.skinTone,
    this.muscleStages = const{},
  });
}