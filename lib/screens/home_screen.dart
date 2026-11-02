import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget 
{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  static const Color _navy = Color(0xFF1F2F66);
  static const Color _blue = Color(0xFF3F63B8);
  static const Color _paleBlue = Color(0xFFDCE6F8);
 
  int _selectedTab = 0;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Home',
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
          _buildTab(1, Icons.fitness_center, 'Workouts'),
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
          // TODO: switch screens here, e.g.
          // context.read<ScreenManager>().setScreen(Screens.workouts);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _paleBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 30, color: selected ? _blue : _navy),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? _blue : _navy,
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
      children: [
        const Text(
          'Work Out',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Move, Train, and Stay Healthy!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 32),
        // Placeholder until you add a real image to assets/
        // Replace the Icon with: Image.asset('assets/workout.png', height: 240)
        Container(
          width: 220,
          height: 220,
          decoration: const BoxDecoration(
            color: _paleBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.self_improvement, size: 120, color: _blue),
        ),
      ],
    );
  }
 
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: go to the workout screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
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
 
