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
  bool _isPrivate = false;

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

  int get _totalPrice => widget.slot.hostName != null ? 0 : widget.field.pricePerHour * _durationHours;

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
        isPrivate: _isPrivate,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking, field: widget.field, slot: widget.slot)));
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
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Konfirmasi Booking'),
        backgroundColor: AppColors.bgPage,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ticket Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _emoji(widget.field.category),
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.field.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.field.category} · ${widget.field.locationType}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 6),
                    InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal Sewa',
                      value: formatDate(widget.date),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Waktu Mulai',
                      value: '${widget.slot.startTime.substring(0, 5)} WIB',
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Estimasi Selesai',
                      value: '$_endTime WIB',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Form - Data Pemesan
              const StepLabel(number: '1', label: 'Data Pemesan'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_rounded, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp',
                        prefixIcon: Icon(Icons.phone_rounded, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor WA wajib diisi' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Selection Sewa - Durasi & Orang
              const StepLabel(number: '2', label: 'Konfigurasi Sewa'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    // Duration Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined, color: AppColors.primary, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Durasi Sewa',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: widget.slot.hostName != null
                                  ? null
                                  : (_durationHours > 1 ? () => setState(() => _durationHours--) : null),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: (widget.slot.hostName == null && _durationHours > 1) ? AppColors.primaryLight : AppColors.bgPage,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (widget.slot.hostName == null && _durationHours > 1)
                                        ? AppColors.primary.withAlpha((0.3 * 255).toInt())
                                        : AppColors.border,
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 20,
                                  color: (widget.slot.hostName == null && _durationHours > 1) ? AppColors.primary : AppColors.textHint,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '$_durationHours jam',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.slot.hostName != null
                                  ? null
                                  : () => setState(() => _durationHours++),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: widget.slot.hostName != null ? AppColors.bgPage : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: widget.slot.hostName != null
                                        ? AppColors.border
                                        : AppColors.primary.withAlpha((0.3 * 255).toInt()),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 20,
                                  color: widget.slot.hostName != null ? AppColors.textHint : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Persons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Jumlah Orang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _personCount > 1 ? () => setState(() => _personCount--) : null,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _personCount > 1 ? AppColors.primaryLight : AppColors.bgPage,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _personCount > 1
                                        ? AppColors.primary.withAlpha((0.3 * 255).toInt())
                                        : AppColors.border,
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 20,
                                  color: _personCount > 1 ? AppColors.primary : AppColors.textHint,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '$_personCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _personCount < widget.slot.remainingCapacity
                                  ? () => setState(() => _personCount++)
                                  : null,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _personCount < widget.slot.remainingCapacity
                                      ? AppColors.primaryLight
                                      : AppColors.bgPage,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _personCount < widget.slot.remainingCapacity
                                        ? AppColors.primary.withAlpha((0.3 * 255).toInt())
                                        : AppColors.border,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 20,
                                  color: _personCount < widget.slot.remainingCapacity
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary.withAlpha((0.8 * 255).toInt())),
                        const SizedBox(width: 6),
                        Text(
                          'Maksimal tersedia: ${widget.slot.remainingCapacity} orang untuk jam ini',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (widget.slot.hostName == null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Sewa Privat (Main Sendiri)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Kunci slot waktu agar orang lain tidak bisa bergabung',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        value: _isPrivate,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isPrivate = val),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Modern Invoice Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha((0.4 * 255).toInt()),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withAlpha((0.15 * 255).toInt())),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Biaya Sewa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga per Jam', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        Text(
                          formatPrice(widget.field.pricePerHour),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durasi Sewa', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        Text(
                          '$_durationHours jam',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah Orang', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        Text(
                          '$_personCount orang (tidak mempengaruhi harga)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          widget.slot.hostName != null ? 'Rp 0 (Gabung Slot)' : formatPrice(_totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              PrimaryButton(
                label: widget.slot.hostName != null ? 'Konfirmasi Bergabung' : 'Lanjut ke Pembayaran',
                icon: widget.slot.hostName != null ? Icons.group_add_rounded : Icons.arrow_forward_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[cat] ?? '🏟️';
  }
}
