import 'package:doofy/screens/allergy_setup.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;

  const TopBar({
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (showBack) const SizedBox(height: 10),
          // Shield icon + title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Step progress row
class ProgressRow extends StatelessWidget {
  final int step;
  final int total;
  const ProgressRow({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(total, (i) {
          final active = i < step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.greenBtn
                    : AppColors.greenLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Allergen card (selection screen)
class AllergenCard extends StatelessWidget {
  final String name;
  final String emoji;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const AllergenCard({
    required this.name,
    required this.emoji,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.greenLight : const Color(0xFFDDDDDD),
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // emoji icon
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 5),
            // allergen name
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            // subtitle
            Expanded(
              child: Text(
                sub,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: selected ? Colors.white70 : AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.greenLight
                    : const Color(0xFFEEEEEE),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Severity card (severity screen)
class SeverityCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String current;
  final ValueChanged<String> onChanged;

  const SeverityCard({
    required this.emoji,
    required this.name,
    required this.current,
    required this.onChanged,
  });

  static const _severeColor = Color(0xFFA32D2D);
  static const _severeBg = Color(0xFFFCEBEB);
  static const _intolColor = Color(0xFF854F0B);
  static const _intolBg = Color(0xFFFAEEDA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: current == 'severe'
              ? _severeColor.withOpacity(0.3)
              : _intolColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // emoji
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          // name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          // severity toggles
          Row(
            children: [
              SeverityBtn(
                label: 'Severe',
                selected: current == 'severe',
                color: _severeColor,
                bg: _severeBg,
                onTap: () => onChanged('severe'),
              ),
              const SizedBox(width: 6),
              SeverityBtn(
                label: 'Intolerant',
                selected: current == 'intolerant',
                color: _intolColor,
                bg: _intolBg,
                onTap: () => onChanged('intolerant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Severity toggle button
class SeverityBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const SeverityBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : const Color(0xFFCCCCCC),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// Legend pill (severity screen)
class LegendPill extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;
  final Color bg;

  const LegendPill({
    required this.label,
    required this.desc,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              desc,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom action button + note
class BottomAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String note;
  final bool noteIsSuccess;

  const BottomAction({
    required this.label,
    required this.onPressed,
    required this.note,
    required this.noteIsSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // note text
          if (note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    noteIsSuccess
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 14,
                    color: noteIsSuccess
                        ? AppColors.greenBtn
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: noteIsSuccess
                          ? AppColors.greenBtn
                          : AppColors.textMuted,
                      fontWeight: noteIsSuccess
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          // main button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenBtn,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
