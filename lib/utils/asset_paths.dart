import 'enums.dart';

class AssetPaths {
  AssetPaths._();

  static const String _root = 'assets/sprites';

  static String headPart(HeadPart part, int option){
    return '$_root/${part.name}_$option.png';
  }
}