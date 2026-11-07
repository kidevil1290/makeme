import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_profile.dart';
import 'screens/avatar_specs.dart';
import 'screens/habit_logger.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_implemented.dart';
import 'services/screen_manager.dart';
import 'utils/enums.dart';
import 'theme/theme.dart';

class MakeMeApp extends StatelessWidget {
  const MakeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScreenManager()),
        ChangeNotifierProvider(create: (_) => UserProfile()),
      ],
      child: MaterialApp(
        title: 'MakeMe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Consumer<ScreenManager>(
          builder: (context, manager, _) {
            return PopScope(
              canPop: !manager.canGoBack,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) manager.goBack();
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(manager.currentScreen),
                  child: switch (manager.currentScreen) {
                    Screens.login => const LoginScreen(),
                    Screens.home => const HomeScreen(),
                    Screens.habitLogger => const HabitLogger(),
                    Screens.avatarSpecs => const AvatarSpecs(),
                    Screens.notImplemented => const NotImplemented(),
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
