import 'package:hive_flutter/hive_flutter.dart';
import 'package:doofy/models/allergen_model.dart';

class SeedHelper {
  static Future<void> seedAllergens() async {
    final box = Hive.box<AllergenModel>('allergens');

    // Already seeded — skip
    // if (box.isNotEmpty) {
    //   print(
    //     '✅ Allergen DB already seeded: '
    //     '${box.length} items',
    //   );
    //   return;
    // }

    await box.put(
      'fish',
      AllergenModel(
        allergenId: 'fish',
        name: 'Fish',
        synonyms: [
          'fish',
          'stockfish',
          'dried fish',
          'smoked fish',
          'fish sauce',
          'anchovies',
          'tilapia',
          'catfish',
          'mackerel',
          'tuna',
          'salmon',
          'sardine',
          'cod',
          'okporoko',
          'panla',
          'titus',
          'kote',
          'fish stock',
          'fish extract',
          'fish oil',
        ],
        nutrientsProvided: ['protein', 'omega-3', 'iodine'],
      ),
    );

    await box.put(
      'shellfish',
      AllergenModel(
        allergenId: 'shellfish',
        name: 'Shellfish',
        synonyms: [
          'shellfish',
          'crayfish',
          'shrimp',
          'prawn',
          'lobster',
          'crab',
          'periwinkle',
          'snail',
          'oyster',
          'scallop',
          'clam',
          'squid',
          'octopus',
          'mussels',
          'seafood',
        ],
        nutrientsProvided: ['protein', 'zinc', 'omega-3'],
      ),
    );

    await box.put(
      'peanuts',
      AllergenModel(
        allergenId: 'peanuts',
        name: 'Peanuts',
        synonyms: [
          'peanuts',
          'peanut',
          'groundnut',
          'groundnut oil',
          'groundnut powder',
          'arachis oil',
          'arachis hypogaea',
          'beer nuts',
          'monkey nuts',
          'mixed nuts',
          'peanut flour',
          'suya'
        ],
        nutrientsProvided: ['protein', 'healthy fats'],
      ),
    );

    await box.put(
      'soy',
      AllergenModel(
        allergenId: 'soy',
        name: 'Soy',
        synonyms: [
          'soy',
          'soya',
          'soybean',
          'soy protein',
          'hydrolysed soy protein',
          'soy lecithin',
          'tofu',
          'miso',
          'tempeh',
          'edamame',
          'soy sauce',
          'shoyu',
          'tamari',
          'textured vegetable protein',
          'tvp',
          'vegetable protein',
          'soy flour',
        ],
        nutrientsProvided: ['protein', 'calcium'],
      ),
    );

    await box.put(
      'wheat',
      AllergenModel(
        allergenId: 'wheat',
        name: 'Wheat',
        synonyms: [
          'wheat',
          'gluten',
          'flour',
          'wheat flour',
          'semolina',
          'spelt',
          'kamut',
          'durum',
          'bulgur',
          'farro',
          'wheat germ',
          'wheat starch',
          'wheat bran',
          'modified wheat starch',
          'triticale',
        ],
        nutrientsProvided: ['carbohydrates', 'fibre'],
      ),
    );

    await box.put(
      'eggs',
      AllergenModel(
        allergenId: 'eggs',
        name: 'Eggs',
        synonyms: [
          'eggs',
          'egg',
          'albumin',
          'globulin',
          'lysozyme',
          'mayonnaise',
          'meringue',
          'ovalbumin',
          'ovomucin',
          'egg white',
          'egg yolk',
          'dried egg',
          'egg solids',
          'egg lecithin',
          'livetin',
        ],
        nutrientsProvided: ['protein', 'vitamin D', 'choline'],
      ),
    );

    await box.put(
      'milk',
      AllergenModel(
        allergenId: 'milk',
        name: 'Milk',
        synonyms: [
          'milk',
          'casein',
          'whey',
          'lactalbumin',
          'lactoglobulin',
          'lactose',
          'skimmed milk',
          'butter',
          'cream',
          'ghee',
          'curds',
          'whey powder',
          'milk solids',
          'milk powder',
          'milk fat',
          'lactulose',
          'dairy',
        ],
        nutrientsProvided: ['calcium', 'vitamin D', 'protein'],
      ),
    );

    await box.put(
      'tree_nuts',
      AllergenModel(
        allergenId: 'tree_nuts',
        name: 'Tree Nuts',
        synonyms: [
          'almond',
          'cashew',
          'walnut',
          'pecan',
          'pistachio',
          'macadamia',
          'hazelnut',
          'brazil nut',
          'pine nut',
          'coconut',
          'chestnut',
          'praline',
          'marzipan',
          'gianduja',
          'nougat',
          'nut paste',
        ],
        nutrientsProvided: ['healthy fats', 'protein', 'vitamin E'],
      ),
    );

    await box.put(
      'sesame',
      AllergenModel(
        allergenId: 'sesame',
        name: 'Sesame',
        synonyms: [
          'sesame',
          'sesame oil',
          'sesame seed',
          'tahini',
          'til',
          'gingelly',
          'benne',
          'sesame flour',
          'sesame paste',
          'sesame butter',
          'gingelly oil',
        ],
        nutrientsProvided: ['healthy fats', 'calcium', 'iron'],
      ),
    );

    print('✅ Seeded ${box.length} allergens to Hive');

    print(box.values.toList());
  }
}
