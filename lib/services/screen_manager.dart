import 'package:flutter/foundation.dart';

import '../utils/enums.dart';

class ScreenManager extends ChangeNotifier {
  Screens _currentScreen = Screens.login;
  final List<Screens> _screenHistory = [];

  Screens get currentScreen => _currentScreen;
  bool get canGoBack => _screenHistory.isNotEmpty;

  void setScreen(Screens screen) {
    if (screen == _currentScreen) return;
    _currentScreen = screen;
    notifyListeners();
  }

  void goBack() {
    if(_screenHistory.isEmpty) return;
    _currentScreen = _screenHistory.removeLast();
    notifyListeners();
  }
}
