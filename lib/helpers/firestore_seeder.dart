import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedAllergens() async {
    final allergens = [
      {
        'allergenId': 'fish',
        'name': 'Fish',
        'synonyms': [
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
        'nutrientsProvided': ['protein', 'omega-3', 'iodine'],
      },
      {
        'allergenId': 'shellfish',
        'name': 'Shellfish',
        'synonyms': [
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
        'nutrientsProvided': ['protein', 'zinc', 'omega-3'],
      },
      {
        'allergenId': 'peanuts',
        'name': 'Peanuts',
        'synonyms': [
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
          'suya',
        ],
        'nutrientsProvided': ['protein', 'healthy fats'],
      },
      {
        'allergenId': 'soy',
        'name': 'Soy',
        'synonyms': [
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
        'nutrientsProvided': ['protein', 'calcium'],
      },
      {
        'allergenId': 'wheat',
        'name': 'Wheat',
        'synonyms': [
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
        'nutrientsProvided': ['carbohydrates', 'fibre'],
      },
      {
        'allergenId': 'eggs',
        'name': 'Eggs',
        'synonyms': [
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
        'nutrientsProvided': ['protein', 'vitamin D', 'choline'],
      },
      {
        'allergenId': 'milk',
        'name': 'Milk',
        'synonyms': [
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
        'nutrientsProvided': ['calcium', 'vitamin D', 'protein'],
      },
      {
        'allergenId': 'tree_nuts',
        'name': 'Tree Nuts',
        'synonyms': [
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
        'nutrientsProvided': ['healthy fats', 'protein', 'vitamin E'],
      },
      {
        'allergenId': 'sesame',
        'name': 'Sesame',
        'synonyms': [
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
        'nutrientsProvided': ['healthy fats', 'calcium', 'iron'],
      },
    ];

    print('🚀 Starting Firestore allergen seed...');

    for (final allergen in allergens) {
      final id = allergen['allergenId'] as String;
      try {
        await _db.collection('allergens').doc(id).set(allergen);
        print('Written: $id');
      } catch (e) {
        print('Failed to write $id: $e');
      }
    }

    // db config version so wgen to 
    try {
      await _db.collection('app_config').doc('version').set({
        'databaseVersion': 1,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print('Written: app_config/version');
    } catch (e) {
      print(' Failed to write app_config: $e');
    }

    print('Firestore seed complete — 9 allergens written');
  }
}
