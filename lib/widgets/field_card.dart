import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

const _emoji = {
  'Futsal': '⚽',
  'Badminton': '🏸',
  'Basket': '🏀',
  'Voli': '🏐',
  'Tenis Meja': '🏓',
  'Tenis': '🎾',
};

const _bgColor = {
  'Futsal': Color(0xFFEBF9F0),
  'Badminton': Color(0xFFFEF3C7),
  'Basket': Color(0xFFDBEAFE),
  'Voli': Color(0xFFFCE7F3),
  'Tenis Meja': Color(0xFFEDE9FE),
  'Tenis': Color(0xFFD1FAE5),
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
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Fixed height 80px
              Container(
                height: 80,
                width: double.infinity,
                color: bg,
                child: Stack(
                  children: [
                    Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 36)),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: field.isAvailable
                              ? AppColors.successBg
                              : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: field.isAvailable
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          field.isAvailable ? 'Tersedia' : 'Penuh',
                          style: TextStyle(
                            color: field.isAvailable
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: 6,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content - Flexible
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nama
                      Text(
                        field.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      // Type
                      Text(
                        '${field.locationType} · ${field.category}',
                        style: const TextStyle(
                          fontSize: 7.5,
                          color: AppColors.textSecondary,
                          height: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 9,
                            color: Color(0xFFF6AD55),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${field.rating}',
                            style: const TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '(${field.reviewCount})',
                            style: const TextStyle(
                              fontSize: 6.5,
                              color: AppColors.textHint,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer - Fixed height 36px
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PriceBadge(price: field.pricePerHour),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: field.isAvailable ? onTap : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Lihat'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
