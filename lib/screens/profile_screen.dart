import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/components/app_colors.dart';
import 'package:doofy/screens/allergy_setup.dart' hide AppColors;
import 'package:doofy/auth/login.dart';

// ─────────────────────────────────────────────────────────────
//  profile_screen.dart
//
//  Features:
//  - User avatar, name and email from Firebase
//  - Current allergen profile summary from Hive
//  - Edit allergens button → navigates to AllergySetupScreen
//  - App settings section (notifications, cloud backup)
//  - Privacy settings section
//  - About section (version, terms, privacy policy)
//  - Logout button
// ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AllergyProfile? _profile;
  bool _notificationsEnabled = true;
  bool _cloudBackupEnabled = false;
  bool _cloudOCREnabled = false;

  final User? _user = FirebaseAuth.instance.currentUser;

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
    final profile = box.get('currentUser');
    setState(() {
      _profile = profile;
      _cloudBackupEnabled = profile?.cloudBackupEnabled ?? false;
    });
  }

  String get _userInitials {
    final name = _user?.displayName ?? _user?.email ?? 'U';
    if (name.contains(' ')) {
      final parts = name.split(' ');
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String get _userName {
    return _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
  }

  String get _userEmail {
    return _user?.email ?? 'No email';
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out? '
          'Your allergy profile will remain '
          'saved on this device.',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFFA32D2D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _clearScanHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear scan history'),
        content: const Text(
          'This will delete all your previous '
          'scan records. This cannot be undone.',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFA32D2D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final box = Hive.box('history');
      await box.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Scan history cleared'),
            backgroundColor: AppColors.green,
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

  void _toggleCloudBackup(bool value) {
    setState(() => _cloudBackupEnabled = value);
    final box = Hive.box<AllergyProfile>('profile');
    final profile = box.get('currentUser');
    if (profile != null) {
      profile.cloudBackupEnabled = value;
      profile.save();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Cloud backup enabled' : 'Cloud backup disabled'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allergens = _profile?.selectedAllergens ?? [];
    final severityMap = _profile?.severityMap ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── header ──────────────────────────
            _ProfileHeader(
              initials: _userInitials,
              name: _userName,
              email: _userEmail,
              allergenCount: allergens.length,
            ),

            // ── scrollable content ───────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // allergen profile section
                    _SectionTitle('Allergy Profile'),
                    const SizedBox(height: 10),
                    _AllergenProfileCard(
                      allergens: allergens,
                      severityMap: severityMap,
                      allergenNames: _allergenNames,
                      allergenEmojis: _allergenEmojis,
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllergySetupScreen(),
                          ),
                        );
                        // Reload profile after edit
                        _loadProfile();
                      },
                    ),

                    const SizedBox(height: 20),

                    // settings section
                    // _SectionTitle('Settings'),
                    // const SizedBox(height: 10),
                    // _SettingsCard(
                    //   children: [
                    //     _ToggleRow(
                    //       icon: Icons.notifications_rounded,
                    //       iconColor: const Color(0xFF185FA5),
                    //       iconBg: const Color(0xFFE6F1FB),
                    //       title: 'Notifications',
                    //       subtitle: 'Allergy alerts and reminders',
                    //       value: _notificationsEnabled,
                    //       onChanged: (v) =>
                    //           setState(() => _notificationsEnabled = v),
                    //     ),
                    //     _Divider(),
                    //     _ToggleRow(
                    //       icon: Icons.cloud_upload_rounded,
                    //       iconColor: const Color(0xFF3B6D11),
                    //       iconBg: const Color(0xFFEAF3DE),
                    //       title: 'Cloud backup',
                    //       subtitle: 'Sync profile to cloud storage',
                    //       value: _cloudBackupEnabled,
                    //       onChanged: _toggleCloudBackup,
                    //     ),
                    //     _Divider(),
                    //     _ToggleRow(
                    //       icon: Icons.cloud_done_rounded,
                    //       iconColor: const Color(0xFF854F0B),
                    //       iconBg: const Color(0xFFFAEEDA),
                    //       title: 'Cloud OCR fallback',
                    //       subtitle: 'Use cloud for unclear label scans',
                    //       value: _cloudOCREnabled,
                    //       onChanged: (v) =>
                    //           setState(() => _cloudOCREnabled = v),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),

                    // privacy section
                    _SectionTitle('Privacy & Data'),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      children: [
                        _ActionRow(
                          icon: Icons.history_rounded,
                          iconColor: const Color(0xFF993556),
                          iconBg: const Color(0xFFFBEAF0),
                          title: 'Clear scan history',
                          subtitle: 'Delete all previous scan records',
                          onTap: _clearScanHistory,
                          isDestructive: false,
                        ),
                        _Divider(),
                        _ActionRow(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF185FA5),
                          iconBg: const Color(0xFFE6F1FB),
                          title: 'Privacy policy',
                          subtitle: 'How we handle your data',
                          onTap: () {
                            // TODO: open privacy policy URL
                          },
                          isDestructive: false,
                        ),
                        _Divider(),
                        _ActionRow(
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFF3B6D11),
                          iconBg: const Color(0xFFEAF3DE),
                          title: 'Terms of service',
                          subtitle: 'Read our terms and conditions',
                          onTap: () {
                            // TODO: open terms URL
                          },
                          isDestructive: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // about section
                    _SectionTitle('About'),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      children: [
                        _ActionRow(
                          icon: Icons.info_outline_rounded,
                          iconColor: const Color(0xFF185FA5),
                          iconBg: const Color(0xFFE6F1FB),
                          title: 'App version',
                          subtitle: '1.0.0',
                          onTap: () {},
                          isDestructive: false,
                          showChevron: false,
                        ),
                        _Divider(),
                        _ActionRow(
                          icon: Icons.star_outline_rounded,
                          iconColor: const Color(0xFF854F0B),
                          iconBg: const Color(0xFFFAEEDA),
                          title: 'Rate the app',
                          subtitle: 'Share your feedback on the app store',
                          onTap: () {
                            // TODO: open app store rating
                          },
                          isDestructive: false,
                        ),
                        _Divider(),
                        _ActionRow(
                          icon: Icons.share_rounded,
                          iconColor: const Color(0xFF3B6D11),
                          iconBg: const Color(0xFFEAF3DE),
                          title: 'Share app',
                          subtitle: 'Tell a friend about AllergyAlert',
                          onTap: () {
                            // TODO: share app link
                          },
                          isDestructive: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFFA32D2D),
                        ),
                        label: const Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA32D2D),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF8D7DA),
                            width: 1,
                          ),
                          backgroundColor: const Color(0xFFFCEBEB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
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
//  PROFILE HEADER
// ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final int allergenCount;

  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.allergenCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // top row — title and edit
          Row(
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  // color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 20),

          // avatar + info
          Row(
            children: [
              // large avatar
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF378ADD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        // color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.warning_amber_rounded,
                label: '$allergenCount',
                sublabel: allergenCount == 1 ? 'Allergen' : 'Allergens',
                color: const Color(0xFFE24B4A),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.shield_rounded,
                label: 'Active',
                sublabel: 'Protection',
                color: AppColors.greenLight,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.wifi_off_rounded,
                label: 'Offline',
                sublabel: 'Ready',
                color: const Color(0xFF378ADD),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ALLERGEN PROFILE CARD
// ─────────────────────────────────────────────────────────────
class _AllergenProfileCard extends StatelessWidget {
  final List<String> allergens;
  final Map<String, String> severityMap;
  final Map<String, String> allergenNames;
  final Map<String, String> allergenEmojis;
  final VoidCallback onEdit;

  const _AllergenProfileCard({
    required this.allergens,
    required this.severityMap,
    required this.allergenNames,
    required this.allergenEmojis,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF3B6D11),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your allergens',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBtn,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // allergen list or empty state
          allergens.isEmpty
              ? _EmptyProfile(onEdit: onEdit)
              : Column(
                  children: allergens.map((id) {
                    final isSevere = severityMap[id] == 'severe';
                    return _AllergenRow(
                      emoji: allergenEmojis[id] ?? '⚠️',
                      name: allergenNames[id] ?? id,
                      isSevere: isSevere,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _AllergenRow extends StatelessWidget {
  final String emoji;
  final String name;
  final bool isSevere;

  const _AllergenRow({
    required this.emoji,
    required this.name,
    required this.isSevere,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSevere ? const Color(0xFFA32D2D) : const Color(0xFF854F0B);
    final bg = isSevere ? const Color(0xFFFCEBEB) : const Color(0xFFFAEEDA);
    final label = isSevere ? 'Severe' : 'Intolerant';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  final VoidCallback onEdit;
  const _EmptyProfile({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Icon(
          Icons.add_circle_outline_rounded,
          color: Color(0xFFCCCCCC),
          size: 36,
        ),
        const SizedBox(height: 10),
        const Text(
          'No allergens added yet',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add your allergens so the app can\n'
          'protect you during scanning.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA), height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.greenBtn,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Add allergens',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SETTINGS COMPONENTS
// ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.greenBtn,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDestructive,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 62),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFEEEEEE)),
    );
  }
}
