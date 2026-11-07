import 'package:flutter/material.dart';

import 'avatar.dart';
import '../utils/enums.dart';
import '../models/head_config.dart';

class UserProfile extends ChangeNotifier {
  Avatar? _avatar;

  Avatar? get avatar => _avatar;

  bool get hasAvatar => _avatar != null;

  void createAvatar({
    required Gender gender,
    required BuildType build,
    required HeadConfig head,
    required double skinTone,
  }) {
    if (_avatar != null) return;
    _avatar = Avatar(
      gender: gender,
      build: build,
      head: head,
      skinTone: skinTone,
    );
    notifyListeners();
  }

  void addGrowth(BodyPartName part, double amount) {
    final current = _avatar;
    if (current == null) return;

    _avatar = current.addGrowth(part, amount);
    notifyListeners();
  }
}
