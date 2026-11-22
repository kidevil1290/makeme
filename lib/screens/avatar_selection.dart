import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../models/avatar.dart';
import '../services/screen_manager.dart';
import '../theme/theme.dart';
import '../utils/enums.dart';
import '../widgets/avatar_display.dart';
import '../models/avatar_record.dart';

// Avatar Selection screen
// Only one avatar can exist per cycle
// Shows the finished avatars, one card for each cycle
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
    final List<AvatarRecord> history = context.watch<UserProfile>().history;

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
  Widget _buildAvatarCard(BuildContext context, AvatarRecord record) {
    final Avatar avatar = record.avatar;

    return GestureDetector(
      onTap: () => _showRecord(context, record),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            // FittedBox scales the avatar to the room left above the name
            Expanded(
              child: FittedBox(
                child: AvatarDisplay(avatar: avatar, width: 120, height: 120),
              ),
            ),
            Text(
              avatar.avatarName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.header,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The full version of the card, shown as a pop-up when a record is tapped
  void _showRecord(BuildContext context, AvatarRecord record) {
    final Avatar avatar = record.avatar;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        // content can scroll if the screen is too short
        scrollable: true,
        title: Text(
          avatar.avatarName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        // double.maxFinite lets the content use the full dialog width
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // the sprites are about 1:2 (width:height), same as the home screen
              AvatarDisplay(avatar: avatar, width: 160, height: 320),
              const SizedBox(height: 20),
              Text(
                '${record.weeksMet} / ${record.totalWeeks} weeks',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              // toIso8601String gives "2026-11-22T17:30:00.000", the first
              // 10 characters are the date: "2026-11-22"
              Text(
                '${record.startedAt.toIso8601String().substring(0, 10)}'
                ' to ${record.endedAt.toIso8601String().substring(0, 10)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
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
