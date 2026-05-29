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
  String _selectedCategory = 'Semua';
  final _searchCtrl = TextEditingController();

  static const List<String> _categories = ['Semua', 'Futsal', 'Badminton', 'Basket', 'Voli', 'Tenis Meja', 'Tenis'];
  
  static const Map<String, String> _categoryEmojis = {
    'Semua': '🌐',
    'Futsal': '⚽',
    'Badminton': '🏸',
    'Basket': '🏀',
    'Voli': '🏐',
    'Tenis Meja': '🏓',
    'Tenis': '🎾',
  };

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final f = await FieldService.getAll();
      if (mounted) setState(() { _all = f; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Field> get _filtered => _all.where((f) {
    final q = f.name.toLowerCase().contains(_query.toLowerCase());
    final c = _selectedCategory == 'Semua' || f.category == _selectedCategory;
    final a = !_availableOnly || f.isAvailable;
    return q && c && a;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Daftar Lapangan'),
        backgroundColor: AppColors.bgPage,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(children: [
            // Search + Filter Card
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Cari nama lapangan...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                            onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category Carousel inside filter card
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (ctx, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      final emoji = _categoryEmojis[cat] ?? '🏟️';

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.primaryGradient : null,
                            color: isSelected ? null : AppColors.bgPage,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Hanya Tampilkan yang Tersedia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const Spacer(),
                  Switch.adaptive(
                    value: _availableOnly, 
                    onChanged: (v) => setState(() => _availableOnly = v), 
                    activeTrackColor: AppColors.primary,
                  ),
                ]),
              ]),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(children: [
                Text(
                  '${filtered.length} lapangan ditemukan',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                ),
              ]),
            ),
            
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filtered.isEmpty
                      ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text('Lapangan tidak ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          SizedBox(height: 4),
                          Text('Coba ganti filter atau kata kunci lain', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ]))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return RefreshIndicator(
                              onRefresh: _load,
                              color: AppColors.primary,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisExtent: 245,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (ctx, i) => FieldCard(
                                  field: filtered[i],
                                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => FieldDetailScreen(field: filtered[i]))),
                                ),
                              ),
                            );
                          }
                        ),
            ),
          ]),
        ),
      ),
    );
  }
}
