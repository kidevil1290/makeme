import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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
  forceAscend,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  // Stops the ascension dialog from being scheduled twice before it opens
  bool _ascendPromptScheduled = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile>();
    // First time this avatar can ascend: explain it with a dialog
    if (profile.shouldShowAscendPrompt) _scheduleAscendPrompt();

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
            // Only for a maxed avatar that still has a badge to earn
            if (profile.readyToAscend) ...[
              _buildAscendButton(),
              const SizedBox(height: 12),
            ],
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
  // so it opens right after this frame is drawn.
  // It is marked as shown first, so it never appears twice for the same avatar
  void _scheduleAscendPrompt() {
    if (_ascendPromptScheduled) return;
    _ascendPromptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ascendPromptScheduled = false;
      if (!mounted) return;
      final profile = context.read<UserProfile>();
      if (!profile.shouldShowAscendPrompt) return;
      // A maxed avatar gets the growth message, otherwise the 91 days are up
      final String reason = profile.isMaxed
          ? 'You have reached maximum muscle growth!'
          : 'You have completed your ${CycleManager.cycleDays} day cycle!';
      profile.markAscendPromptShown();
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Congratulations!'),
          content: Text(
            '$reason If you choose to ascend, '
            'you will create a new Avatar to replace your current Avatar. '
            'Your new Avatar will be granted the next ascension level. '
            'Each ascension level is indicated by a badge that will appear '
            'next to your Avatar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  // Asks before ascending, because the avatar moves to history and cannot come back.
  // Only ascends when the user taps Ascend in the dialog
  Future<void> _confirmAscend() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Your avatar will move to history and you will create a new one. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ascend'),
          ),
        ],
      ),
    );
    // Closing the dialog by tapping outside it gives null, treated as cancel
    if (confirmed != true || !mounted) return;
    context.read<UserProfile>().ascend();
    context.read<ScreenManager>().setScreen(Screens.avatarCreation);
  }

  // Archives the maxed avatar, raises the ascension level and
  // sends the user to create the next avatar (after the confirm dialog)
  Widget _buildAscendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: _confirmAscend,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.header,
          ),
          icon: const Icon(Icons.keyboard_double_arrow_up),
          label: const Text(
            'Ascend!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          iconAlignment: IconAlignment.end,
        ),
      ),
    );
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
          // Same as Ascend! but skips the maxed check, for testing badges
          case _ProfileAction.forceAscend:
            context.read<UserProfile>().ascend();
            manager.setScreen(Screens.avatarCreation);
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
          if (kDebugMode)
            const PopupMenuItem(
              value: _ProfileAction.forceAscend,
              child: Text('Force Ascend'),
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
