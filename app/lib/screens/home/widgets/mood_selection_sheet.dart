import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/mood.dart';
import 'mood_selection_item.dart';

class MoodSelectionSheet extends StatefulWidget {
  final List<Mood> initialSelection;
  final ValueChanged<List<Mood>> onApply;

  const MoodSelectionSheet({
    super.key,
    required this.initialSelection,
    required this.onApply,
  });

  static Future<List<Mood>?> show(
    BuildContext context, {
    List<Mood> initialSelection = const [],
  }) async {
    return showModalBottomSheet<List<Mood>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodSelectionSheet(
        initialSelection: initialSelection,
        onApply: (moods) => Navigator.of(context).pop(moods),
      ),
    );
  }

  @override
  State<MoodSelectionSheet> createState() => _MoodSelectionSheetState();
}

class _MoodSelectionSheetState extends State<MoodSelectionSheet> {
  late Set<Mood> _selectedMoods;

  @override
  void initState() {
    super.initState();
    _selectedMoods = Set.from(widget.initialSelection);
  }

  void _toggleMood(Mood mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else {
        _selectedMoods.add(mood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Moods Horizontal List
          Expanded(
            child: _buildMoodsList(),
          ),

          // Bottom Section
          _buildBottomSection(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            AppLocalizations.of(context)!.moodTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.8,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            AppLocalizations.of(context)!.moodSubtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B).withValues(alpha: 0.9),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: Mood.allMoods.length,
      itemBuilder: (context, index) {
        final mood = Mood.allMoods[index];
        final isSelected = _selectedMoods.contains(mood);

        return Padding(
          padding: EdgeInsets.only(
            right: index < Mood.allMoods.length - 1 ? 16 : 0,
          ),
          child: MoodSelectionItem(
            mood: mood,
            isSelected: isSelected,
            onTap: () => _toggleMood(mood),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(double bottomPadding) {
    final selectedCount = _selectedMoods.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected count indicator
          if (selectedCount > 0) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFEDD5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF97316),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$selectedCount',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.moodSelectedCount(selectedCount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC2410C),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedMoods.toList());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: const Color(0xFFF97316).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                selectedCount > 0
                    ? AppLocalizations.of(context)!.applyMood
                    : AppLocalizations.of(context)!.skipForNow,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
