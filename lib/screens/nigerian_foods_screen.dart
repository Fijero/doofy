import 'package:doofy/components/app_colors.dart';
import 'package:doofy/screens/scan_result_screen.dart';
import 'package:doofy/services/allergen_detection_service.dart';
import 'package:flutter/material.dart';

class _Dish {
  final String name;
  final String ingredients;
  const _Dish(this.name, this.ingredients);
}

const List<_Dish> _dishes = [
  _Dish(
    'Jollof rice',
    'Rice, tomatoes, red pepper, onions, vegetable oil, tomato paste, thyme, curry powder, bay leaf, salt, seasoning cubes',
  ),
  _Dish(
    'Fried rice',
    'Rice, mixed vegetables, carrots, green peas, liver, shrimp, vegetable oil, curry powder, thyme, seasoning cubes, salt',
  ),
  _Dish(
    'Egusi soup',
    'Egusi seeds, palm oil, crayfish, stockfish, assorted meat, pepper, onions, leafy vegetables, seasoning cubes, salt',
  ),
  _Dish(
    'Efo riro',
    'Spinach, palm oil, peppers, onions, locust beans, crayfish, stockfish, assorted meat, seasoning cubes, salt',
  ),
  _Dish(
    'Okra soup',
    'Okra, palm oil, crayfish, stockfish, assorted meat, pepper, onions, locust beans, seasoning cubes, salt',
  ),
  _Dish(
    'Ogbono soup',
    'Ogbono seeds, palm oil, crayfish, stockfish, assorted meat, pepper, onions, leafy vegetables, seasoning cubes, salt',
  ),
  _Dish(
    'Banga soup',
    'Palm fruit extract, catfish, crayfish, dried fish, beef, onions, pepper, banga spice, salt',
  ),
  _Dish(
    'Pepper soup',
    'Goat meat, fish, pepper soup spice, onions, scent leaf, utazi, chilli pepper, seasoning cubes, salt',
  ),
  _Dish(
    'Moi moi',
    'Beans, red pepper, onions, palm oil, crayfish, boiled eggs, fish, seasoning cubes, salt',
  ),
  _Dish('Akara', 'Beans, onions, pepper, salt, vegetable oil'),
  _Dish(
    'Suya',
    'Beef, groundnut powder, ginger, paprika, chilli pepper, garlic, onion powder, seasoning cubes, salt',
  ),
  _Dish(
    'Chin chin',
    'Wheat flour, eggs, butter, milk, sugar, baking powder, nutmeg, vegetable oil, salt',
  ),
  _Dish('Puff puff', 'Wheat flour, sugar, yeast, nutmeg, salt, vegetable oil'),
  _Dish(
    'Meat pie',
    'Wheat flour, butter, beef, potatoes, carrots, onions, egg, pepper, salt, seasoning cubes',
  ),
  _Dish('Boli and groundnut', 'Roasted plantain, groundnuts, salt, pepper'),
  _Dish('Pounded yam', 'Yam'),
  _Dish('Amala', 'Yam flour, water'),
  _Dish('Eba', 'Cassava garri, water'),
  _Dish(
    'Ofada rice and stew',
    'Ofada rice, palm oil, peppers, locust beans, assorted meat, onions, seasoning cubes, salt',
  ),
  _Dish(
    'Nkwobi',
    'Cow foot, palm oil, potash, utazi leaves, ground crayfish, ehuru, onions, seasoning cubes, salt',
  ),
];

class NigerianFoodsScreen extends StatefulWidget {
  const NigerianFoodsScreen({super.key});

  @override
  State<NigerianFoodsScreen> createState() => _NigerianFoodsScreenState();
}

class _NigerianFoodsScreenState extends State<NigerianFoodsScreen> {
  final _search = TextEditingController();
  final _service = AllergenDetectionService();
  String _query = '';
  bool _busy = false;

  List<_Dish> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _dishes;
    return _dishes.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _check(_Dish dish) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await _service.analyse(
        dish.ingredients,
        scanMethod: 'manual',
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Detection failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Nigerian foods'),
        backgroundColor: AppColors.greenBtn,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search local dishes...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Text(
                    'Typical recipes. Ingredients vary by cook or vendor, so '
                    'always confirm with whoever made the food.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No dishes found'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final dish = items[i];
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.greenBtn,
                        ),
                        title: Text(
                          dish.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          dish.ingredients,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _check(dish),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
