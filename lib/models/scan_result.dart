import 'package:hive/hive.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 3)
class DetectedAllergen {
  @HiveField(0)
  String allergenName;

  @HiveField(1)
  String triggeredBy;

  @HiveField(2)
  String severity;

  DetectedAllergen({
    required this.allergenName,
    required this.triggeredBy,
    required this.severity,
  });
}

@HiveType(typeId: 4)
class ScanResult extends HiveObject {
  @HiveField(0)
  String ingredientText;

  @HiveField(1)
  List<DetectedAllergen> detectedAllergens;

  @HiveField(2)
  String status;

  @HiveField(3)
  String scanMethod;

  @HiveField(4)
  DateTime timestamp;

  ScanResult({
    required this.ingredientText,
    required this.detectedAllergens,
    required this.status,
    required this.scanMethod,
    required this.timestamp,
  });
}
