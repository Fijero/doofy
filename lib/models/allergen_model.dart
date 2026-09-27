
import 'package:hive/hive.dart';

part 'allergen_model.g.dart';

@HiveType(typeId: 1)
class AllergenModel extends HiveObject {
  @HiveField(0)
  String allergenId;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> synonyms;

  @HiveField(3)
  List<String> nutrientsProvided;

  AllergenModel({
    required this.allergenId,
    required this.name,
    required this.synonyms,
    required this.nutrientsProvided,
  });
}
