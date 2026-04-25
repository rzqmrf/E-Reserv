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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section (Made smaller)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: field.imageUrl != null && field.imageUrl!.isNotEmpty
                    ? Image.network(
                        field.imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          width: double.infinity,
                          color: bg,
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: bg,
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              // Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      field.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: field.isAvailable
                          ? const Color(0xFFE8FDF5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      field.isAvailable ? 'Tersedia' : 'Penuh',
                      style: TextStyle(
                        color: field.isAvailable
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${field.locationType} - ${field.category}',
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              // Compact Info
              Row(
                children: [
                  const Icon(Icons.people_outline_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${field.capacity} orang',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  if (field.rating > 0) ...[
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      '${field.rating}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatPrice(field.pricePerHour),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                          const TextSpan(
                            text: '/jam',
                            style: TextStyle(
                                fontSize: 9, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lihat',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
