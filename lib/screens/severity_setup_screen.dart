import 'package:doofy/components/setup_widgets.dart';
import 'package:doofy/dashboard.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/screens/allergy_setup.dart';
import 'package:doofy/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SeveritySetupScreen extends StatefulWidget {
  final List<String> selectedAllergens;
  const SeveritySetupScreen({super.key, required this.selectedAllergens});

  @override
  State<SeveritySetupScreen> createState() => _SeveritySetupScreenState();
}

class _SeveritySetupScreenState extends State<SeveritySetupScreen> {
  late Map<String, String> _severity;
  bool _isSaving = false;

  static const Map<String, String> _names = {
    'milk': 'Milk',
    'eggs': 'Eggs',
    'peanuts': 'Peanuts',
    'tree_nuts': 'Tree Nuts',
    'wheat': 'Wheat',
    'soy': 'Soy',
    'fish': 'Fish',
    'shellfish': 'Shellfish',
    'sesame': 'Sesame',
  };

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
  void initState() {
    super.initState();
    // Default every selected allergen to severe
    _severity = {for (final id in widget.selectedAllergens) id: 'severe'};
  }

  Future<void> _saveAndContinue() async {
    // Prevent double taps
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Step 1 — Save profile to Hive
      final box = Hive.box<AllergyProfile>('profile');
      await box.put(
        'currentUser',
        AllergyProfile(
          selectedAllergens: widget.selectedAllergens,
          severityMap: _severity,
          cloudBackupEnabled: false,
        ),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      // Show error if save failed
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // top bar
              TopBar(
                title: 'How serious is each one?',
                subtitle: 'This determines the alert colour shown to you',
                showBack: true,
              ),

              // progress indicator
              ProgressRow(step: 2, total: 2),

              // legend
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: const [
                    LegendPill(
                      label: 'Severe',
                      desc: 'Anaphylaxis risk — red alert',
                      color: Color(0xFFA32D2D),
                      bg: Color(0xFFFCEBEB),
                    ),
                    SizedBox(width: 8),
                    LegendPill(
                      label: 'Intolerant',
                      desc: 'Discomfort — orange alert',
                      color: Color(0xFF854F0B),
                      bg: Color(0xFFFAEEDA),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // severity list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: widget.selectedAllergens.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final id = widget.selectedAllergens[i];
                    return SeverityCard(
                      emoji: _emojis[id] ?? '⚠️',
                      name: _names[id] ?? id,
                      current: _severity[id] ?? 'severe',
                      onChanged: (v) => setState(() => _severity[id] = v),
                    );
                  },
                ),
              ),

              // bottom action
              BottomAction(
                label: _isSaving ? 'Saving...' : 'Save my profile',
                onPressed: _isSaving ? () {} : _saveAndContinue,
                note:
                    'You can update this anytime'
                    ' from your profile',
                noteIsSuccess: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
