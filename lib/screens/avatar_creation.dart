import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/head_config.dart';
import '../widgets/avatar_display.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';
import '../models/avatar.dart';
import '../theme/theme.dart';
import '../models/user_profile.dart';

class AvatarCreation extends StatefulWidget {
  const AvatarCreation({super.key});

  @override
  State<AvatarCreation> createState() => _AvatarCreationState();
}

class _AvatarCreationState extends State<AvatarCreation> {
  Gender _gender = Gender.male;
  BuildType _buildType = BuildType.average;
  HeadConfig _head = const HeadConfig();
  double _skinTone = 0.5;
  double _hairTone = 1.0;
  String _avatarName = '';
  int _weeklyGoal = 3;
  // skinTones from light to dark
  static const List<Color> skinColor = [
    Color(0xFFFFE0BD),
    Color(0xFFE5B887),
    Color(0xFFC68642),
    Color(0xFF8D5524),
    Color(0xFF4A2C17),
  ];

  static const List<Color> hairColor = [
    Color(0xFFE53935), // red (primary)
    Color(0xFFF4511E), // red-orange (tertiary)
    Color(0xFFFFA000), // yellow-orange (tertiary)
    Color(0xFFFFEB3B), // yellow (primary)
    Color(0xFF9CCC22), // yellow-green (tertiary)
    Color(0xFF00A99D), // blue-green (tertiary)
    Color(0xFF1E5FD8), // blue (primary)
    Color(0xFF5B3FD6), // blue-violet (tertiary)
    Color(0xFFC71585), // red-violet (tertiary)
    Color(0xFFF1DDA0), // light blonde
    Color(0xFFD2A24C), // golden blonde
    Color(0xFF8B5A2B), // light brown
    Color(0xFF4A3322), // dark brown
    Color(0xFF2A2A2A), // black (not pure black, so shading still shows)
  ];

  static const double _previewWidth = 210;
  static const double _previewHeight = 420;
  static const double _titleWidth = 60;

  // "hair" becomes "Hair"
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  // builds the row with title: and a white box on the right
  Widget _rowSetting(String title, Widget dropdown) {
    return Row(
      children: [
        SizedBox(
          width: _titleWidth,
          child: Text(
            '$title:',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.header,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: dropdown,
          ),
        ),
      ],
    );
  }

  // Generic enum drop down
  Widget _enumDropdown<T extends Enum>(
    String title,
    T value,
    List<T> values,
    ValueChanged<T> onChanged,
  ) {
    return _rowSetting(
      title,
      DropdownButton<T>(
        isDense: true,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        value: value,
        items: [
          for (final T v in values)
            DropdownMenuItem(value: v, child: Text(_capitalize(v.name))),
        ],
        onChanged: (T? picked) {
          if (picked == null) return;
          onChanged(picked);
        },
      ),
    );
  }

  // Builds the dropdown for one part and loops through all the options
  Widget _headDropdown(HeadPart part) {
    return _rowSetting(
      _capitalize(part.name),
      DropdownButton<int>(
        isDense: true,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        value: _head.optionFor(part),
        items: [
          for (int i = 0; i < part.optionCount; i++)
            DropdownMenuItem(value: i, child: Text('Option ${i + 1}')),
        ],
        onChanged: (int? value) {
          if (value == null) return;
          setState(() => _head = _head.withOption(part, value));
        },
      ),
    );
  }

  // Temp widget for avatar preview,
  // white box as background preview
  // with a TEMP circle to test skinColor
  Widget _buildPreview(Avatar preview) {
    return Container(
      width: _previewWidth,
      height: _previewHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      // TEMP for testing skinColor slider
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: _colorAt(hairColor, _hairTone),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // Left column: preview, skinColor bar, name, goal
  Widget _buildPreviewColumn(Avatar preview) {
    return SizedBox(
      width: _previewWidth,
      child: Column(
        children: [
          _buildPreview(preview),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 4,
              children: [
                _colorSlider(
                  'Skin',
                  skinColor,
                  _skinTone,
                  (double v) => setState(() => _skinTone = v),
                ),
                _colorSlider(
                  'Hair',
                  hairColor,
                  _hairTone,
                  (double v) => setState(() => _hairTone = v),
                  divisions: hairColor.length - 1,
                ),
              ],
            ),
          ),
          _buildSurveyColumn(),
        ],
      ),
    );
  }

  // Initial survey column only Name and Goal for now
  Widget _buildSurveyColumn() {
    return Column(
      spacing: 20,
      children: [
        _rowSetting(
          'Name',
          TextField(
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'Enter Name',
            ),
            onChanged: (String n) => setState(() => _avatarName = n),
          ),
        ),
        _rowSetting(
          'Goal',
          DropdownButton<int>(
            isDense: true,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            value: _weeklyGoal,
            items: [
              for (int d = 1; d <= 7; d++)
                DropdownMenuItem(value: d, child: Text('$d days / week')),
            ],
            onChanged: (int? d) {
              if (d == null) return;
              setState(() => _weeklyGoal = d);
            },
          ),
        ),
      ],
    );
  }

  // Creates the avatar from the selected options,
  // then goes back to home screen
  void _save() {
    context.read<UserProfile>().createAvatar(
      avatarName: _avatarName.trim(),
      weeklyGoal: _weeklyGoal,
      gender: _gender,
      build: _buildType,
      head: _head,
      skinColor: _colorAt(skinColor, _skinTone),
      hairColor: _colorAt(hairColor, _hairTone),
    );
    context.read<ScreenManager>().setScreen(Screens.home);
  }

  // Column of all the dropdowns for the user to select through
  Widget _buildSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 40,
      children: [
        for (final HeadPart part in HeadPart.values) _headDropdown(part),
        _enumDropdown<BuildType>(
          'Build',
          _buildType,
          BuildType.values,
          (BuildType b) => setState(() => _buildType = b),
        ),
        _enumDropdown<Gender>(
          'Gender',
          _gender,
          Gender.values,
          (Gender g) => setState(() => _gender = g),
        ),
      ],
    );
  }

  // Returns the skin color at position t from 0.0 to 1.0
  // on the bar by blending the two nearest colors
  Color _colorAt(List<Color> colors, double t) {
    final double scaled = t * (colors.length - 1);
    final int i = scaled.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[i], colors[i + 1], scaled - i)!;
  }

  // Builds gradient bar with a transparent slider
  Widget _colorSlider(
    String label,
    List<Color> colors,
    double value,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: LinearGradient(colors: colors),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 14,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                    elevation: 2,
                  ),
                  trackShape: const RoundedRectSliderTrackShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: value,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.header,
          ),
        ),
      ],
    );
  }

  // Disabled until name is entered
  Widget _createButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: _avatarName.trim().isEmpty ? null : _save,
          icon: const Icon(Icons.play_arrow),
          label: const Text(
            'Create Avatar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          iconAlignment: IconAlignment.end,
        ),
      ),
    );
  }

  // Draws the screen, gets redrawn after every setState
  @override
  Widget build(BuildContext context) {
    // Draft of the avatar based on selected options
    // used for preview
    final Avatar preview = Avatar(
      avatarName: _avatarName,
      weeklyGoal: _weeklyGoal,
      gender: _gender,
      build: _buildType,
      head: _head,
      skinColor: _colorAt(skinColor, _skinTone),
      hairColor: _colorAt(hairColor, _hairTone),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Avatar Creation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          ElevatedButton(
            onPressed: () =>
                context.read<ScreenManager>().setScreen(Screens.home),
            child: const Text('cancel', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewColumn(preview),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSelectors()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _createButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
