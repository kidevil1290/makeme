import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../theme/theme.dart';
import '../models/user_profile.dart';
import '../widgets/avatar_display.dart';

enum _ProfileAction { avatarSelection, growthDebug, logOut }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
            1 => Screens.workoutlog,
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
    final avatar = context.watch<UserProfile>().avatar;

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
        return Center(
          child: AvatarDisplay(avatar: avatar, width: width, height: height),
        );
      },
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
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ProfileAction.avatarSelection,
          child: Text('Avatar Selection'),
        ),
        PopupMenuItem(value: _ProfileAction.logOut, child: Text('Log Out')),
      ],
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
