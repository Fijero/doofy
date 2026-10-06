import 'package:doofy/components/app_colors.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/services/allergen_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class _Swap {
  final String name;
  final String useFor;
  final String note;
  final List<String> contains; // allergen ids this swap itself contains
  const _Swap(this.name, this.useFor, this.note, {this.contains = const []});
}

const Map<String, String> _emojis = {
  'milk': '🥛',
  'eggs': '🥚',
  'peanuts': '🥜',
  'tree_nuts': '🌰',
  'wheat': '🌾',
  'soy': '🫘',
  'fish': '🐟',
  'shellfish': '🦐',
  'sesame': '🌱',
};

const Map<String, List<_Swap>> _swaps = {
  'milk': [
    _Swap(
      'Tigernut milk (kunun aya)',
      'Milk in drinks, pap, cereal',
      'Naturally dairy-free. Check that no milk was added.',
    ),
    _Swap(
      'Coconut milk',
      'Milk in cooking and baking',
      'Works well in soups, rice and puff puff batter.',
    ),
    _Swap(
      'Soy milk',
      'Milk in drinks and baking',
      'Unsweetened versions are best.',
      contains: ['soy'],
    ),
    _Swap(
      'Vegetable oil or palm oil',
      'Butter in frying and baking',
      'Avoid margarine unless the label says dairy-free.',
    ),
  ],
  'eggs': [
    _Swap(
      'Ground flaxseed and water',
      'One egg in baking',
      'Mix 1 tbsp ground flaxseed with 3 tbsp water and rest 5 minutes.',
    ),
    _Swap(
      'Ripe mashed banana',
      'Egg in cakes and chin chin',
      'About half a banana per egg. Adds a little sweetness.',
    ),
    _Swap(
      'Leave it out',
      'Boiled egg in moi moi or meat pie',
      'Safe to omit. The dish still holds together.',
    ),
  ],
  'peanuts': [
    _Swap(
      'Sunflower seed butter',
      'Groundnut paste or butter',
      'Closest texture to groundnut butter.',
    ),
    _Swap(
      'Roasted pumpkin seeds (ground)',
      'Groundnut powder in suya spice',
      'Mix with ginger, paprika, pepper and salt.',
    ),
    _Swap(
      'Palm oil or vegetable oil',
      'Groundnut oil for frying',
      'Check the bottle is not a blend containing groundnut oil.',
    ),
    _Swap(
      'Cashew or almond butter',
      'Groundnut paste',
      'Only if tree nuts are safe for you.',
      contains: ['tree_nuts'],
    ),
  ],
  'tree_nuts': [
    _Swap(
      'Sunflower or pumpkin seeds',
      'Nuts in snacks, baking and toppings',
      'Buy plain seeds from a source that does not also pack nuts.',
    ),
    _Swap(
      'Sunflower seed butter',
      'Nut butters',
      'Spreads and bakes like nut butter.',
    ),
    _Swap(
      'Groundnuts',
      'Cashew or almond in snacks',
      'Peanuts are legumes, but some people with tree nut allergy react to them too.',
      contains: ['peanuts'],
    ),
  ],
  'wheat': [
    _Swap(
      'Cassava flour',
      'Wheat flour in baking and batter',
      'Use roughly the same amount.',
    ),
    _Swap(
      'Rice flour',
      'Puff puff, pancakes, frying batter',
      'Gives a lighter, crispier result.',
    ),
    _Swap(
      'Cornflour (corn starch)',
      'Thickening stews and sauces',
      'Mix with cold water first.',
    ),
    _Swap(
      'Eba, pounded yam or amala',
      'Bread or noodles as the carb side',
      'Naturally wheat-free. Check packaged flours for wheat blends.',
    ),
  ],
  'soy': [
    _Swap(
      'Iru (locust beans)',
      'Soy sauce or seasoning for savoury flavour',
      'Fermented locust bean, not related to soybeans.',
    ),
    _Swap(
      'Fresh herbs and spices',
      'Seasoning cubes with hydrolysed soy protein',
      'Thyme, curry, ginger, garlic and onion. Many cubes and noodle flavour packs contain soy, so check labels.',
    ),
    _Swap('Coconut milk', 'Soy milk', 'Good in drinks and cooking.'),
    _Swap(
      'Beans or meat',
      'Soy protein',
      'Beans are a different legume. Ask your doctor if unsure.',
    ),
  ],
  'fish': [
    _Swap(
      'Chicken, beef, goat or turkey',
      'Stockfish and dried fish in soups',
      'Season well so the soup does not taste flat.',
    ),
    _Swap(
      'Iru (locust beans)',
      'Fish flavour in stews and soups',
      'Adds a deep savoury taste.',
    ),
    _Swap(
      'Dried mushrooms',
      'Smoky depth in soups',
      'Soak, then blend or chop.',
    ),
  ],
  'shellfish': [
    _Swap(
      'Iru (locust beans)',
      'Crayfish in soups and stews',
      'Adds depth. Use a small amount, it is strong.',
    ),
    _Swap(
      'Ground dried mushrooms',
      'Crayfish powder',
      'Gives a similar umami taste.',
    ),
    _Swap(
      'Stockfish or smoked fish',
      'Crayfish and shrimp',
      'Only if fish is safe for you.',
      contains: ['fish'],
    ),
    _Swap(
      'Chicken or turkey',
      'Shrimp in fried rice',
      'Dice small so it cooks evenly.',
    ),
  ],
  'sesame': [
    _Swap('Palm oil or vegetable oil', 'Sesame oil', 'Use a neutral oil.'),
    _Swap(
      'Sunflower seed butter',
      'Tahini',
      'Thin with a little water or oil.',
    ),
    _Swap(
      'Egusi or ogbono',
      'Benniseed as a soup thickener',
      'Melon seeds and ogbono are not sesame.',
    ),
    _Swap(
      'Pumpkin seeds',
      'Sesame seeds on bread or snacks',
      'Use plain, unflavoured seeds.',
    ),
  ],
};

class AlternativesScreen extends StatelessWidget {
  final ScanResultData result;
  const AlternativesScreen({super.key, required this.result});

  Set<String> get _userAllergens {
    final profile = Hive.box<AllergyProfile>('profile').get('currentUser');
    return Set<String>.from(profile?.selectedAllergens ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final user = _userAllergens;

    // one section per allergen, even if it was triggered by several ingredients
    final seen = <String>{};
    final detected = result.detectedAllergens
        .where((d) => seen.add(d.allergenId))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Safe alternatives'),
        backgroundColor: AppColors.greenBtn,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          for (final d in detected) ...[
            _AllergenSwaps(
              emoji: _emojis[d.allergenId] ?? '⚠️',
              name: d.allergenName,
              triggeredBy: d.triggeredBy,
              swaps: (_swaps[d.allergenId] ?? const <_Swap>[])
                  .where((s) => !s.contains.any(user.contains))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Swaps already exclude your other allergens, but always read '
              'labels and check for cross-contamination. For serious '
              'allergies, confirm with your doctor or a dietitian.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF854F0B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergenSwaps extends StatelessWidget {
  final String emoji;
  final String name;
  final String triggeredBy;
  final List<_Swap> swaps;

  const _AllergenSwaps({
    required this.emoji,
    required this.name,
    required this.triggeredBy,
    required this.swaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instead of $name',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Found in: $triggeredBy',
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
          const SizedBox(height: 12),
          if (swaps.isEmpty)
            const Text(
              'No safe swaps in our list for your profile. '
              'Ask a dietitian for options.',
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            )
          else
            ...swaps.map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF3B6D13),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use for: ${s.useFor}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3B6D13),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.note,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
