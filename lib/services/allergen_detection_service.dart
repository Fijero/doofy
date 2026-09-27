// ignore_for_file: avoid_print

import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/models/allergen_model.dart';

// ── detected allergen ─────────────────────────────────────────
class DetectedAllergen {
  final String allergenId;
  final String allergenName;
  final String triggeredBy;
  final String severity;

  DetectedAllergen({
    required this.allergenId,
    required this.allergenName,
    required this.triggeredBy,
    required this.severity,
  });
}

// ── scan result ───────────────────────────────────────────────
class ScanResultData {
  final String ingredientText;
  final List<DetectedAllergen> detectedAllergens;
  final String status;
  final String scanMethod;
  final DateTime timestamp;

  ScanResultData({
    required this.ingredientText,
    required this.detectedAllergens,
    required this.status,
    required this.scanMethod,
    required this.timestamp,
  });

  bool get isSafe => detectedAllergens.isEmpty;
  bool get hasSevere => detectedAllergens.any((d) => d.severity == 'severe');
}

// ── detection service ─────────────────────────────────────────
class AllergenDetectionService {
  static final AllergenDetectionService _instance =
      AllergenDetectionService._internal();
  factory AllergenDetectionService() => _instance;
  AllergenDetectionService._internal();

  Future<ScanResultData> analyse(
    String ingredientText, {
    String scanMethod = 'manual',
  }) async {
    // Step 1 — normalise text
    final normalisedText = _normalise(ingredientText);

    // Step 2 — load user profile from Hive
    // ── FIX: was accidentally loading allergenBox
    //         into profileBox variable ──────────────
    final profileBox = Hive.isBoxOpen('profile')
        ? Hive.box<AllergyProfile>('profile')
        : await Hive.openBox<AllergyProfile>('profile');

    final profile = profileBox.get('currentUser');

    // No profile or no allergens selected
    if (profile == null || profile.selectedAllergens.isEmpty) {
      return ScanResultData(
        ingredientText: ingredientText,
        detectedAllergens: [],
        status: 'SAFE',
        scanMethod: scanMethod,
        timestamp: DateTime.now(),
      );
    }

    // Step 3 — load allergen database from Hive
    // ── FIX: now correctly loading allergenBox ────
    final allergenBox = Hive.isBoxOpen('allergens')
        ? Hive.box<AllergenModel>('allergens')
        : await Hive.openBox<AllergenModel>('allergens');

    final allergenDB = allergenBox.values.toList();

    if (allergenDB.isEmpty) {
      print(
        'WARNING: Allergen database is empty. '
        'Have you populated Firestore and '
        'downloaded to Hive?',
      );
    }

    // Step 4 — detection loop
    final List<DetectedAllergen> detected = [];

    for (final allergenId in profile.selectedAllergens) {
      AllergenModel? allergenData;
      try {
        allergenData = allergenDB.firstWhere((a) => a.allergenId == allergenId);
      } catch (_) {
        print('Allergen "$allergenId" not found in DB');
        continue;
      }

      final allTerms = [
        allergenData.name.toLowerCase(),
        ...allergenData.synonyms.map((s) => s.toLowerCase()),
      ];

      bool found = false;
      for (final term in allTerms) {
        if (normalisedText.contains(term)) {
          detected.add(
            DetectedAllergen(
              allergenId: allergenId,
              allergenName: allergenData.name,
              triggeredBy: term,
              severity: profile.severityMap[allergenId] ?? 'intolerant',
            ),
          );
          found = true;
          break; // stop synonyms, continue outer loop
        }
      }

      if (!found) {
        print('No match for: $allergenId');
      }
    }

    // Step 5 — determine status
    String status;
    if (detected.isEmpty) {
      status = 'SAFE';
    } else if (detected.length == 1) {
      status = 'ALLERGEN_DETECTED';
    } else {
      status = 'MULTIPLE_DETECTED';
    }

    // Step 6 — save to history
    await _saveToHistory(
      ingredientText: ingredientText,
      detected: detected,
      status: status,
      scanMethod: scanMethod,
    );

    return ScanResultData(
      ingredientText: ingredientText,
      detectedAllergens: detected,
      status: status,
      scanMethod: scanMethod,
      timestamp: DateTime.now(),
    );
  }

  String _normalise(String text) {
    return text
        .toLowerCase()
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _saveToHistory({
    required String ingredientText,
    required List<DetectedAllergen> detected,
    required String status,
    required String scanMethod,
  }) async {
    try {
      final box = Hive.isBoxOpen('history')
          ? Hive.box('history')
          : await Hive.openBox('history');

      await box.add({
        'ingredientText': ingredientText,
        'status': status,
        'scanMethod': scanMethod,
        'timestamp': DateTime.now().toIso8601String(),
        'detectedAllergens': detected
            .map(
              (d) => {
                'allergenId': d.allergenId,
                'allergenName': d.allergenName,
                'triggeredBy': d.triggeredBy,
                'severity': d.severity,
              },
            )
            .toList(),
      });
    } catch (e) {
      print('Failed to save history: $e');
    }
  }
}
