import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/transport.dart';
import 'transport_selection_item.dart';

class TransportSelectionSheet extends StatefulWidget {
  final TransportMode? initialSelection;
  final ValueChanged<TransportMode?> onApply;

  const TransportSelectionSheet({
    super.key,
    required this.initialSelection,
    required this.onApply,
  });

  static Future<TransportMode?> show(
    BuildContext context, {
    TransportMode? initialSelection,
  }) async {
    return showModalBottomSheet<TransportMode?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransportSelectionSheet(
        initialSelection: initialSelection,
        onApply: (mode) => Navigator.of(context).pop(mode),
      ),
    );
  }

  @override
  State<TransportSelectionSheet> createState() => _TransportSelectionSheetState();
}

class _TransportSelectionSheetState extends State<TransportSelectionSheet> {
  TransportMode? _selectedMode;

  // Purple color matching Transport icon on home screen
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color darkPurple = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialSelection;
  }

  void _selectMode(TransportMode mode) {
    setState(() {
      if (_selectedMode == mode) {
        _selectedMode = null;
      } else {
        _selectedMode = mode;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.transportTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.transportSubtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Transport Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: TransportMode.allModes.map((mode) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: mode != TransportMode.allModes.last ? 12 : 0,
                  ),
                  child: TransportSelectionItem(
                    mode: mode,
                    isSelected: _selectedMode == mode,
                    onTap: () => _selectMode(mode),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // Apply Button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [primaryPurple, darkPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedMode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.applyTransport,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
