import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class TermsOfServiceSheet extends StatefulWidget {
  const TermsOfServiceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsOfServiceSheet(),
    );
  }

  @override
  State<TermsOfServiceSheet> createState() => _TermsOfServiceSheetState();
}

class _TermsOfServiceSheetState extends State<TermsOfServiceSheet> {
  String _tosContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading so that context is available for locale lookup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTosContent();
    });
  }

  Future<void> _loadTosContent() async {
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final assetPath = locale == 'tr'
          ? 'assets/terms_of_service_tr.txt'
          : 'assets/terms_of_service.txt';
      final content = await rootBundle.loadString(assetPath);
      setState(() {
        _tosContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _tosContent = AppLocalizations.of(context)!.termsLoadFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF16509c),
                      strokeWidth: 2,
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 24),
                    child: Text(
                      _tosContent,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.termsOfServiceTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.8,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.termsReadCarefully,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Material(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF475569),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
