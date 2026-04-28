import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final Field field;
  const PaymentScreen({super.key, required this.booking, required this.field});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _pay() async {
    setState(() => _isLoading = true);
    try {
      // Dapat snap token dari Laravel → Midtrans
      await PaymentService.getSnapToken(widget.booking.id, widget.booking.totalPrice);
      // TODO: buka Midtrans Snap UI dengan snap_token
      // Sekarang simulasi sukses
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pembayaran berhasil! Menunggu konfirmasi.'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StatusScreen()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Ringkasan
          const Text('Ringkasan Booking',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(_emoji(widget.field.category), style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.field.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(b.bookingCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
                    ),
                  ]),
                ),
                const Divider(height: 1),
                InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: b.formattedDate),
                const Divider(height: 1),
                InfoRow(icon: Icons.schedule_outlined, label: 'Waktu', value: '${b.startTime} – ${b.endTime}'),
                const Divider(height: 1),
                InfoRow(icon: Icons.people_outline_rounded, label: 'Jumlah Orang', value: '${b.personCount} orang'),
                const Divider(height: 1),
                InfoRow(icon: Icons.payments_outlined, label: 'Total', value: formatPrice(b.totalPrice), valueColor: AppColors.primary),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Midtrans info
          const Text('Metode Pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFEEF9F4), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('💳', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Midtrans Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('Transfer Bank · E-Wallet · QRIS · Kartu Kredit',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Anda akan diarahkan ke halaman pembayaran Midtrans yang aman.',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              )),
            ]),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Bayar Sekarang',
            icon: Icons.payment_rounded,
            isLoading: _isLoading,
            onPressed: _pay,
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[cat] ?? '🏟️';
  }
}
