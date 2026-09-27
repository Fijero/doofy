import 'package:doofy/components/app_colors.dart';
import 'package:flutter/material.dart';

class Onboard extends StatelessWidget {
  const Onboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Text(
                    'Scan. Detect.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay Safe',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detect allergens in your food instantly',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Phone + floating icons area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.bgTop,
                      AppColors.greenLight.withValues(alpha: 0.3),
                      AppColors.greenLight.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Phone image centered
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 0),
                        child: Image.asset(
                          'assets/images/phone.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Wheat icon — top right
                    Positioned(
                      top: 20,
                      right: 24,
                      child: _IconBadge(
                        assetPath: 'assets/icons/wheat.png',
                        size: 44,
                        borderColor: Colors.amber,
                        bgColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),

                    // Peanut icon — top left
                    Positioned(
                      top: 20,
                      left: 24,
                      child: _IconBadge(
                        assetPath: 'assets/icons/peanut.png',
                        size: 44,
                        bgColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),

                    // Milk carton — mid right
                    Positioned(
                      top: 130,
                      right: 16,
                      child: _IconBadge(
                        assetPath: 'assets/icons/milk-carton.png',
                        size: 40,
                        bgColor: AppColors.greenLight.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Leaf — mid left
                    Positioned(
                      top: 130,
                      left: 16,
                      child: _IconBadge(
                        assetPath: 'assets/icons/leaf.png',
                        size: 40,
                        bgColor: AppColors.greenLight.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Scan button pinned above bottom
                    Positioned(
                      left: 40,
                      right: 40,
                      bottom: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/authWrapper');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenBtn,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.assetPath,
    required this.size,
    this.bgColor = Colors.white,
    this.borderColor,
    this.shape = BoxShape.rectangle,
  });

  final String assetPath;
  final double size;
  final Color bgColor;
  final Color? borderColor;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(12)
            : null,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(assetPath, width: size, height: size),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const waves = 5;
    final waveWidth = size.width / waves;
    const baseY = 40.0;
    const amplitude = 18.0;

    path.moveTo(0, baseY);
    for (int i = 0; i < waves; i++) {
      final startX = i * waveWidth;
      final endX = startX + waveWidth;
      final controlX = startX + waveWidth / 2;
      final controlY = i.isEven ? baseY - amplitude : baseY + amplitude;
      path.quadraticBezierTo(controlX, controlY, endX, baseY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
