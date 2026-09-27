import 'package:hive/hive.dart';

part 'allergy_profile.g.dart';

@HiveType(typeId: 0)
class AllergyProfile extends HiveObject {
  @HiveField(0)
  List<String> selectedAllergens;

  @HiveField(1)
  Map<String, String> severityMap;

  @HiveField(2)
  bool cloudBackupEnabled;

  AllergyProfile({
    required this.selectedAllergens,
    required this.severityMap,
    this.cloudBackupEnabled = false,
  });
}
