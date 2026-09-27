import 'package:doofy/models/allergen_model.dart';
import 'package:doofy/models/nigerian_food.dart';
import 'package:doofy/screens/allergy_setup.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/components/app_colors.dart' hide AppColors;
import 'package:doofy/models/allergy_profile.dart';

// ─────────────────────────────────────────────────────────────
//  settings_screen.dart
//
//  Sections:
//  1. Scanning preferences
//     - Cloud OCR fallback toggle
//     - Default scan mode
//  2. Allergen detection
//     - Synonym matching toggle
//     - Minimum word count threshold
//  3. Privacy and data
//     - Cloud backup toggle
//     - Clear scan history
//     - Clear allergen cache
//     - Export profile data
//  4. Notifications
//     - Scan alerts
//     - Database update alerts
//  5. About
//     - App version
//     - Database version
//     - Rate app
//     - Share app
//     - Contact support
//  6. Danger zone
//     - Reset all data
// ─────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── settings state ────────────────────────────
  bool _cloudOCREnabled = false;
  bool _cloudBackupEnabled = false;
  bool _scanNotifications = true;
  bool _updateNotifications = true;
  bool _synonymMatching = true;
  String _defaultScanMode = 'label';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── load saved settings from Hive ────────────
  void _loadSettings() {
    final box = Hive.box('settings');
    final profileBox = Hive.box<AllergyProfile>('profile');
    final profile = profileBox.get('currentUser');

    setState(() {
      _cloudOCREnabled = box.get('cloudOCR', defaultValue: false);
      _cloudBackupEnabled = profile?.cloudBackupEnabled ?? false;
      _scanNotifications = box.get('scanNotif', defaultValue: true);
      _updateNotifications = box.get('updateNotif', defaultValue: true);
      _synonymMatching = box.get('synonymMatch', defaultValue: true);
      _defaultScanMode = box.get('defaultScan', defaultValue: 'label');
    });
  }

  // ── save a setting to Hive ────────────────────
  void _saveSetting(String key, dynamic value) {
    Hive.box('settings').put(key, value);
  }

  // ── toggle cloud OCR ─────────────────────────
  void _toggleCloudOCR(bool value) {
    if (value) {
      // Show consent dialog before enabling
      _showCloudOCRConsentDialog();
    } else {
      setState(() => _cloudOCREnabled = false);
      _saveSetting('cloudOCR', false);
    }
  }

  // ── toggle cloud backup ───────────────────────
  void _toggleCloudBackup(bool value) {
    setState(() => _cloudBackupEnabled = value);
    _saveSetting('cloudBackup', value);

    // Update the AllergyProfile in Hive
    final box = Hive.box<AllergyProfile>('profile');
    final profile = box.get('currentUser');
    if (profile != null) {
      profile.cloudBackupEnabled = value;
      profile.save();
    }

    _showSnack(
      value
          ? 'Cloud backup enabled'
          : 'Cloud backup disabled. Profile stays on device only.',
    );
  }

  Future<void> _showCloudOCRConsentDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enable Cloud OCR?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'When enabled, label images that cannot '
          'be read clearly by the on-device scanner '
          'will be sent to Google Cloud Vision for '
          'better accuracy.\n\n'
          'Your food label image will be processed '
          'by Google servers and then discarded. '
          'No personal data is included.',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6),
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
              'Enable',
              style: TextStyle(
                color: Color(0xFF388E3C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _cloudOCREnabled = true);
      _saveSetting('cloudOCR', true);
      _showSnack('Cloud OCR enabled');
    }
  }

  Future<void> _clearScanHistory() async {
    final confirmed = await _showConfirmDialog(
      title: 'Clear scan history',
      message:
          'This will permanently delete all your '
          'previous scan records. This cannot be undone.',
      confirmLabel: 'Clear history',
      isDestructive: true,
    );

    if (confirmed == true) {
      await Hive.box('history').clear();
      _showSnack('Scan history cleared');
    }
  }

  Future<void> _clearAllergenCache() async {
    final confirmed = await _showConfirmDialog(
      title: 'Clear allergen cache',
      message:
          'This will delete the locally cached '
          'allergen database. It will be re-downloaded '
          'from the server on next app launch.',
      confirmLabel: 'Clear cache',
      isDestructive: false,
    );

    if (confirmed == true) {
      await Hive.box('allergens').clear();
      await Hive.box('food_alternatives').clear();
      await Hive.box('nigerian_foods').clear();
      _showSnack('Cache cleared. Database will sync on next launch.');
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await _showConfirmDialog(
      title: 'Reset all data',
      message:
          'This will permanently delete your allergy '
          'profile, all scan history, all cached data, '
          'and all settings. You will need to set up '
          'the app again from scratch.\n\n'
          'This cannot be undone.',
      confirmLabel: 'Reset everything',
      isDestructive: true,
    );

    if (confirmed == true) {
      await Hive.box<AllergyProfile>('profile').clear();
      await Hive.box<AllergenModel>('allergens').clear();
      await Hive.box('history').clear();
      await Hive.box<NigerianFood>('nigerian_foods').clear();
      await Hive.box('food_alternatives').clear();
      await Hive.box('barcodes').clear();
      await Hive.box('settings').clear();

      if (mounted) {
        _showSnack('All data reset.');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AllergySetupScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
            height: 1.6,
          ),
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
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive
                    ? const Color(0xFFA32D2D)
                    : AppColors.greenBtn,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── header ───────────────────────────
            _SettingsHeader(),

            // ── scrollable content ───────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // ── scanning preferences ─────
                  _SectionTitle('Scanning'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        icon: Icons.cloud_done_rounded,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        title: 'Cloud OCR fallback',
                        subtitle:
                            'Improve accuracy on unclear labels '
                            'by using cloud processing',
                        value: _cloudOCREnabled,
                        onChanged: _toggleCloudOCR,
                      ),
                      _Divider(),
                      _SelectRow(
                        icon: Icons.document_scanner_rounded,
                        iconBg: const Color(0xFFEAF3DE),
                        iconColor: const Color(0xFF3B6D11),
                        title: 'Default scan mode',
                        subtitle: _defaultScanLabel,
                        onTap: _showDefaultScanPicker,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── allergen detection ────────
                  _SectionTitle('Allergen Detection'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        icon: Icons.manage_search_rounded,
                        iconBg: const Color(0xFFFBEAF0),
                        iconColor: const Color(0xFF993556),
                        title: 'Synonym matching',
                        subtitle:
                            'Detect allergens declared under '
                            'alternative names like casein for milk',
                        value: _synonymMatching,
                        onChanged: (v) {
                          setState(() => _synonymMatching = v);
                          _saveSetting('synonymMatch', v);
                        },
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.info_outline_rounded,
                        iconBg: const Color(0xFFFAEEDA),
                        iconColor: const Color(0xFF854F0B),
                        title: 'Allergen database',
                        subtitle:
                            '9 major allergens with full synonym coverage',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── privacy and data ──────────
                  _SectionTitle('Privacy and Data'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        icon: Icons.cloud_upload_rounded,
                        iconBg: const Color(0xFFEAF3DE),
                        iconColor: const Color(0xFF3B6D11),
                        title: 'Cloud backup',
                        subtitle: 'Sync your allergy profile to the cloud',
                        value: _cloudBackupEnabled,
                        onChanged: _toggleCloudBackup,
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.history_rounded,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        title: 'Clear scan history',
                        subtitle: 'Delete all previous scan records',
                        onTap: _clearScanHistory,
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.cached_rounded,
                        iconBg: const Color(0xFFFAEEDA),
                        iconColor: const Color(0xFF854F0B),
                        title: 'Clear allergen cache',
                        subtitle: 'Force re-download of allergen database',
                        onTap: _clearAllergenCache,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── notifications ─────────────
                  _SectionTitle('Notifications'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_active_rounded,
                        iconBg: const Color(0xFFEAF3DE),
                        iconColor: const Color(0xFF3B6D11),
                        title: 'Scan alerts',
                        subtitle: 'Notify when allergens are detected',
                        value: _scanNotifications,
                        onChanged: (v) {
                          setState(() => _scanNotifications = v);
                          _saveSetting('scanNotif', v);
                        },
                      ),
                      _Divider(),
                      _ToggleRow(
                        icon: Icons.system_update_rounded,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        title: 'Database updates',
                        subtitle: 'Notify when allergen database is updated',
                        value: _updateNotifications,
                        onChanged: (v) {
                          setState(() => _updateNotifications = v);
                          _saveSetting('updateNotif', v);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── about ─────────────────────
                  _SectionTitle('About'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _InfoRow(
                        icon: Icons.shield_rounded,
                        iconBg: const Color(0xFFEAF3DE),
                        iconColor: const Color(0xFF3B6D11),
                        title: 'App version',
                        subtitle: '1.0.0',
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.dataset_rounded,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        title: 'Database version',
                        subtitle: _getDatabaseVersion(),
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.star_outline_rounded,
                        iconBg: const Color(0xFFFAEEDA),
                        iconColor: const Color(0xFF854F0B),
                        title: 'Rate the app',
                        subtitle: 'Share your feedback on the app store',
                        onTap: () {
                          // TODO: open app store rating
                        },
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.share_rounded,
                        iconBg: const Color(0xFFFBEAF0),
                        iconColor: const Color(0xFF993556),
                        title: 'Share app',
                        subtitle: 'Tell a friend about AllergyAlert',
                        onTap: () {
                          // TODO: use share_plus package
                        },
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.support_agent_rounded,
                        iconBg: const Color(0xFFEAF3DE),
                        iconColor: const Color(0xFF3B6D11),
                        title: 'Contact support',
                        subtitle: 'Get help or report an issue',
                        onTap: () {
                          // TODO: open email or support URL
                        },
                      ),
                      _Divider(),
                      _ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        title: 'Privacy policy',
                        subtitle: 'How we handle your data',
                        onTap: () {
                          // TODO: open privacy policy URL
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── danger zone ───────────────
                  _SectionTitle('Danger Zone'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ActionRow(
                        icon: Icons.delete_forever_rounded,
                        iconBg: const Color(0xFFFCEBEB),
                        iconColor: const Color(0xFFA32D2D),
                        title: 'Reset all data',
                        subtitle:
                            'Delete profile, history and all '
                            'settings permanently',
                        onTap: _resetAllData,
                        titleColor: const Color(0xFFA32D2D),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _defaultScanLabel {
    switch (_defaultScanMode) {
      case 'barcode':
        return 'Barcode scan';
      case 'manual':
        return 'Manual input';
      case 'nigerian':
        return 'Nigerian foods';
      default:
        return 'Label scan';
    }
  }

  String _getDatabaseVersion() {
    final box = Hive.box('settings');
    final v = box.get('dbVersion', defaultValue: '—');
    return 'Version $v';
  }

  void _showDefaultScanPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Default scan mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...[
              {
                'value': 'label',
                'label': 'Label scan',
                'icon': Icons.document_scanner_rounded,
              },
              {
                'value': 'barcode',
                'label': 'Barcode scan',
                'icon': Icons.qr_code_scanner_rounded,
              },
              {
                'value': 'manual',
                'label': 'Manual input',
                'icon': Icons.edit_rounded,
              },
              {
                'value': 'nigerian',
                'label': 'Nigerian foods',
                'icon': Icons.restaurant_menu_rounded,
              },
            ].map((item) {
              final isSelected = _defaultScanMode == item['value'];
              return GestureDetector(
                onTap: () {
                  setState(() => _defaultScanMode = item['value'] as String);
                  _saveSetting('defaultScan', item['value']);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.greenBtn.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.greenBtn
                          : const Color(0xFFEEEEEE),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? AppColors.greenBtn
                            : const Color(0xFF888888),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.greenBtn
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.greenBtn,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.greenBtn,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
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

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

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
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.greenBtn,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _ActionRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
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
                      color: titleColor ?? const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
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

class _SelectRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
                      color: AppColors.greenBtn,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
        ],
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
