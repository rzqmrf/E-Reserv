import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/field_card.dart';
import 'field_detail_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  List<Field> _all = [];
  bool _loading = true;
  String _query = '';
  bool _availableOnly = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final f = await FieldService.getAll();
      if (mounted)
        setState(() {
          _all = f;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Field> get _filtered => _all.where((f) {
        final q = f.name.toLowerCase().contains(_query.toLowerCase()) ||
            f.category.toLowerCase().contains(_query.toLowerCase());
        final a = !_availableOnly || f.isAvailable;
        return q && a;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Daftar Lapangan'), leading: const BackButton()),
      body: Column(children: [
        // Search + filter
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari lapangan...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textHint, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        })
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Text('Hanya yang tersedia',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Switch.adaptive(
                  value: _availableOnly,
                  onChanged: (v) => setState(() => _availableOnly = v),
                  activeColor: AppColors.primary),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Text('${filtered.length} lapangan ditemukan',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : filtered.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text('Lapangan tidak ditemukan',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('Coba kata kunci lain',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          double maxExtent;

                          if (width < 400) {
                            maxExtent = 400;
                          } else if (width < 600) {
                            maxExtent = 200;
                          } else if (width < 1000) {
                            maxExtent = 220;
                          } else {
                            maxExtent = 240;
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: maxExtent,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => FieldCard(
                              field: filtered[i],
                              onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                      builder: (_) => FieldDetailScreen(
                                          field: filtered[i]))),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}
