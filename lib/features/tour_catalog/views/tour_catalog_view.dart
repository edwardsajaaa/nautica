import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../models/tour_package.dart';
import '../viewmodels/tour_catalog_viewmodel.dart';

/// Halaman Katalog Paket Wisata Tur — desain light, solid color.
class TourCatalogView extends StatefulWidget {
  const TourCatalogView({super.key});

  @override
  State<TourCatalogView> createState() => _TourCatalogViewState();
}

class _TourCatalogViewState extends State<TourCatalogView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TourCatalogViewModel>().loadPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Admin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Search bar
                    Container(
                      width: 240,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.search, color: AppTheme.textHint, size: 20),
                          SizedBox(width: 8),
                          Text('Search...', style: TextStyle(color: AppTheme.textHint, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tab filter
                Row(
                  children: [
                    _FilterChip(label: 'Most Popular', selected: true),
                    const SizedBox(width: 10),
                    _FilterChip(label: 'Best Price', selected: false),
                    const SizedBox(width: 10),
                    _FilterChip(label: 'Diving', selected: false),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showForm(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Paket'),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Grid ──
          Expanded(
            child: Consumer<TourCatalogViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.packages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sailing_outlined, size: 72, color: AppTheme.textHint),
                        const SizedBox(height: 16),
                        const Text('Belum ada paket wisata', style: TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => _showForm(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah Paket Pertama'),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: vm.packages.length,
                    itemBuilder: (context, index) {
                      final pkg = vm.packages[index];
                      return _PackageCard(
                        package: pkg,
                        onTap: () => _showForm(context, package: pkg),
                        onDelete: () => _confirmDelete(context, pkg),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {TourPackage? package}) {
    final titleCtrl = TextEditingController(text: package?.title ?? '');
    final descCtrl = TextEditingController(text: package?.description ?? '');
    final priceCtrl = TextEditingController(
      text: package?.price.toStringAsFixed(0) ?? '',
    );
    final isEditing = package != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Paket' : 'Tambah Paket Baru'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Paket'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (title.isEmpty || desc.isEmpty || price <= 0) return;
              final vm = context.read<TourCatalogViewModel>();
              final p = TourPackage(
                id: package?.id,
                title: title,
                description: desc,
                price: price,
              );
              isEditing ? vm.updatePackage(p) : vm.addPackage(p);
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TourPackage pkg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Paket?'),
        content: Text('Hapus "${pkg.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              context.read<TourCatalogViewModel>().deletePackage(pkg.id!);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Card Paket Wisata ──
class _PackageCard extends StatelessWidget {
  final TourPackage package;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PackageCard({
    required this.package,
    required this.onTap,
    required this.onDelete,
  });

  // Warna solid untuk header card (berputar)
  static const _headerColors = [
    Color(0xFF6C63FF),
    Color(0xFF1E88E5),
    Color(0xFF00897B),
    Color(0xFFE53935),
    Color(0xFFFFA726),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _headerColors[package.id != null ? package.id! % _headerColors.length : 0];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header solid color
            Container(
              height: 110,
              width: double.infinity,
              color: color,
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.sailing, size: 44, color: Colors.white38),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        package.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: AppTheme.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '3-5 Days',
                          style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                        ),
                        const Spacer(),
                        Text(
                          'Rp ${_fmt(package.price)}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final p = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (var i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) b.write('.');
      b.write(p[i]);
    }
    return b.toString();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: selected ? null : Border.all(color: AppTheme.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
