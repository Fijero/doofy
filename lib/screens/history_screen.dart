import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/components/app_colors.dart';
import 'package:doofy/services/allergen_detection_service.dart';
import 'package:doofy/screens/scan_result_screen.dart';

// ─────────────────────────────────────────────────────────────
//  history_screen.dart
//
//  Features:
//  - Reads all scan records from Hive history box
//  - Shows chronological list newest first
//  - Colour coded status dots (green safe, red severe,
//    orange intolerant)
//  - Shows allergen names detected and scan method
//  - Tap any item to view the full result screen
//  - Empty state when no scans exist
//  - Clear all history button
//  - Filter by result type (All, Safe, Unsafe)
// ─────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<dynamic, dynamic>> _allScans = [];
  String _filter = 'all'; // all | safe | unsafe

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final box = Hive.box('history');
    final raw = box.values.toList();

    // Reverse so newest is first
    final scans = raw
        .whereType<Map>()
        .map((e) => Map<dynamic, dynamic>.from(e))
        .toList()
        .reversed
        .toList();

    setState(() => _allScans = scans);
  }

  List<Map<dynamic, dynamic>> get _filteredScans {
    if (_filter == 'safe') {
      return _allScans.where((s) => s['status'] == 'SAFE').toList();
    }
    if (_filter == 'unsafe') {
      return _allScans.where((s) => s['status'] != 'SAFE').toList();
    }
    return _allScans;
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear scan history',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'This will permanently delete all your '
          'previous scan records. '
          'This cannot be undone.',
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
              'Clear all',
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
      await Hive.box('history').clear();
      _loadHistory();
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

  void _openScan(Map<dynamic, dynamic> scan) {
    // Rebuild a ScanResultData from the stored map
    final rawDetected = scan['detectedAllergens'] as List? ?? [];

    final detected = rawDetected
        .whereType<Map>()
        .map(
          (d) => DetectedAllergen(
            allergenId: d['allergenId']?.toString() ?? '',
            allergenName: d['allergenName']?.toString() ?? '',
            triggeredBy: d['triggeredBy']?.toString() ?? '',
            severity: d['severity']?.toString() ?? 'intolerant',
          ),
        )
        .toList();

    final status = scan['status']?.toString() ?? 'SAFE';
    final method = scan['scanMethod']?.toString() ?? 'manual';
    final text = scan['ingredientText']?.toString() ?? '';
    final tsRaw = scan['timestamp']?.toString() ?? '';

    DateTime timestamp;
    try {
      timestamp = DateTime.parse(tsRaw);
    } catch (_) {
      timestamp = DateTime.now();
    }

    final result = ScanResultData(
      ingredientText: text,
      detectedAllergens: detected,
      status: status,
      scanMethod: method,
      timestamp: timestamp,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanResultScreen(result: result)),
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
            _HistoryHeader(
              totalCount: _allScans.length,
              onClear: _allScans.isEmpty ? null : _clearHistory,
            ),

            // ── filter chips ─────────────────────
            if (_allScans.isNotEmpty)
              _FilterRow(
                current: _filter,
                onChanged: (f) => setState(() => _filter = f),
                allCount: _allScans.length,
                safeCount: _allScans.where((s) => s['status'] == 'SAFE').length,
                unsafeCount: _allScans
                    .where((s) => s['status'] != 'SAFE')
                    .length,
              ),

            // ── list or empty state ───────────────
            Expanded(
              child: _allScans.isEmpty
                  ? const _EmptyState()
                  : _filteredScans.isEmpty
                  ? _EmptyFilterState(filter: _filter)
                  : RefreshIndicator(
                      onRefresh: () async => _loadHistory(),
                      color: AppColors.greenBtn,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: _filteredScans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final scan = _filteredScans[i];
                          return _HistoryCard(
                            scan: scan,
                            onTap: () => _openScan(scan),
                          );
                        },
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
class _HistoryHeader extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onClear;

  const _HistoryHeader({required this.totalCount, required this.onClear});

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  totalCount == 0
                      ? 'No scans yet'
                      : '$totalCount scan'
                            '${totalCount > 1 ? "s" : ""}'
                            ' recorded',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),

          // Clear button
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FILTER ROW
// ─────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  final int allCount;
  final int safeCount;
  final int unsafeCount;

  const _FilterRow({
    required this.current,
    required this.onChanged,
    required this.allCount,
    required this.safeCount,
    required this.unsafeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _FilterChip(
            label: 'All ($allCount)',
            active: current == 'all',
            onTap: () => onChanged('all'),
            color: const Color(0xFF1A1A2E),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Safe ($safeCount)',
            active: current == 'safe',
            onTap: () => onChanged('safe'),
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Unsafe ($unsafeCount)',
            active: current == 'unsafe',
            onTap: () => onChanged('unsafe'),
            color: const Color(0xFFA32D2D),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : const Color(0xFFDDDDDD),
            width: active ? 0 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HISTORY CARD
// ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final Map<dynamic, dynamic> scan;
  final VoidCallback onTap;

  const _HistoryCard({required this.scan, required this.onTap});

  static const Map<String, String> _methodLabels = {
    'manual': 'Manual input',
    'camera': 'Label scan',
    'barcode': 'Barcode scan',
    'nigerian_foods': 'Nigerian foods',
  };

  static const Map<String, IconData> _methodIcons = {
    'manual': Icons.edit_rounded,
    'camera': Icons.document_scanner_rounded,
    'barcode': Icons.qr_code_scanner_rounded,
    'nigerian_foods': Icons.restaurant_menu_rounded,
  };

  String get _status => scan['status']?.toString() ?? 'SAFE';

  bool get _isSafe => _status == 'SAFE';

  bool get _isSevere {
    final detected = scan['detectedAllergens'] as List? ?? [];
    return detected.any((d) => (d as Map?)?['severity'] == 'severe');
  }

  Color get _statusColor {
    if (_isSafe) return const Color(0xFF2E7D32);
    if (_isSevere) return const Color(0xFFA32D2D);
    return const Color(0xFF854F0B);
  }

  Color get _statusBg {
    if (_isSafe) return const Color(0xFFEAF3DE);
    if (_isSevere) return const Color(0xFFFCEBEB);
    return const Color(0xFFFAEEDA);
  }

  String get _statusLabel {
    if (_isSafe) return 'Safe';
    if (_status == 'MULTIPLE_DETECTED') {
      return 'Multiple detected';
    }
    return 'Allergen detected';
  }

  String get _detectedNames {
    final detected = scan['detectedAllergens'] as List? ?? [];
    if (detected.isEmpty) return '';
    return detected
        .whereType<Map>()
        .map((d) => d['allergenName']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
  }

  String get _timeLabel {
    final tsRaw = scan['timestamp']?.toString() ?? '';
    try {
      final ts = DateTime.parse(tsRaw);
      final now = DateTime.now();
      final diff = now.difference(ts);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      }
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      }
      return '${ts.day}/${ts.month}/${ts.year}';
    } catch (_) {
      return '';
    }
  }

  String get _preview {
    final text = scan['ingredientText']?.toString() ?? '';
    if (text.length <= 40) return text;
    return '${text.substring(0, 40)}...';
  }

  String get _method => scan['scanMethod']?.toString() ?? 'manual';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSafe
                ? const Color(0xFFEEEEEE)
                : _statusColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // status badge + time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // detected allergens or safe message
                  if (!_isSafe && _detectedNames.isNotEmpty)
                    Text(
                      _detectedNames,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  if (_isSafe)
                    const Text(
                      'No allergens found',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                  const SizedBox(height: 3),

                  // ingredient preview
                  Text(
                    _preview,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // scan method row
                  Row(
                    children: [
                      Icon(
                        _methodIcons[_method] ?? Icons.edit_rounded,
                        size: 12,
                        color: const Color(0xFFAAAAAA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _methodLabels[_method] ?? 'Manual input',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // chevron
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

// ─────────────────────────────────────────────────────────────
//  EMPTY STATE — no scans at all
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.greenBtn.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.greenBtn,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your scan history will appear here\n'
              'after you check a food for allergens.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPTY FILTER STATE — filter returns no results
// ─────────────────────────────────────────────────────────────
class _EmptyFilterState extends StatelessWidget {
  final String filter;
  const _EmptyFilterState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: Color(0xFFCCCCCC),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No ${filter == "safe" ? "safe" : "unsafe"} '
            'scans found',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
