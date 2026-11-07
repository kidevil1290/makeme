import 'package:flutter/foundation.dart';

import '../utils/enums.dart';

// Decides which screen is showing.
// screens call setScreen() to navigate
// app.dart watch this class and swaps the screen
class ScreenManager extends ChangeNotifier {
  Screens _currentScreen = Screens.login;
  // List of screens we came from, used for the back button to return to
  // might delete
  final List<Screens> _screenHistory = [];

  Screens get currentScreen => _currentScreen;
  bool get canGoBack => _screenHistory.isNotEmpty;

  // Switches the screen and remembers the one we left
  void setScreen(Screens screen) {
    if (screen == _currentScreen) return;
    _screenHistory.add(_currentScreen);
    _currentScreen = screen;
    notifyListeners();
  }

  // Returns to the previous screen or does nothing if there is none
  // Used for the android back button
  // might delete
  void goBack() {
    if (_screenHistory.isEmpty) return;
    _currentScreen = _screenHistory.removeLast();
    notifyListeners();
  }
}
