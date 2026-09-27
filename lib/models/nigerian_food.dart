import 'package:hive/hive.dart';

part 'nigerian_food.g.dart';

@HiveType(typeId: 2)
class NigerianFood extends HiveObject {
  @HiveField(0)
  String foodId;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> allergens;

  @HiveField(3)
  List<String> commonIngredients;

  @HiveField(4)
  String hiddenAllergenNote;

  @HiveField(5)
  String region;

  @HiveField(6)
  String vendorVariation;

  NigerianFood({
    required this.foodId,
    required this.name,
    required this.allergens,
    required this.commonIngredients,
    required this.hiddenAllergenNote,
    required this.region,
    required this.vendorVariation,
  });
}
