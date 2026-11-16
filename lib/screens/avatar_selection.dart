import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../models/avatar.dart';
import '../services/screen_manager.dart';
import '../theme/theme.dart';
import '../utils/enums.dart';
import '../widgets/avatar_display.dart';

// Avatar Selection screen
// Only one avatar can exist per cycle
// Shows the previous avatars that completed a cycle
class AvatarSelection extends StatelessWidget {
  const AvatarSelection({super.key});

  static const int _minSlots = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Selection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.read<ScreenManager>().setScreen(Screens.login),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top half: create button
            Expanded(child: _buildCreateButton(context)),
            // Bottom half: avatar history
            Expanded(child: _buildHistory(context)),
          ],
        ),
      ),
    );
  }

  // Has two states: Create Avatar and Play with avatarName
  Widget _buildCreateButton(BuildContext context) {
    final avatar = context.watch<UserProfile>().avatar;
    final bool hasAvatar = context.watch<UserProfile>().hasAvatar;

    return Center(
      child: GestureDetector(
        onTap: () => context.read<ScreenManager>().setScreen(
          hasAvatar ? Screens.home : Screens.avatarCreation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasAvatar ? Icons.play_arrow : Icons.add,
                size: 64,
                color: AppColors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 24),
              child: Text(
                avatar?.avatarName ?? 'Create Avatar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.header,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final List<Avatar> history = context.watch<UserProfile>().history;

    final int slotCount = max(history.length, _minSlots);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsetsGeometry.fromLTRB(16, 8, 16, 8),
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.header,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: slotCount,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => i < history.length
                ? _buildAvatarCard(context, history[i])
                : _buildEmptySlot(),
          ),
        ),
      ],
    );
  }

  // White rounded box shared by filled and empty slots
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
      ],
    );
  }

  // A finished avatar from a past cycle
  Widget _buildAvatarCard(BuildContext context, Avatar avatar) {
    return GestureDetector(
      onTap: () =>
          context.read<ScreenManager>().goBack(),
      child: Container(
        width: 150,
        decoration: _cardDecoration(),
        child: Center(
          child: AvatarDisplay(avatar: avatar, width: 120, height: 120),
        ),
      ),
    );
  }

  // Unlocked Silhoutte with a question mark meaning nothing is here yet
  Widget _buildEmptySlot() {
    return Container(
      width: 150,
      decoration: _cardDecoration(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.person, size: 130, color: AppColors.blue),
          const Text(
            '?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.header,
            ),
          ),
        ],
      ),
    );
  }
}
