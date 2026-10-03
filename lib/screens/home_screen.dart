import 'package:doofy/screens/barcode_scan_screen.dart';
import 'package:doofy/screens/camera_scan_screen.dart';
import 'package:doofy/screens/manual_input_screen.dart';
import 'package:doofy/screens/nigerian_foods_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/components/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AllergyProfile? _profile;

  static const Map<String, String> _allergenNames = {
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

  static const Map<String, String> _allergenEmojis = {
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
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box<AllergyProfile>('profile');
    setState(() => _profile = box.get('currentUser'));
  }

  String get _userInitials {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email ?? 'U';
    return name.substring(0, 1).toUpperCase();
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? 'User';
  }

  void _comingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ' sorry $name is still in progress',
          style: TextStyle(color: Colors.amber.shade800),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.amber.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // header
          _Header(userName: _userName, initials: _userInitials),

          // scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // active allergens card
                  _ActiveAllergensCard(
                    profile: _profile,
                    allergenNames: _allergenNames,
                    allergenEmojis: _allergenEmojis,
                  ),

                  const SizedBox(height: 20),

                  const _SectionLabel('How would you like to check?'),

                  const SizedBox(height: 20),

                  // scan label
                  _ScanCard(
                    icon: Icons.document_scanner_rounded,
                    iconBg: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                    title: 'Scan ingredient label',
                    subtitle: 'Point camera at ingredient list',
                    badge: 'Offline',
                    badgeColor: const Color(0xFF3B6D13),
                    badgeBg: const Color(0xFFEAF3DE),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraScanScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // scan barcode
                  _ScanCard(
                    icon: Icons.qr_code_scanner_rounded,
                    iconBg: const Color(0xFFEAF3DE),
                    iconColor: const Color(0xFF3B6D13),
                    title: 'Scan barcode',
                    subtitle: 'Point camera at product barcode',
                    badge: 'Online',
                    badgeColor: const Color(0xFF185FA5),
                    badgeBg: const Color(0xFFE6F1FB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarcodeScanScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // enter manually
                  _ScanCard(
                    icon: Icons.edit_rounded,
                    iconBg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                    title: 'Enter manually',
                    subtitle: 'Type or paste ingredients',
                    badge: 'Always works',
                    badgeColor: const Color(0xFF854F0B),
                    badgeBg: const Color(0xFFFAEEDA),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ManualInputScreen(initialText: ''),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Nigerian foods
                  _ScanCard(
                    icon: Icons.restaurant_menu_rounded,
                    iconBg: const Color(0xFFFBEAF0),
                    iconColor: const Color(0xFF993556),
                    title: 'Nigerian foods',
                    subtitle: 'Search local dishes',
                    badge: 'Offline',
                    badgeColor: const Color(0xFF3B6D13),
                    badgeBg: const Color(0xFFEAF3DE),
                   onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NigerianFoodsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// header

class _Header extends StatelessWidget {
  final String userName;
  final String initials;

  const _Header({required this.userName, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.greenBtn,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // shield icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.greenBtn.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.greenLight,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          // greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF378ADD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  active alergen card

class _ActiveAllergensCard extends StatelessWidget {
  final AllergyProfile? profile;
  final Map<String, String> allergenNames;
  final Map<String, String> allergenEmojis;

  const _ActiveAllergensCard({
    required this.profile,
    required this.allergenNames,
    required this.allergenEmojis,
  });

  @override
  Widget build(BuildContext context) {
    final allergens = profile?.selectedAllergens ?? [];
    final severityMap = profile?.severityMap ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // color: const Color(0xFF1A1A2E),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            children: [
              const Icon(
                Icons.manage_accounts_rounded,
                color: Color(0xFFAAAAAA),
                size: 14,
              ),
              const SizedBox(width: 5),
              const Text(
                'Your active allergens',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF378ADD),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // chips or empty state
          allergens.isEmpty
              ? const _EmptyAllergenState()
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allergens.map((id) {
                    final isSevere = severityMap[id] == 'severe';
                    return _AllergenChip(
                      emoji: allergenEmojis[id] ?? '⚠️',
                      label: allergenNames[id] ?? id,
                      isSevere: isSevere,
                    );
                  }).toList(),
                ),

          const SizedBox(height: 10),

          // legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFFE24B4A), label: 'Severe'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFEF9F27), label: 'Intolerant'),
              const Spacer(),
              if (allergens.isNotEmpty)
                Text(
                  '${allergens.length} allergen'
                  '${allergens.length > 1 ? "s" : ""}'
                  ' active',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllergenChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSevere;

  const _AllergenChip({
    required this.emoji,
    required this.label,
    required this.isSevere,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSevere ? const Color(0xFFE24B4A) : const Color(0xFFEF9F27);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAllergenState extends StatelessWidget {
  const _EmptyAllergenState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            color: Color(0xFF555555),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            'No allergens selected — tap Edit to add',
            style: TextStyle(color: Color(0xFF666666), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 10),
        ),
      ],
    );
  }
}

// section label
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
        letterSpacing: 0.3,
      ),
    );
  }
}

// scan card
class _ScanCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final VoidCallback onTap;

  const _ScanCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),

            const SizedBox(width: 6),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
