import 'package:flutter/foundation.dart';
import '../utils/enums.dart';

class ScreenManager extends ChangeNotifier
{
  Screens _currentScreen = Screens.login;

  Screens get currentScreen => _currentScreen;

  void setScreen(Screens screen)
  {
    if (screen == _currentScreen) return;
    _currentScreen = screen;
    notifyListeners();
  }
}