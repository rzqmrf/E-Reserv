import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Field field;
  final Slot slot;
  final DateTime date;
  const BookingScreen({super.key, required this.field, required this.slot, required this.date});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _durationHours = 1;
  int _personCount = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  int get _totalPrice => widget.field.pricePerHour * _durationHours * _personCount;

  String get _endTime {
    final parts = widget.slot.startTime.split(':');
    final startHour = int.tryParse(parts.first) ?? 0;
    final endHour = startHour + _durationHours;
    return '${endHour.toString().padLeft(2, '0')}:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final booking = await BookingService.create(
        fieldId: widget.field.id,
        slotId: widget.slot.id,
        date: widget.date,
        startTime: widget.slot.startTime,
        endTime: _endTime,
        durationHours: _durationHours,
        totalPrice: _totalPrice,
        personCount: _personCount,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking, field: widget.field)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Booking'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Detail booking card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(_emoji(widget.field.category), style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.field.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('${widget.field.category} · ${widget.field.locationType}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                  ]),
                  const Divider(height: 24),
                  InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: formatDate(widget.date)),
                  const Divider(height: 1),
                  InfoRow(icon: Icons.schedule_outlined, label: 'Waktu', value: '${widget.slot.startTime} – $_endTime ($_durationHours jam)'),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.people_outline_rounded,
                    label: 'Kapasitas Lapangan',
                    value: '${widget.field.capacity} orang',
                    valueColor: AppColors.success,
                  ),
                  const Divider(height: 1),
                  InfoRow(icon: Icons.payments_outlined, label: 'Total Harga', value: formatPrice(_totalPrice), valueColor: AppColors.primary),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            const StepLabel(number: '1', label: 'Data Pemesan'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textHint),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined, size: 20, color: AppColors.textHint),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor WA wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            const StepLabel(number: '2', label: 'Durasi Sewa'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  const Text('Durasi Sewa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  // Counter
                  Row(children: [
                    GestureDetector(
                      onTap: _durationHours > 1 ? () => setState(() => _durationHours--) : null,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _durationHours > 1 ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _durationHours > 1 ? AppColors.primary.withAlpha((0.3 * 255).toInt()) : AppColors.border),
                        ),
                        child: Icon(Icons.remove_rounded, size: 18,
                            color: _durationHours > 1 ? AppColors.primary : AppColors.textHint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_durationHours jam', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _durationHours++),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).toInt())),
                        ),
                        child: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            const StepLabel(number: '3', label: 'Jumlah Orang'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  const Text('Jumlah Orang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  // Counter
                  Row(children: [
                    GestureDetector(
                      onTap: _personCount > 1 ? () => setState(() => _personCount--) : null,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _personCount > 1 ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _personCount > 1 ? AppColors.primary.withAlpha((0.3 * 255).toInt()) : AppColors.border),
                        ),
                        child: Icon(Icons.remove_rounded, size: 18,
                            color: _personCount > 1 ? AppColors.primary : AppColors.textHint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_personCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: _personCount < widget.slot.remainingCapacity
                          ? () => setState(() => _personCount++)
                          : null,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _personCount < widget.slot.remainingCapacity ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _personCount < widget.slot.remainingCapacity
                                  ? AppColors.primary.withAlpha((0.3 * 255).toInt())
                                  : AppColors.border),
                        ),
                        child: Icon(Icons.add_rounded, size: 18,
                            color: _personCount < widget.slot.remainingCapacity ? AppColors.primary : AppColors.textHint),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Text('Maksimal ${widget.slot.remainingCapacity} orang tersisa untuk slot ini',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Biaya',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Harga per Jam', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(formatPrice(widget.field.pricePerHour), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Durasi Sewa', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('$_durationHours jam', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah Orang', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('$_personCount orang', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        formatPrice(_totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Lanjut ke Pembayaran',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[cat] ?? '🏟️';
  }
}
