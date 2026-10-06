import 'package:doofy/screens/alternative_screen.dart';
import 'package:flutter/material.dart';
import 'package:doofy/components/app_colors.dart';
import 'package:doofy/services/allergen_detection_service.dart';

// ═══════════════════════════════════════════════════════════════
//  FILE 3: lib/screens/scan_result_screen.dart
// ═══════════════════════════════════════════════════════════════

class ScanResultScreen extends StatelessWidget {
  final ScanResultData result;

  const ScanResultScreen({super.key, required this.result});

  // ── colours based on result ─────────────────────────────────
  Color get _bannerColor {
    if (result.isSafe) return const Color(0xFF2E7D32);
    if (result.hasSevere) return const Color(0xFFA32D2D);
    return const Color(0xFF854F0B); // intolerant only
  }

  Color get _bannerBg {
    if (result.isSafe) return const Color(0xFFEAF3DE);
    if (result.hasSevere) return const Color(0xFFFCEBEB);
    return const Color(0xFFFAEEDA);
  }

  IconData get _bannerIcon {
    if (result.isSafe) return Icons.check_circle_rounded;
    if (result.hasSevere) return Icons.dangerous_rounded;
    return Icons.warning_rounded;
  }

  String get _bannerTitle {
    if (result.isSafe) return 'Safe for you';
    if (result.result.detectedAllergens.length > 1) {
      return 'Multiple allergens detected';
    }
    return 'Allergen detected';
  }

  String get _bannerSubtitle {
    if (result.isSafe) {
      return 'No allergens from your profile were found';
    }
    if (result.hasSevere) {
      return 'Do not consume this product';
    }
    return 'You may experience discomfort';
  }

  String get _scanMethodLabel {
    switch (result.scanMethod) {
      case 'camera':
        return 'Label scan';
      case 'barcode':
        return 'Barcode scan';
      case 'nigerian_foods':
        return 'Nigerian foods';
      default:
        return 'Manual input';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── header ───────────────────────────
            _ResultHeader(
              scanMethod: _scanMethodLabel,
              timestamp: result.timestamp,
            ),

            // ── scrollable content ───────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    // colour-coded banner
                    _BannerCard(
                      color: _bannerColor,
                      bg: _bannerBg,
                      icon: _bannerIcon,
                      title: _bannerTitle,
                      subtitle: _bannerSubtitle,
                    ),

                    const SizedBox(height: 16),

                    // detected allergens list
                    if (result.detectedAllergens.isNotEmpty)
                      _DetectedSection(detected: result.detectedAllergens),

                    // safe confirmation
                    if (result.isSafe) _SafeSection(),

                    const SizedBox(height: 16),

                    // scanned text preview
                    _IngredientPreview(
                      text: result.ingredientText,
                      detected: result.detectedAllergens,
                    ),

                    const SizedBox(height: 16),

                    // alternatives button
                    if (!result.isSafe) _AlternativesButton(result: result),

                    const SizedBox(height: 12),

                    // scan again button
                    _ScanAgainButton(),

                    const SizedBox(height: 16),

                    // disclaimer
                    if (result.isSafe) const _SafeDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────
class _ResultHeader extends StatelessWidget {
  final String scanMethod;
  final DateTime timestamp;

  const _ResultHeader({required this.scanMethod, required this.timestamp});

  String get _timeLabel {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        // color: Color(0xFF1A1A2E),
        color: AppColors.greenBtn,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$scanMethod · $_timeLabel',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),

          // share button
          GestureDetector(
            onTap: () {
              // TODO: share result
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BANNER CARD
// ─────────────────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final Color color;
  final Color bg;
  final IconData icon;
  final String title;
  final String subtitle;

  const _BannerCard({
    required this.color,
    required this.bg,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 44),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DETECTED ALLERGENS SECTION
// ─────────────────────────────────────────────────────────────
class _DetectedSection extends StatelessWidget {
  final List<DetectedAllergen> detected;

  const _DetectedSection({required this.detected});

  static const Map<String, String> _emojis = {
    'milk': '🥛',
    'eggs': '🥚',
    'peanuts': '🥜',
    'tree_nuts': '🌰',
    'wheat': '🌾',
    'soy': '🫘',
    'fish': '🐟',
    'shellfish': '🦐',
    'sesame': '🌱',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Allergens found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 12),

          ...detected.map((d) {
            final isSevere = d.severity == 'severe';
            final color = isSevere
                ? const Color(0xFFA32D2D)
                : const Color(0xFF854F0B);
            final bg = isSevere
                ? const Color(0xFFFCEBEB)
                : const Color(0xFFFAEEDA);
            final emoji = _emojis[d.allergenId] ?? '⚠️';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // emoji
                  Text(emoji, style: const TextStyle(fontSize: 22)),

                  const SizedBox(width: 10),

                  // allergen info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.allergenName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: color.withOpacity(0.8),
                            ),
                            children: [
                              const TextSpan(text: 'Found in: '),
                              TextSpan(
                                text: d.triggeredBy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // severity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSevere ? 'Severe' : 'Intolerant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SAFE SECTION
// ─────────────────────────────────────────────────────────────
class _SafeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All your allergens checked',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'None of the allergens in your '
            'profile were detected in this '
            'ingredient list.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF3B6D11),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  INGREDIENT TEXT PREVIEW
// ─────────────────────────────────────────────────────────────
class _IngredientPreview extends StatefulWidget {
  final String text;
  final List<DetectedAllergen> detected;

  const _IngredientPreview({required this.text, required this.detected});

  @override
  State<_IngredientPreview> createState() => _IngredientPreviewState();
}

class _IngredientPreviewState extends State<_IngredientPreview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Scanned text',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Show more',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF185FA5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ALTERNATIVES BUTTON
// ─────────────────────────────────────────────────────────────
class _AlternativesButton extends StatelessWidget {
  final ScanResultData result;

  const _AlternativesButton({required this.result});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) {
                return AlternativesScreen(result: result);
              },
            ),
          );
        },
        icon: const Icon(Icons.swap_horiz_rounded, size: 20),
        label: const Text(
          'View safe alternatives',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SCAN AGAIN BUTTON
// ─────────────────────────────────────────────────────────────
class _ScanAgainButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text(
          'Check another food',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenBtn,
          side: const BorderSide(color: AppColors.greenBtn, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SAFE DISCLAIMER
// ─────────────────────────────────────────────────────────────
class _SafeDisclaimer extends StatelessWidget {
  const _SafeDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEF9F27).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFF854F0B), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Always verify with the manufacturer '
              'for cross-contamination risks. '
              'This app is a screening tool only.',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF854F0B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EXTENSION for cleaner access
// ─────────────────────────────────────────────────────────────
extension on ScanResultData {
  ScanResultData get result => this;
}
