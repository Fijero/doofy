import 'package:flutter/material.dart';
import 'package:doofy/components/app_colors.dart';
import 'package:doofy/services/allergen_detection_service.dart';
import 'package:doofy/screens/scan_result_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  FILE 2: lib/screens/manual_input_screen.dart
// ═══════════════════════════════════════════════════════════════

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _controller = TextEditingController();
  final _service = AllergenDetectionService();
  bool _isAnalysing = false;

  // ── example Nigerian foods for quick test ──
  static const List<Map<String, String>> _examples = [
    {
      'label': 'Indomie Noodles',
      'text':
          'Wheat flour, palm oil, salt, sugar, monosodium '
          'glutamate, hydrolysed soy protein, chicken '
          'flavour, caramel colour, turmeric',
    },
    {
      'label': 'Chin Chin',
      'text':
          'Wheat flour, eggs, butter, milk, sugar, '
          'baking powder, groundnut oil, salt',
    },
    {
      'label': 'Egusi Soup',
      'text':
          'Egusi seeds, palm oil, crayfish, stockfish, '
          'assorted meat, pepper, onions, maggi seasoning '
          'cubes, salt, leafy vegetables',
    },
    {
      'label': 'Suya',
      'text':
          'Beef, groundnut powder, ginger, paprika, '
          'chilli pepper, garlic, onion powder, salt',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyse() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some ingredients first'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isAnalysing = true);

    try {
      final result = await _service.analyse(text, scanMethod: 'manual');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ScanResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detection failed: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalysing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── header ───────────────────────────
            _Header(),

            // ── scrollable content ───────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // instruction card
                    _InstructionCard(),

                    const SizedBox(height: 16),

                    // text input field
                    _InputCard(controller: _controller),

                    const SizedBox(height: 16),

                    // quick examples
                    _ExamplesSection(
                      examples: _examples,
                      onSelect: (text) {
                        _controller.text = text;
                        // scroll to top implicitly
                        // by setting text
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── floating analyse button ───────────────
      floatingActionButton: _AnalyseButton(
        isAnalysing: _isAnalysing,
        onPressed: _analyse,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.greenBtn,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter ingredients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Type or paste an ingredient list',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  INSTRUCTION CARD
// ─────────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF90CAF9), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF185FA5),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Type or paste the ingredient list '
              'from a food label, menu, or ask '
              'the vendor what is in the food.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF185FA5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  INPUT CARD
// ─────────────────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final TextEditingController controller;
  const _InputCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        children: [
          // label row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                // clear button
                GestureDetector(
                  onTap: () => controller.clear(),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                ),
              ],
            ),
          ),

          // text field
          TextField(
            controller: controller,
            maxLines: 8,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A2E),
              height: 1.6,
            ),
            decoration: const InputDecoration(
              hintText:
                  'e.g. wheat flour, palm oil, salt, '
                  'sugar, crayfish, stockfish, maggi...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: Color(0xFFBBBBBB),
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(14, 10, 14, 14),
            ),
          ),

          // character count
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, __, ___) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.text.length} characters',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EXAMPLES SECTION
// ─────────────────────────────────────────────────────────────
class _ExamplesSection extends StatelessWidget {
  final List<Map<String, String>> examples;
  final ValueChanged<String> onSelect;

  const _ExamplesSection({required this.examples, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRY AN EXAMPLE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF888888),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ...examples.map(
          (example) => GestureDetector(
            onTap: () => onSelect(example['text']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.greenBtn,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          example['label']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          example['text']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFCCCCCC),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ANALYSE BUTTON
// ─────────────────────────────────────────────────────────────
class _AnalyseButton extends StatelessWidget {
  final bool isAnalysing;
  final VoidCallback onPressed;

  const _AnalyseButton({required this.isAnalysing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isAnalysing ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenBtn,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.greenBtn.withOpacity(0.6),
            elevation: 4,
            shadowColor: AppColors.greenBtn.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isAnalysing
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Analysing...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Check for allergens',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
