import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

const _emoji = {
  'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀',
  'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾',
};

const _bgColor = {
  'Futsal': Color(0xFFEBF9F0), 'Badminton': Color(0xFFFEF3C7),
  'Basket': Color(0xFFDBEAFE), 'Voli': Color(0xFFFCE7F3),
  'Tenis Meja': Color(0xFFEDE9FE), 'Tenis': Color(0xFFD1FAE5),
};

class FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onTap;

  const FieldCard({super.key, required this.field, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final emoji = _emoji[field.category] ?? '🏟️';
    final bg = _bgColor[field.category] ?? AppColors.primaryLight;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 95, width: double.infinity, color: bg,
              child: Stack(children: [
                Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: field.isAvailable ? AppColors.successBg : AppColors.warningBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: field.isAvailable ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Text(
                      field.isAvailable ? 'Tersedia' : 'Penuh',
                      style: TextStyle(color: field.isAvailable ? AppColors.success : AppColors.warning, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(field.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${field.category} · ${field.locationType}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                // Kapasitas
                Row(children: [
                  const Icon(Icons.people_outline_rounded, size: 12, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text('Kapasitas ${field.capacity} orang',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF6AD55)),
                  const SizedBox(width: 2),
                  Text('${field.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Text(' (${field.reviewCount})', style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ]),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: PriceBadge(price: field.pricePerHour)),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: field.isAvailable ? onTap : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Lihat'),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
