import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    } catch (e) {
      if (kDebugMode) print('[HOME ERROR] Gagal memuat lapangan: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('E-ReservLap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: AppColors.bgPage,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildBanner(user),
            const SizedBox(height: 24),
            _buildFeatures(),
            const SizedBox(height: 24),
            _buildFieldsPreview(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildBanner(User? user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Sistem Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Halo, ${user?.name.split(' ').first ?? 'Pengguna'} 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reservasi Lapangan olahraga mudah & cepat',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldsScreen())),
                  icon: const Icon(Icons.apartment_rounded, size: 20),
                  label: const Text('Lihat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  label: const Text('Riwayat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      (Icons.access_time_filled_rounded, 'Cek Jadwal', 'Lihat slot dan Kapasitas'),
      (Icons.touch_app_rounded, 'Booking Mudah', 'Proses cepat & simpel'),
      (Icons.credit_card_rounded, 'Bayar Online', 'Via Midtrans'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur Unggulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Semua yang anda butuhkan',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: features.length,
          itemBuilder: (_, i) {
            final f = features[i];
            return Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(f.$1, color: AppColors.primary, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    f.$2,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    maxLines: 1,
                  ),
                  Text(
                    f.$3,
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                    maxLines: 2,
                  ),
                ],
              ),
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
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 245,
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