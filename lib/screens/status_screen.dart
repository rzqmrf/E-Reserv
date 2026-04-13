import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'field_detail_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await BookingService.getMyBookings();
      if (mounted) setState(() { _bookings = b; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Booking'), leading: const BackButton()),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _bookings.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _bookings.length,
                    itemBuilder: (_, i) => _buildCard(_bookings[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88, height: 88,
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textHint),
          ),
          const SizedBox(height: 20),
          const Text('Belum Ada Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Riwayat booking Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ]),
      ),
    );
  }

  Widget _buildCard(Booking b) {
    final cfg = _statusCfg(b.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(b.bookingCode,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const Spacer(),
            StatusChip(label: cfg.$1, color: cfg.$2, bgColor: cfg.$3, icon: cfg.$4),
          ]),
          const SizedBox(height: 10),
          Text(b.field?.name ?? 'Lapangan',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),

          // Progress stepper
          Row(children: [
            _stepIcon(Icons.receipt_long_outlined, 'Booking', true),
            _stepLine(b.status != BookingStatus.pending),
            _stepIcon(Icons.payments_outlined, 'Bayar', b.status != BookingStatus.pending),
            _stepLine(b.status == BookingStatus.approved),
            _stepIcon(
              b.status == BookingStatus.approved ? Icons.check_circle_outline_rounded
                  : b.status == BookingStatus.rejected ? Icons.cancel_outlined
                  : Icons.hourglass_empty_rounded,
              b.status == BookingStatus.approved ? 'Disetujui'
                  : b.status == BookingStatus.rejected ? 'Ditolak' : 'Menunggu',
              b.status != BookingStatus.pending,
              color: cfg.$2,
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          _infoTile(Icons.calendar_today_outlined, b.formattedDate),
          _infoTile(Icons.schedule_outlined, '${b.startTime} – ${b.endTime}'),
          _infoTile(Icons.people_outline_rounded, '${b.personCount} orang'),
          _infoTile(Icons.payments_outlined, formatPrice(b.totalPrice), valueColor: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _stepIcon(IconData icon, String label, bool active, {Color? color}) {
    final c = active ? (color ?? AppColors.primary) : AppColors.textHint;
    return Column(children: [
      Icon(icon, size: 20, color: c),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, color: c, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }

  Widget _stepLine(bool active) {
    return Expanded(child: Container(
      height: 1.5, margin: const EdgeInsets.fromLTRB(6, 0, 6, 14),
      color: active ? AppColors.primary : AppColors.border,
    ));
  }

  Widget _infoTile(IconData icon, String text, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(
          fontSize: 13,
          color: valueColor ?? AppColors.textSecondary,
          fontWeight: valueColor != null ? FontWeight.w700 : FontWeight.w400,
        ))),
      ]),
    );
  }

  (String, Color, Color, IconData) _statusCfg(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return ('Menunggu', AppColors.warning, AppColors.warningBg, Icons.hourglass_empty_rounded);
      case BookingStatus.approved:
        return ('Berhasil', AppColors.success, AppColors.successBg, Icons.check_circle_outline_rounded);
      case BookingStatus.rejected:
        return ('Ditolak', AppColors.error, AppColors.errorBg, Icons.cancel_outlined);
    }
  }
}
