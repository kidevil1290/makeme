import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models/user_profile.dart';
import 'screens/avatar_creation.dart';
import 'screens/habit_logger.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_implemented.dart';
import 'screens/avatar_selection.dart';
import 'screens/templates_screen.dart';
import 'screens/workoutlog_screen.dart';
import 'screens/status_screen.dart';
import 'screens/growth_debug_screen.dart';
import 'services/screen_manager.dart';
import 'utils/enums.dart';
import 'theme/theme.dart';
import 'models/user_data.dart';
import 'services/storage_service.dart';

class MakeMeApp extends StatelessWidget {
  final StorageService storage;
  final UserData data;
  const MakeMeApp({super.key, required this.storage, required this.data});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Shared objects any screen can reach with context.read / context.watch
      providers: [
        ChangeNotifierProvider(create: (_) => ScreenManager()),
        // loaded at startup, only used to build the UserProfile
        ChangeNotifierProvider(
          create: (_) => UserProfile(storage: storage, data: data),
        ),
      ],
      child: MaterialApp(
        title: 'MakeMe',
        debugShowCheckedModeBanner: false,
        // Colors and widget design comes from theme.dart
        theme: AppTheme.light,
        scrollBehavior: const NoOverscroll(),
        builder: (context, child) {
          if (!kIsWeb) return child!;
          return ColoredBox(
            color: AppColors.header,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                // 390 x 844 screen plus 10 of bezel on every side
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                    child: Container(
                      width: 410,
                      height: 864,
                      padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 24),
                      ],
                    ),
                    // black bezel
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Stack(
                        children: [
                          // the whole app, drawn inside the screen
                          Positioned.fill(child: child!),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 110,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        // Rebuilds whenever ScreenManager changes screen
        home: Consumer<ScreenManager>(
          builder: (context, manager, _) {
            // Stops the system back gesture from closing the app and sends it to screenManager.goBack()
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) manager.goBack();
              },
              // Animation that fades between screens
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(manager.currentScreen),
                  // One case per Screens value.
                  // All screen enum value needs a case
                  child: switch (manager.currentScreen) {
                    Screens.login => const LoginScreen(),
                    Screens.home => const HomeScreen(),
                    Screens.habitLogger => const HabitLogger(),
                    Screens.avatarCreation => const AvatarCreation(),
                    Screens.notImplemented => const NotImplemented(),
                    Screens.workoutlog => const WorkoutLog(),
                    Screens.template => const WorkoutTemplateScreen(),
                    Screens.avatarSelection => const AvatarSelection(),
                    Screens.status => const StatusScreen(),
                    Screens.growthDebug => const GrowthDebugScreen(),
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
