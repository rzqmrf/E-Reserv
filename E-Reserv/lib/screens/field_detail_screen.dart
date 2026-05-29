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
            const Text('Pilih Tanggal:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).toInt())),
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

        // Title Instruction
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Pilih Jam Mulai:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
        ),

        // Slots Grid (Showing all slots, with 'Penuh' indicator for full ones)
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _slots.isEmpty
                  ? const Center(child: Text('Tidak ada jadwal tersedia', style: TextStyle(color: AppColors.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: _slots.length,
                      itemBuilder: (ctx, i) {
                        final slot = _slots[i];
                        final isSelected = _selectedSlot?.id == slot.id;
                        final isFull = !slot.isAvailable || slot.isFull;

                        Color bgColor;
                        Color borderColor;
                        Color textColor;

                        if (isSelected) {
                          bgColor = AppColors.primary;
                          borderColor = AppColors.primary;
                          textColor = AppColors.white;
                        } else if (isFull) {
                          bgColor = AppColors.errorBg;
                          borderColor = AppColors.error.withAlpha((0.3 * 255).toInt());
                          textColor = AppColors.error;
                        } else {
                          bgColor = AppColors.primaryLight;
                          borderColor = AppColors.primary.withAlpha((0.2 * 255).toInt());
                          textColor = AppColors.primary;
                        }

                        return GestureDetector(
                          onTap: isFull ? null : () => setState(() => _selectedSlot = isSelected ? null : slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isFull 
                                    ? '${slot.startTime.substring(0, 5)} (Penuh)'
                                    : slot.startTime.substring(0, 5),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                    Text('Jam Mulai: ${_selectedSlot!.startTime.substring(0, 5)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Kapasitas: ${_selectedSlot!.remainingCapacity} orang',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  Text(formatPrice(field.pricePerHour),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ]),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Booking Lapangan',
                  icon: Icons.arrow_forward_rounded,
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

  String _fieldEmoji(String category) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[category] ?? '🏟️';
  }
}
