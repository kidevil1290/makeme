import 'package:flutter/foundation.dart';

import '../utils/enums.dart';

// Decides which screen is showing.
// screens call setScreen() to navigate
// app.dart watches this class and swaps the screen
class ScreenManager extends ChangeNotifier {
  Screens _currentScreen = Screens.login;
  Screens? _previousScreen;

  Screens get currentScreen => _currentScreen;

  // Switches the screen and remembers the one we left
  void setScreen(Screens screen) {
    if (screen == _currentScreen) return;
    _previousScreen = currentScreen;
    _currentScreen = screen;
    notifyListeners();
  }

  // Goes back one previous screen, or to home if there is none.
  // Does nothing on home and log in screen to protect app closing on stray back gestures
  // Used for the android back button
  void goBack() {
    if (_currentScreen == Screens.home || _currentScreen == Screens.login) {
      return;
    }
    _currentScreen = _previousScreen ?? Screens.home;
    _previousScreen = null;
    notifyListeners();
  }
}
