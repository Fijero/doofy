
import 'package:doofy/models/allergen_model.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/models/nigerian_food.dart';
import 'package:hive/hive.dart';

class HiveInit {
  static Future<void> initHive() async{

  // register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AllergyProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(AllergenModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(NigerianFoodAdapter());
  }

  //open all hive boxes safely
  if (!Hive.isBoxOpen('profile')) {
    await Hive.openBox<AllergyProfile>('profile');
  }
  if (!Hive.isBoxOpen('allergens')) {
    await Hive.openBox<AllergenModel>('allergens');
  }
  if (!Hive.isBoxOpen('nigerian_foods')) {
    await Hive.openBox<NigerianFood>('nigerian_foods');
  }

  // Untyped boxes
  if (!Hive.isBoxOpen('food_alternatives')) {
    await Hive.openBox('food_alternatives');
  }
  if (!Hive.isBoxOpen('history')) {
    await Hive.openBox('history');
  }
  if (!Hive.isBoxOpen('barcodes')) {
    await Hive.openBox('barcodes');
  }
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  }
}