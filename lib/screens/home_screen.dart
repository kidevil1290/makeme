import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';
import 'package:makeme/theme/theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.header,
        foregroundColor: AppColors.white,
        title: const Text(
          'MakeMe',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 72,
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

  // The white bar with Home / Workouts / Stats
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
          if (index == 0) {
            context.read<ScreenManager>().setScreen(Screens.login);
          }
          final Screens target = switch (index){
            0 => Screens.login,
            1 => Screens.notImplemented,
            _ => Screens.notImplemented,
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
              Icon(icon, size: 30, color: selected ? AppColors.blue : AppColors.background),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.blue : AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Title, subtitle and the illustration
  Widget _buildHeroSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

//start button on the bottom
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => context.read<ScreenManager>().setScreen(Screens.notImplemented),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
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
}
