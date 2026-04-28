import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'booking_screen.dart';

class FieldDetailScreen extends StatefulWidget {
  final Field field;
  const FieldDetailScreen({super.key, required this.field});
  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Slot> _slots = [];
  bool _loading = true;
  Slot? _selectedSlot;

  @override
  void initState() { super.initState(); _loadSlots(); }

  Future<void> _loadSlots() async {
    setState(() { _loading = true; _selectedSlot = null; });
    try {
      final slots = await SlotService.getByFieldAndDate(widget.field.id, _selectedDate);
      if (mounted) setState(() { _slots = slots; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime d) {
    const days = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    return Scaffold(
      appBar: AppBar(title: Text(field.name), leading: const BackButton()),
      body: Column(children: [
        // Field info card
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(_fieldEmoji(field.category), style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(field.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('${field.category} · ${field.locationType}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Kapasitas ${field.capacity} orang',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const SizedBox(width: 12),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF6AD55)),
                const SizedBox(width: 3),
                Text('${field.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(formatPrice(field.pricePerHour),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const Text('/ jam', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        const Divider(height: 1),

        // Date picker row
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Pilih Tanggal:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_fmtDate(_selectedDate),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                ]),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),

        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _legendItem(AppColors.successBg, AppColors.success, 'Tersedia'),
            const SizedBox(width: 16),
            _legendItem(AppColors.errorBg, AppColors.error, 'Penuh'),
            const SizedBox(width: 16),
            _legendItem(AppColors.primaryLight, AppColors.primary, 'Dipilih'),
          ]),
        ),

        // Slots
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _slots.isEmpty
                  ? const Center(child: Text('Tidak ada jadwal tersedia', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: _slots.length,
                      itemBuilder: (ctx, i) => _buildSlotTile(_slots[i]),
                    ),
        ),
      ]),

      // Bottom booking button
      bottomNavigationBar: _selectedSlot != null
          ? Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_selectedSlot!.startTime} – ${_selectedSlot!.endTime}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Sisa ${_selectedSlot!.remainingCapacity} dari ${_selectedSlot!.capacity} orang',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  Text(formatPrice(field.pricePerHour),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ]),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Booking Slot Ini',
                  icon: Icons.calendar_month_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookingScreen(field: field, slot: _selectedSlot!, date: _selectedDate)),
                  ),
                ),
              ]),
            )
          : null,
    );
  }

  Widget _buildSlotTile(Slot slot) {
    final isSelected = _selectedSlot?.id == slot.id;
    final isFull = slot.isFull;
    final pct = slot.capacity > 0 ? slot.bookedCount / slot.capacity : 0.0;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      bgColor = AppColors.primaryLight;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else if (isFull) {
      bgColor = AppColors.errorBg;
      borderColor = AppColors.error.withOpacity(0.3);
      textColor = AppColors.error;
    } else {
      bgColor = AppColors.successBg;
      borderColor = AppColors.success.withOpacity(0.3);
      textColor = AppColors.success;
    }

    return GestureDetector(
      onTap: isFull ? null : () => setState(() => _selectedSlot = isSelected ? null : slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(children: [
          // Waktu
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${slot.startTime} – ${slot.endTime}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 2),
            Text(isFull ? 'Penuh' : 'Tersedia',
                style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
          ]),
          const Spacer(),
          // Kapasitas
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              Icon(Icons.people_outline_rounded, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text('${slot.bookedCount}/${slot.capacity} orang',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            ]),
            const SizedBox(height: 6),
            // Progress bar kapasitas
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFull ? AppColors.error : pct > 0.7 ? AppColors.warning : AppColors.success,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text('Sisa ${slot.remainingCapacity} slot',
                style: TextStyle(fontSize: 10, color: textColor)),
          ]),
          if (isSelected) ...[
            const SizedBox(width: 10),
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ]),
      ),
    );
  }

  Widget _legendItem(Color bg, Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3), border: Border.all(color: color.withOpacity(0.4)))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  String _fieldEmoji(String category) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[category] ?? '🏟️';
  }
}
