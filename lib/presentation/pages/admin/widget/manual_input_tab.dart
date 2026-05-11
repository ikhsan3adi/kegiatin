import 'package:flutter/material.dart';
import 'package:kegiatin/core/theme/custom.dart';

/// Tab input manual untuk mencatat kehadiran peserta tanpa QR.
///
/// Admin menambah peserta satu per satu melalui dialog input nama.
/// Setiap entri memiliki status kehadiran yang dapat diubah secara mandiri.
class ManualInputTab extends StatefulWidget {
  const ManualInputTab({super.key});

  @override
  State<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends State<ManualInputTab> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Daftar peserta yang ditambahkan admin secara manual.
  /// Awalnya kosong; diisi melalui dialog "Tambah".
  final List<_PesertaEntry> _peserta = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Menghasilkan inisial dari nama (maks 2 karakter).
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  List<_PesertaEntry> get _filtered {
    if (_query.isEmpty) return _peserta;
    final q = _query.toLowerCase();
    return _peserta.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  // ── Dialog tambah peserta ────────────────────────────────────────────────

  Future<void> _showTambahDialog() async {
    final nameController = TextEditingController();
    final npaController = TextEditingController();
    // Tanpa GlobalKey/Form agar tidak crash saat StatefulBuilder rebuild
    var isAnggota = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;

        InputDecoration fieldDeco({required String label, String? hint, IconData? icon}) =>
            InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon) : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
            );

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Tambah Peserta',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              // SingleChildScrollView mencegah overflow saat NPA field muncul
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Nama ──────────────────────────────────────────────
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: fieldDeco(
                        label: 'Nama',
                        hint: 'Contoh: Ahmad Yani',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Pilih status keanggotaan ───────────────────────────
                    // SegmentedButton tidak membuka overlay — aman di dalam dialog
                    Text(
                      'Status Keanggotaan',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Anggota'),
                          icon: Icon(Icons.badge_outlined),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Non-Anggota'),
                          icon: Icon(Icons.person_outline_rounded),
                        ),
                      ],
                      selected: {isAnggota},
                      onSelectionChanged: (sel) {
                        final v = sel.first;
                        setDialogState(() => isAnggota = v);
                        if (!v) npaController.clear();
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colorScheme.primaryContainer,
                        selectedForegroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),

                    // ── NPA (Anggota saja, opsional) ──────────────────────
                    if (isAnggota) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: npaController,
                        keyboardType: TextInputType.number,
                        decoration: fieldDeco(
                          label: 'Nomor NPA (Opsional)',
                          hint: 'Kosongkan jika belum tersedia',
                          icon: Icons.tag_rounded,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: KegiatinCustomTheme.appBarBottom,
                    foregroundColor: KegiatinCustomTheme.onGradient,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Nama tidak boleh kosong'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      setState(() {
        _peserta.add(
          _PesertaEntry(
            name: nameController.text.trim(),
            initials: _initials(nameController.text),
            isAnggota: isAnggota,
            npa: isAnggota ? npaController.text.trim() : null,
          ),
        );
      });
    }

    nameController.dispose();
    npaController.dispose();
  }

  // ── Mark hadir ───────────────────────────────────────────────────────────

  void _toggleMark(_PesertaEntry entry) {
    setState(() => entry.isPresent = !entry.isPresent);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filtered;

    return Column(
      children: [
        // Search bar + tombol tambah
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Input Nama Anggota',
                    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _showTambahDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: FilledButton.styleFrom(
                  backgroundColor: KegiatinCustomTheme.appBarBottom,
                  foregroundColor: KegiatinCustomTheme.onGradient,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ],
          ),
        ),

        // Label jumlah anggota
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _peserta.isEmpty
                  ? 'Belum ada anggota ditambahkan'
                  : 'Anggota Terdaftar: ${_peserta.length}',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),

        // Daftar peserta
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _peserta.isEmpty ? Icons.group_add_outlined : Icons.person_search_outlined,
                        size: 48,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _peserta.isEmpty
                            ? 'Tekan "Tambah" untuk mencatat peserta'
                            : 'Peserta tidak ditemukan',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _PesertaCard(entry: filtered[i], onToggle: () => _toggleMark(filtered[i])),
                ),
        ),
      ],
    );
  }
}

// Model

/// Entri peserta yang ditambahkan secara manual oleh admin.
/// [isPresent] bersifat mutable agar status hadir bisa diubah in-place
/// tanpa mengganggu urutan daftar.
class _PesertaEntry {
  _PesertaEntry({required this.name, required this.initials, required this.isAnggota, this.npa});

  final String name;
  final String initials;
  final bool isAnggota;

  /// Nomor Pokok Anggota; null jika [isAnggota] = false.
  final String? npa;

  bool isPresent = false;
}

// Card

class _PesertaCard extends StatelessWidget {
  const _PesertaCard({required this.entry, required this.onToggle});

  final _PesertaEntry entry;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final marked = entry.isPresent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: marked ? colorScheme.primaryContainer.withValues(alpha: 0.4) : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: marked
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar inisial
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              entry.initials,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama & keterangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.isAnggota
                      ? (entry.npa != null && entry.npa!.isNotEmpty
                            ? 'NPA ${entry.npa}'
                            : 'Anggota')
                      : 'Non-Anggota',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Status hadir / tombol hadir
          if (marked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Hadir',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              onPressed: onToggle,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: const Text('Hadir'),
            ),
        ],
      ),
    );
  }
}
