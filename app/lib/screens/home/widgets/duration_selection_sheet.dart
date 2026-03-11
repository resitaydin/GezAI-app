import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/duration.dart';
import 'duration_selection_item.dart';

class DurationSelectionSheet extends StatefulWidget {
  final DurationPreference initialPreference;
  final ValueChanged<DurationPreference> onApply;

  const DurationSelectionSheet({
    super.key,
    required this.initialPreference,
    required this.onApply,
  });

  static Future<DurationPreference?> show(
    BuildContext context, {
    DurationPreference initialPreference = const DurationPreference(),
  }) async {
    return showModalBottomSheet<DurationPreference>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DurationSelectionSheet(
        initialPreference: initialPreference,
        onApply: (preference) => Navigator.of(context).pop(preference),
      ),
    );
  }

  @override
  State<DurationSelectionSheet> createState() => _DurationSelectionSheetState();
}

class _DurationSelectionSheetState extends State<DurationSelectionSheet> {
  TimePeriod? _selectedPeriod;
  late int _selectedHours;

  static const Color primaryGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPreference.selectedPeriod;
    _selectedHours = widget.initialPreference.maxHours.clamp(1, 12).toInt();
  }

  void _selectPeriod(TimePeriod period) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedPeriod == period) {
        _selectedPeriod = null;
      } else {
        _selectedPeriod = period;
        _selectedHours = period.defaultMaxHours.clamp(1, 12);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          const SizedBox(height: 20),

          // Title
          Text(
            AppLocalizations.of(context)!.durationTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          // Time Period Grid (2x2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DurationSelectionItem(
                        period: TimePeriod.morning,
                        isSelected: _selectedPeriod == TimePeriod.morning,
                        onTap: () => _selectPeriod(TimePeriod.morning),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DurationSelectionItem(
                        period: TimePeriod.afternoon,
                        isSelected: _selectedPeriod == TimePeriod.afternoon,
                        onTap: () => _selectPeriod(TimePeriod.afternoon),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DurationSelectionItem(
                        period: TimePeriod.evening,
                        isSelected: _selectedPeriod == TimePeriod.evening,
                        onTap: () => _selectPeriod(TimePeriod.evening),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DurationSelectionItem(
                        period: TimePeriod.anytime,
                        isSelected: _selectedPeriod == TimePeriod.anytime,
                        onTap: () => _selectPeriod(TimePeriod.anytime),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hour Display
          Text(
            '$_selectedHours',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
              height: 1,
            ),
          ),
          Text(
            _selectedHours == 1
                ? AppLocalizations.of(context)!.hourSingular
                : AppLocalizations.of(context)!.hourPlural,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),

          const SizedBox(height: 20),

          // Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: primaryGreen,
                inactiveTrackColor: primaryGreen.withValues(alpha: 0.15),
                thumbColor: Colors.white,
                overlayColor: primaryGreen.withValues(alpha: 0.1),
                trackHeight: 6,
                thumbShape: _MinimalThumbShape(),
              ),
              child: Slider(
                value: _selectedHours.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHours = value.round());
                },
              ),
            ),
          ),

          // Hour Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1${AppLocalizations.of(context)!.hourAbbr}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                Text('12${AppLocalizations.of(context)!.hourAbbr}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Apply Button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onApply(DurationPreference(
                    selectedPeriod: _selectedPeriod,
                    minHours: _selectedHours,
                    maxHours: _selectedHours,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.applyDuration,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _MinimalThumbShape extends RoundSliderThumbShape {
  _MinimalThumbShape() : super(enabledThumbRadius: 12);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      11,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White circle
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);

    // Green border
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
}
