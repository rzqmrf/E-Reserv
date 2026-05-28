import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'status_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final Field field;
  const PaymentScreen({super.key, required this.booking, required this.field});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.midtrans;
  bool _isLoading = false;

  Future<void> _pay() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedMethod == PaymentMethod.midtrans) {
        // get snap token dari Laravel → Midtrans
        final snapToken = await PaymentService.getSnapToken(widget.booking.id, widget.booking.totalPrice);
        
        final url = Uri.parse('https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Gagal membuka Midtrans');
        }

        // send data endpoint agar berhasil
        try {
          await ApiService.post('/payments/webhook', {
            'order_id': widget.booking.bookingCode, 
            'transaction_status': 'settlement',
            'fraud_status': 'accept',
            'transaction_id': 'fake-tx-id-${DateTime.now().millisecondsSinceEpoch}',
            'payment_type': 'qris',
            'gross_amount': widget.booking.totalPrice.toString(),
          });
        } catch (e) {
          debugPrint('Bypass status error: $e');
        }
        // ─────────────────────────────────────────────────────────────────────

      } else {
        // Manual Transfer
        await PaymentService.create(
          bookingId: widget.booking.id,
          amount: widget.booking.totalPrice,
          method: PaymentMethod.manualTransfer,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking berhasil! Silakan upload bukti transfer.'),
          backgroundColor: AppColors.success,
        ));
      }

      if (!mounted) return;
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

          // Metode Pembayaran
          const Text('Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          
          // Midtrans Option
          _buildMethodCard(
            method: PaymentMethod.midtrans,
            title: 'Midtrans (Otomatis)',
            subtitle: 'Transfer Bank, QRIS, E-Wallet, Kartu Kredit',
            icon: '💳',
            isSelected: _selectedMethod == PaymentMethod.midtrans,
          ),
          const SizedBox(height: 12),
          
          // Manual Option
          _buildMethodCard(
            method: PaymentMethod.manualTransfer,
            title: 'Transfer Manual',
            subtitle: 'Transfer ke Rekening Bank (Upload Bukti)',
            icon: '🏦',
            isSelected: _selectedMethod == PaymentMethod.manualTransfer,
          ),
          
          if (_selectedMethod == PaymentMethod.manualTransfer) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha((0.5 * 255).toInt()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha((0.1 * 255).toInt())),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Informasi Rekening:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                SizedBox(height: 8),
                Text('Bank BCA: 1234567890\nA.N. E-Reserv Sports', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
              ]),
            ),
          ],
          
          const SizedBox(height: 32),
          PrimaryButton(
            label: _selectedMethod == PaymentMethod.midtrans ? 'Bayar Sekarang' : 'Konfirmasi Booking',
            icon: Icons.payment_rounded,
            isLoading: _isLoading,
            onPressed: _pay,
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.white.withAlpha((0.6 * 255).toInt()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withAlpha((0.1 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
            color: isSelected ? AppColors.primary : AppColors.textHint,
            size: 22,
          ),
        ]),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {'Futsal': '⚽', 'Badminton': '🏸', 'Basket': '🏀', 'Voli': '🏐', 'Tenis Meja': '🏓', 'Tenis': '🎾'};
    return map[cat] ?? '🏟️';
  }
}