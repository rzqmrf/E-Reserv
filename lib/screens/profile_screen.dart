import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
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
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthService.getProfile();
      if (mounted) setState(() { _user = user; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildMenuSection(),
                  const SizedBox(height: 16),
                  _buildLogout(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final name = _user?.name ?? 'Pengguna';
    final email = _user?.email ?? '-';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // Avatar
        Container(
          width: 84, height: 84,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Center(
            child: Text(initials,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 14),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        if (_user?.phone != null) ...[
          const SizedBox(height: 2),
          Text(_user!.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ]),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: AppColors.white,
      child: Column(children: [
        _menuTile(
          icon: Icons.receipt_long_outlined,
          label: 'Riwayat Booking',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusScreen())),
        ),
        const Divider(height: 1, indent: 56),
        _menuTile(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profil',
          onTap: () => _showEditProfile(),
        ),
        const Divider(height: 1, indent: 56),
        _menuTile(
          icon: Icons.lock_outline_rounded,
          label: 'Ubah Password',
          onTap: () => _showChangePassword(),
        ),
        const Divider(height: 1, indent: 56),
        _menuTile(
          icon: Icons.info_outline_rounded,
          label: 'Tentang Aplikasi',
          onTap: () => _showAbout(),
        ),
      ]),
    );
  }

  Widget _menuTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 19),
            ),
            const SizedBox(width: 14),
            const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
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
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Edit Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'No. WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined, size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Simpan Perubahan',
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Profil berhasil diperbarui'),
                backgroundColor: AppColors.success,
              ));
            },
          ),
        ]),
      ),
    );
  }

  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ubah Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password Lama',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(height: 14),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password Baru',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(height: 14),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Konfirmasi Password Baru',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textHint)),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Simpan Password',
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Password berhasil diubah'),
                backgroundColor: AppColors.success,
              ));
            },
          ),
        ]),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.sports_soccer_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('E-ReservLap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('v1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Aplikasi reservasi lapangan olahraga mudah & cepat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
