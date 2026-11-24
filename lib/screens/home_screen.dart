import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/cycle_manager.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../theme/theme.dart';
import '../models/user_profile.dart';
import '../widgets/avatar_display.dart';
import '../widgets/ascension_badge.dart';

enum _ProfileAction {
  avatarSelection,
  growthDebug,
  logOut,
  avatarEndCycle,
  avatarToMax,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  // Stops the ascension dialog from opening twice while it is scheduled or open
  bool _ascendPromptOpen = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile>();
    // The cycle is over: the user must ascend before doing anything else.
    // Checked on every build, so it comes back after a restart
    if (profile.canAscend) _scheduleAscendPrompt();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MakeMe',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [_buildProfileMenu()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildHeroSection()),
            _buildStartButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // The white bar with Home / Loggers / Stats
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.home_outlined, 'Home'),
          _buildTab(1, Icons.edit_note, 'Loggers'),
          _buildTab(2, Icons.bar_chart, 'Stats'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final bool selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          final Screens target = switch (index) {
            0 => Screens.home,
            1 => Screens.notImplemented,
            _ => Screens.status,
          };
          context.read<ScreenManager>().setScreen(target);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: selected ? AppColors.blue : AppColors.header,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.blue : AppColors.header,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The avatar, drawn from the saved UserProfile.
  // context.watch rebuilds this screen whenever the avatar changes,
  // so a logged workout shows up here without any extra code.
  Widget _buildHeroSection() {
    final profile = context.watch<UserProfile>();
    final avatar = profile.avatar;
    final int level = profile.ascensionLevel;

    // No avatar yet (first launch, before creation): show a short message
    // instead of crashing, because avatar is nullable.
    if (avatar == null) {
      return const Center(child: Text('Create an avatar to get started'));
    }

    // LayoutBuilder gives the space left over by the tab bar and the button.
    // The sprites are about 1:2 (width:height), so the height decides the size:
    // height = constraints.maxHeight, width = half of it.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.maxHeight - 16;
        final double width = height / 2;
        return Stack(
          children: [
            Center(
              child: AvatarDisplay(avatar: avatar, width: width, height: height),
            ),
            // Ascension badge on the right, from level 1 up.
            // Its top lines up with the top of the avatar, which is centered,
            // so the avatar's top edge is half of the leftover height
            if (level >= 1)
              Positioned(
                top: (constraints.maxHeight - height) / 2,
                right: 24,
                child: AscensionBadge(level: level),
              ),
          ],
        );
      },
    );
  }

  // A dialog cannot open while the screen is being built,
  // so it opens right after this frame is drawn
  void _scheduleAscendPrompt() {
    if (_ascendPromptOpen) return;
    _ascendPromptOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.read<UserProfile>().canAscend) {
        _ascendPromptOpen = false;
        return;
      }
      _showAscendPrompt();
    });
  }

  // The forced ascension: no Cancel button, tapping outside and the back
  // gesture do nothing, so Ascend! is the only way out
  Future<void> _showAscendPrompt() async {
    final profile = context.read<UserProfile>();
    // A maxed avatar gets the growth message, otherwise the 91 days are up
    final String reason = profile.isMaxed
        ? 'You have reached maximum muscle growth!'
        : 'You have completed your ${CycleManager.cycleDays} day cycle!';
    // At the last badge the level cannot rise, so the new avatar keeps it
    final String reward = profile.atMaxAscension
        ? 'You already hold the highest ascension level, so your new Avatar '
              'will keep your current badge.'
        : 'Your new Avatar will be granted the next ascension level. '
              'Each ascension level is indicated by a badge that will appear '
              'next to your Avatar.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          // Gold dialog for the ascension; surfaceTintColor off so
          // Material 3 does not tint the gold
          backgroundColor: AppColors.gold,
          surfaceTintColor: Colors.transparent,
          title: const Text('Congratulations!'),
          content: Text(
            '$reason Your Avatar will now ascend and move to your history, '
            'and you will create a new Avatar. $reward',
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext),
              // Navy with gold text, so the button stands out on the gold dialog
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.header,
                foregroundColor: AppColors.gold,
              ),
              icon: const Icon(Icons.keyboard_double_arrow_up),
              label: const Text(
                'Ascend!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
      ),
    );

    _ascendPromptOpen = false;
    if (!mounted) return;
    // The dialog only closes through Ascend!, so ascend now
    context.read<UserProfile>().ascend();
    context.read<ScreenManager>().setScreen(Screens.avatarCreation);
  }

  // Start button on the bottom
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () =>
              context.read<ScreenManager>().setScreen(Screens.workoutlog),
          icon: const Icon(Icons.play_arrow),
          label: const Text(
            'Start Workout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          iconAlignment: IconAlignment.end,
        ),
      ),
    );
  }

  // Person icon in a circle with a small drop arrow on its lower right
  Widget _buildProfileMenu() {
    return PopupMenuButton<_ProfileAction>(
      tooltip: 'Account',
      offset: const Offset(0, 56),
      onSelected: (action) {
        final manager = context.read<ScreenManager>();
        switch (action) {
          case _ProfileAction.avatarSelection:
            manager.setScreen(Screens.avatarSelection);
          case _ProfileAction.growthDebug:
            manager.setScreen(Screens.growthDebug);
          case _ProfileAction.logOut:
            manager.setScreen(Screens.login);
          // Demo: ascension by the 91 day cycle
          case _ProfileAction.avatarEndCycle:
            context.read<UserProfile>().forceEndCycle();
          // Demo: ascension by maximum muscle growth
          case _ProfileAction.avatarToMax:
            context.read<UserProfile>().forceMaxed();
        }
      },
      itemBuilder: (_) {
        return [
          const PopupMenuItem(
            value: _ProfileAction.avatarSelection,
            child: Text('Avatar Selection'),
          ),
          const PopupMenuItem(
            value: _ProfileAction.logOut,
            child: Text('Log Out'),
          ),
          const PopupMenuItem(
            value: _ProfileAction.growthDebug,
            child: Text('Growth Sim'),
          ),
          // Shown in every build, kept for demos and testing
          const PopupMenuItem(
            value: _ProfileAction.avatarEndCycle,
            child: Text('Force End Cycle'),
          ),
          const PopupMenuItem(
            value: _ProfileAction.avatarToMax,
            child: Text('Force Maxed Avatar'),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, size: 28, color: AppColors.header),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: .8),
                ),
                child: const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
