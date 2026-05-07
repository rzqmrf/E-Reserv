import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'status_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getProfile();
    if (mounted) setState(() { _user = u; _loading = false; });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
                  child: Column(children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildMenu(),
                    const SizedBox(height: 16),
                    _buildLogout(),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final name = _user?.name ?? 'Pengguna';
    final email = _user?.email ?? '-';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((0.3 * 255).toInt()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _user?.initials ?? 'U',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        if (_user?.phone != null && _user!.phone.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Text(
              _user!.phone,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildMenu() {
    return Container(
      color: AppColors.white,
      child: Column(children: [
        _menuTile(Icons.receipt_long_rounded, 'Riwayat Booking',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen()))),
        _menuDivider(),
        _menuTile(Icons.person_outline_rounded, 'Edit Profil', _showEditProfile),
        _menuDivider(),
        _menuTile(Icons.lock_outline_rounded, 'Ubah Password', _showChangePassword),
        _menuDivider(),
        _menuTile(Icons.info_outline_rounded, 'Tentang Aplikasi', _showAbout),
      ]),
    );
  }

  Widget _menuDivider() => const Divider(height: 1, indent: 72, endIndent: 24);

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
        ]),
      ),
    );
  }

  Widget _buildLogout() {
    return Container(
      color: AppColors.white,
      child: InkWell(
        onTap: _logout,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 16),
            const Text(
              'Keluar dari Akun',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.error),
            ),
          ]),
        ),
      ),
    );
  }

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _user?.name);
    final phoneCtrl = TextEditingController(text: _user?.phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Edit Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 16),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'No. WhatsApp', prefixIcon: Icon(Icons.phone_rounded))),
          const SizedBox(height: 32),
          PrimaryButton(
              label: 'Simpan Perubahan',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppColors.success));
              }),
        ]),
      ),
    );
  }

  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ubah Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password Lama', prefixIcon: Icon(Icons.lock_rounded))),
          const SizedBox(height: 16),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password Baru', prefixIcon: Icon(Icons.lock_rounded))),
          const SizedBox(height: 16),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Konfirmasi Password Baru', prefixIcon: Icon(Icons.lock_rounded))),
          const SizedBox(height: 32),
          PrimaryButton(
              label: 'Update Password',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: AppColors.success));
              }),
        ]),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.sports_soccer_rounded, color: Colors.white, size: 40)),
          const SizedBox(height: 24),
          const Text('E-ReservLap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: const Text('Versi 2.0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
          const SizedBox(height: 20),
          const Text('Aplikasi reservasi lapangan olahraga modern dengan fitur real-time schedule & booking.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
        ]),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          )
        ],
      ),
    );
  }
}
