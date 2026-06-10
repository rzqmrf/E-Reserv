import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
// APP NOTIFICATION SYSTEM
// ═══════════════════════════════════════════════════════════════

enum _NotifType { success, error, warning, info }

class AppNotif {
  // ── Public shortcuts ─────────────────────────────────────────
  static void success(BuildContext context, String message, {String? title}) =>
      _show(context, message: message, title: title ?? 'Berhasil', type: _NotifType.success);

  static void error(BuildContext context, String message, {String? title}) =>
      _show(context, message: message, title: title ?? 'Gagal', type: _NotifType.error);

  static void warning(BuildContext context, String message, {String? title}) =>
      _show(context, message: message, title: title ?? 'Perhatian', type: _NotifType.warning);

  static void info(BuildContext context, String message, {String? title}) =>
      _show(context, message: message, title: title ?? 'Informasi', type: _NotifType.info);

  /// Tampilkan error dari exception — otomatis parse pesannya
  static void exception(BuildContext context, dynamic error, {String? title}) =>
      _show(context,
          message: ErrorParser.parse(error),
          title: title ?? 'Gagal',
          type: _NotifType.error);

  // ── Internal renderer ─────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required String title,
    required _NotifType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: duration,
        content: _NotifContent(
          title: title,
          message: message,
          type: type,
        ),
      ),
    );
  }
}

class _NotifContent extends StatelessWidget {
  final String title;
  final String message;
  final _NotifType type;
  const _NotifContent({required this.title, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cfg.accent.withAlpha((0.25 * 255).toInt()), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: cfg.accent.withAlpha((0.18 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cfg.accent.withAlpha((0.15 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, color: cfg.accent, size: 20),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cfg.accent,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotifConfig _config(_NotifType t) {
    switch (t) {
      case _NotifType.success:
        return const _NotifConfig(
          bg: Color(0xFFF0FDF4),
          accent: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case _NotifType.error:
        return const _NotifConfig(
          bg: Color(0xFFFFF1F2),
          accent: AppColors.error,
          icon: Icons.error_rounded,
        );
      case _NotifType.warning:
        return const _NotifConfig(
          bg: Color(0xFFFFFBEB),
          accent: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case _NotifType.info:
        return const _NotifConfig(
          bg: AppColors.primaryLight,
          accent: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _NotifConfig {
  final Color bg;
  final Color accent;
  final IconData icon;
  const _NotifConfig({required this.bg, required this.accent, required this.icon});
}

// ═══════════════════════════════════════════════════════════════
// ERROR PARSER — Ubah pesan exception mentah → teks ramah
// ═══════════════════════════════════════════════════════════════

class ErrorParser {
  static String parse(dynamic error) {
    String raw = error.toString();

    // Buang prefix "Exception: "
    raw = raw.replaceAll(RegExp(r'^Exception:\s*'), '');

    // Buang prefix "POST/GET/PUT/DELETE /endpoint gagal: "
    raw = raw.replaceAll(RegExp(r'^(POST|GET|PUT|DELETE|PATCH)\s+\S+\s+gagal:\s*'), '');

    // Buang prefix "Exception: " yang mungkin muncul lagi setelah strip
    raw = raw.replaceAll(RegExp(r'^Exception:\s*'), '');

    // Mapping pesan backend → pesan Indonesia yang ramah
    final lc = raw.toLowerCase();

    // ── Auth errors ───────────────────────────────────────────
    if (lc.contains('email atau password salah') ||
        lc.contains('invalid credentials') ||
        lc.contains('these credentials do not match')) {
      return 'Email atau password yang Anda masukkan salah. Silakan coba lagi.';
    }

    if (lc.contains('akses ditolak') || lc.contains('forbidden') || lc.contains('403')) {
      return 'Akses ditolak. Anda tidak memiliki izin untuk melakukan tindakan ini.';
    }

    if (lc.contains('sesi habis') || lc.contains('unauthenticated') || lc.contains('401')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    if (lc.contains('email sudah') ||
        lc.contains('has already been taken') ||
        lc.contains('already been taken')) {
      return 'Email ini sudah terdaftar. Gunakan email lain atau langsung masuk.';
    }

    if (lc.contains('email tidak ditemukan') || lc.contains('not found') && lc.contains('email')) {
      return 'Email tidak ditemukan. Pastikan email yang Anda masukkan sudah terdaftar.';
    }

    if (lc.contains('password') && (lc.contains('minimum') || lc.contains('minimal') || lc.contains('at least'))) {
      return 'Password terlalu pendek. Minimal 6 karakter.';
    }

    if (lc.contains('konfirmasi') || lc.contains('confirmation') || lc.contains('tidak sama')) {
      return 'Konfirmasi password tidak cocok dengan password baru.';
    }

    // ── Network / connection errors ───────────────────────────
    if (lc.contains('socketexception') ||
        lc.contains('connection refused') ||
        lc.contains('failed to connect') ||
        lc.contains('network')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }

    if (lc.contains('timeout') || lc.contains('timed out')) {
      return 'Koneksi timeout. Server terlalu lama merespons, coba lagi.';
    }

    // ── Validation errors ─────────────────────────────────────
    if (lc.contains('validasi gagal') || lc.contains('the given data was invalid')) {
      // Coba ekstrak pesan validasi
      final match = RegExp(r'validasi gagal:\s*(.+)', caseSensitive: false).firstMatch(raw);
      if (match != null) return 'Periksa kembali data Anda: ${match.group(1)}';
      return 'Data yang Anda masukkan tidak valid. Periksa kembali semua field.';
    }

    // ── Booking errors ────────────────────────────────────────
    if (lc.contains('slot') && lc.contains('tidak tersedia') ||
        lc.contains('sudah dipesan') ||
        lc.contains('already booked')) {
      return 'Slot waktu ini sudah tidak tersedia. Pilih jam lain.';
    }

    if (lc.contains('kapasitas penuh') || lc.contains('full capacity') || lc.contains('no capacity')) {
      return 'Kapasitas slot ini sudah penuh. Pilih jam lain.';
    }

    // ── Payment errors ────────────────────────────────────────
    if (lc.contains('midtrans') || lc.contains('snap token') || lc.contains('payment gateway')) {
      return 'Gagal terhubung ke layanan pembayaran. Coba lagi dalam beberapa saat.';
    }

    if (lc.contains('gagal membuka')) {
      return 'Gagal membuka halaman pembayaran. Pastikan browser atau aplikasi tersedia.';
    }

    // ── Server errors ─────────────────────────────────────────
    if (lc.contains('500') || lc.contains('server error') || lc.contains('internal server')) {
      return 'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
    }

    if (lc.contains('terjadi kesalahan')) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }

    // ── Fallback: tampilkan pesan asli tapi dengan format bersih ──
    if (raw.length > 120) {
      return 'Terjadi kesalahan. Silakan coba lagi atau hubungi dukungan.';
    }
    return raw.isNotEmpty ? raw : 'Terjadi kesalahan yang tidak diketahui.';
  }
}


// ─── Section Header ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ])),
      if (trailing != null) trailing!,
    ]);
  }
}

// ─── Primary Button ──────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed != null ? AppTheme.primaryGradient : null,
        color: onPressed == null ? AppColors.textHint.withAlpha((0.3 * 255).toInt()) : null,
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.3 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
              ]),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const InfoRow({super.key, required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const StatusChip({super.key, required this.label, required this.color, required this.bgColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ─── Price Badge ─────────────────────────────────────────────
class PriceBadge extends StatelessWidget {
  final int price;
  const PriceBadge({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
      child: Text('Rp ${_fmt(price)}/jam', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Step Label ──────────────────────────────────────────────
class StepLabel extends StatelessWidget {
  final String number;
  final String label;
  const StepLabel({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.2 * 255).toInt()),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
      ),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2)),
    ]);
  }
}

// ─── Format Price ─────────────────────────────────────────────
String formatPrice(int p) {
  final s = p.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if ((s.length - i) % 3 == 0 && i != 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp ${buf.toString()}';
}

// ─── Format Date ──────────────────────────────────────────────
String formatDate(DateTime d) {
  const days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}

String formatDateShort(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
