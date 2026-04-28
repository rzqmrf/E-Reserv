import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/field_card.dart';
import 'fields_screen.dart';
import 'field_detail_screen.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Field> _fields = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final f = await FieldService.getAll();
      if (mounted) setState(() { _fields = f; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('E-ReservLap'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Riwayat Booking',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildBanner(user),
            _buildFeatures(),
            _buildFieldsPreview(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildBanner(User? user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 7, color: Color(0xFF90EE90)),
              SizedBox(width: 6),
              Text('Sistem Aktif', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Text(
          user != null ? 'Halo, ${user.name.split(' ').first}! 👋' : 'Selamat Datang!',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text('Reservasi lapangan olahraga mudah & cepat',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldsScreen())),
                icon: const Icon(Icons.stadium_outlined, size: 17),
                label: const Text('Lihat Lapangan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
                icon: const Icon(Icons.receipt_long_outlined, size: 17),
                label: const Text('Riwayat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildFeatures() {
    final features = [
      (Icons.schedule_outlined, 'Cek Jadwal', 'Lihat slot & kapasitas'),
      (Icons.touch_app_outlined, 'Booking Mudah', 'Proses cepat & simpel'),
      (Icons.payment_outlined, 'Bayar Online', 'Via Midtrans'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
        child: SectionHeader(title: 'Fitur Unggulan', subtitle: 'Semua yang Anda butuhkan'),
      ),
      SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: features.length,
          itemBuilder: (_, i) {
            final f = features[i];
            return Container(
              width: 145,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(f.$1, color: AppColors.primary, size: 19),
                ),
                const SizedBox(height: 10),
                Text(f.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(f.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildFieldsPreview() {
    final available = _fields.where((f) => f.isAvailable).length;
    final preview = _fields.take(4).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
        child: SectionHeader(
          title: 'Lapangan Tersedia',
          subtitle: _loading ? 'Memuat...' : '$available lapangan siap',
          trailing: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldsScreen())),
            child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
      if (_loading)
        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)))
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            childAspectRatio: isWide ? 0.85 : 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: preview.length,
          itemBuilder: (ctx, i) => FieldCard(
            field: preview[i],
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => FieldDetailScreen(field: preview[i]))),
          ),
        ),
    ]);
  }
}