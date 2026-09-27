import 'package:doofy/components/setup_widgets.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/screens/home_screen.dart';
import 'package:doofy/screens/severity_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// ─────────────────────────────────────────────────────────────
//  allergy_setup_screen.dart
//  Screen shown after login/register
//  User selects their allergens then proceeds to
//  severity setup screen (SeveritySetupScreen below)
//
//  Both screens are in this file for easy copy-paste.
//  Split into separate files if preferred.
// ─────────────────────────────────────────────────────────────

class AppColors {
  static const Color bgTop = Color(0xFFE8F5E2);
  static const Color bgBottom = Color(0xFFF5FAF0);
  static const Color green = Color(0xFF2E7D32);
  static const Color greenLight = Color(0xFF4CAF50);
  static const Color greenBtn = Color(0xFF388E3C);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF666666);
  static const Color white = Colors.white;
  static const Color cardBg = Color(0xFFF9FFF6);
  static const Color phoneFrame = Color(0xFF1C1C1E);
  static const Color phoneScreen = Color(0xFFF8FBF6);
  static const Color iconRing = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────────────────────
//  SCREEN 1 — ALLERGEN SELECTION
// ─────────────────────────────────────────────────────────────
class AllergySetupScreen extends StatefulWidget {
  const AllergySetupScreen({super.key});

  @override
  State<AllergySetupScreen> createState() => _AllergySetupScreenState();
}

class _AllergySetupScreenState extends State<AllergySetupScreen> {
  final Set<String> _selected = {};

  static const List<Map<String, String>> _allergens = [
    {
      'id': 'milk',
      'name': 'Milk',
      'emoji': '🥛',
      'sub': 'Casein, whey, lactose',
    },
    {'id': 'eggs', 'name': 'Eggs', 'emoji': '🥚', 'sub': 'Albumin, mayonnaise'},
    {
      'id': 'peanuts',
      'name': 'Peanuts',
      'emoji': '🥜',
      'sub': 'Groundnut, arachis oil',
    },
    {
      'id': 'tree_nuts',
      'name': 'Tree Nuts',
      'emoji': '🌰',
      'sub': 'Cashew, almond, walnut',
    },
    {
      'id': 'wheat',
      'name': 'Wheat',
      'emoji': '🌾',
      'sub': 'Gluten, flour, semolina',
    },
    {'id': 'soy', 'name': 'Soy', 'emoji': '🫘', 'sub': 'Maggi cubes, tofu'},
    {
      'id': 'fish',
      'name': 'Fish',
      'emoji': '🐟',
      'sub': 'Stockfish, dried fish',
    },
    {
      'id': 'shellfish',
      'name': 'Shellfish',
      'emoji': '🦐',
      'sub': 'Crayfish, shrimp, prawn',
    },
    {
      'id': 'sesame',
      'name': 'Sesame',
      'emoji': '🌱',
      'sub': 'Tahini, sesame oil',
    },
  ];

  void _toggle(String id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );

  void _onContinue() {
    if (_selected.isEmpty) {
      _showSkipDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SeveritySetupScreen(selectedAllergens: _selected.toList()),
      ),
    );
  }


void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'No allergens selected',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'Without selecting allergens, all scans '
          'will return safe results. You can update '
          'your profile any time from the settings screen.',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Go back',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _saveEmptyProfile(); // then navigate
            },
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: AppColors.greenBtn,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveEmptyProfile() {
    // Save empty profile to Hive so AuthWrapper
    // knows setup is complete
    final box = Hive.box<AllergyProfile>('profile');
    box.put(
      'currentUser',
      AllergyProfile(
        selectedAllergens: [],
        severityMap: {},
        cloudBackupEnabled: false,
      ),
    );

    // Navigate to home and clear all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
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
              // ── top bar ───────────────────────────
              TopBar(
                title: 'Your allergens',
                subtitle: 'Tap everything that applies to you',
              ),

              // ── progress indicator ────────────────
              ProgressRow(step: 1, total: 2),

              // ── allergen grid ─────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.88,
                        ),
                    itemCount: _allergens.length,
                    itemBuilder: (_, i) {
                      final a = _allergens[i];
                      final sel = _selected.contains(a['id']);
                      return AllergenCard(
                        name: a['name']!,
                        emoji: a['emoji']!,
                        sub: a['sub']!,
                        selected: sel,
                        onTap: () => _toggle(a['id']!),
                      );
                    },
                  ),
                ),
              ),

              // ── bottom action area ────────────────
              BottomAction(
                label: _selected.isEmpty
                    ? 'Skip for now'
                    : 'Continue  →  Set severity'
                          '${_selected.length > 1 ? " (${_selected.length})" : ""}',
                onPressed: _onContinue,
                note: _selected.isEmpty
                    ? 'You can add allergens later in your profile'
                    : '${_selected.length} allergen'
                          '${_selected.length > 1 ? "s" : ""} selected',
                noteIsSuccess: _selected.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

// Top bar with title and subtitle
