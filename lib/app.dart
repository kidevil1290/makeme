import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/avatar_editor.dart';
import 'screens/habit_logger.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_implemented.dart';
import 'services/screen_manager.dart';
import 'utils/enums.dart';

class MakeMeApp extends StatelessWidget {
  const MakeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScreenManager(),
      child: MaterialApp(
        title: 'MakeMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
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
                    Screens.habitlogger => const HabitLogger(),
                    Screens.avatarEditor => const AvatarEditor(),
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
