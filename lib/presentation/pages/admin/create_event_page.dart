import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/event/create_event_controller.dart';
import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/gradient_header.dart';

// ---------------------------------------------------------------------------
// Enum internal untuk pola pengulangan Series Event
// ---------------------------------------------------------------------------
enum _RepeatPattern { mingguan, bulanan, custom }

/// Halaman form untuk membuat kegiatan baru.
///
/// Mendukung Single Event (1 sesi) dan Series Event (beberapa sesi
/// berulang dengan pola mingguan, bulanan, atau kustom).
class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _narahubungController = TextEditingController();
  final _jumlahPertemuanController = TextEditingController();

  // State
  EventType? _tipe;
  EventVisibility? _visibilitas;
  _RepeatPattern? _polaPengulangan;

  /// Tanggal kegiatan — digunakan bersama oleh waktu mulai dan waktu selesai.
  DateTime? _tanggal;

  /// Jam mulai sesi.
  TimeOfDay? _jamMulai;

  /// Jam selesai sesi.
  TimeOfDay? _jamSelesai;

  /// Daftar tanggal sesi ter-generate (hanya untuk Series).
  List<DateTime> _generatedSessions = [];

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _narahubungController.dispose();
    _jumlahPertemuanController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Date / Time Helpers
  // ---------------------------------------------------------------------------

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _tanggal = picked;
      _regenerateSessions();
    });
  }

  Future<void> _pickJamMulai() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _jamMulai ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _jamMulai = picked;
      // Reset jam selesai jika sekarang lebih awal dari jam mulai.
      if (_jamSelesai != null) {
        final mulaiMenit = picked.hour * 60 + picked.minute;
        final selesaiMenit = _jamSelesai!.hour * 60 + _jamSelesai!.minute;
        if (selesaiMenit <= mulaiMenit) _jamSelesai = null;
      }
    });
  }

  Future<void> _pickJamSelesai() async {
    final initial = _jamSelesai ??
        (_jamMulai != null
            ? TimeOfDay(
                hour: (_jamMulai!.hour + 1) % 24,
                minute: _jamMulai!.minute,
              )
            : TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) return;
    setState(() => _jamSelesai = picked);
  }

  /// Bangun DateTime penuh dari [_tanggal] + [time].
  DateTime _buildDateTime(TimeOfDay time) => DateTime(
        _tanggal!.year,
        _tanggal!.month,
        _tanggal!.day,
        time.hour,
        time.minute,
      );


  // ---------------------------------------------------------------------------
  // Series Session Generation
  // ---------------------------------------------------------------------------

  void _regenerateSessions() {
    if (_tipe != EventType.series || _tanggal == null) {
      _generatedSessions = [];
      return;
    }

    final raw = int.tryParse(_jumlahPertemuanController.text);
    if (raw == null || raw <= 0) {
      _generatedSessions = [];
      return;
    }

    final count = raw;
    final sessions = <DateTime>[];

    for (int i = 0; i < count; i++) {
      final DateTime next;
      switch (_polaPengulangan) {
        case _RepeatPattern.bulanan:
          final m = _tanggal!.month + i;
          next = DateTime(
            _tanggal!.year + (m - 1) ~/ 12,
            ((m - 1) % 12) + 1,
            _tanggal!.day,
          );
        // Mingguan dan Custom sama-sama pakai interval 7 hari.
        case _RepeatPattern.mingguan:
        case _RepeatPattern.custom:
        case null:
          next = _tanggal!.add(Duration(days: 7 * i));
      }
      sessions.add(next);
    }

    _generatedSessions = sessions;
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _onSimpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_tanggal == null || _jamMulai == null || _jamSelesai == null) {
      _showError('Tanggal dan jam kegiatan wajib diisi');
      return;
    }

    final waktuMulai = _buildDateTime(_jamMulai!);
    final waktuSelesai = _buildDateTime(_jamSelesai!);

    if (!waktuSelesai.isAfter(waktuMulai)) {
      _showError('Jam selesai harus setelah jam mulai');
      return;
    }

    final durasi = waktuSelesai.difference(waktuMulai);

    List<SessionInput> sessions;

    if (_tipe == EventType.single) {
      sessions = [
        SessionInput(
          title: _namaController.text.trim(),
          startTime: waktuMulai,
          endTime: waktuSelesai,
          location: _lokasiController.text.trim(),
        ),
      ];
    } else {
      if (_generatedSessions.isEmpty) {
        _showError('Generate jadwal sesi terlebih dahulu');
        return;
      }
      sessions = _generatedSessions
          .map(
            (tanggalSesi) => SessionInput(
              title: _namaController.text.trim(),
              startTime: tanggalSesi.copyWith(
                hour: _jamMulai!.hour,
                minute: _jamMulai!.minute,
              ),
              endTime: tanggalSesi.copyWith(
                hour: _jamMulai!.hour,
                minute: _jamMulai!.minute,
              ).add(durasi),
              location: _lokasiController.text.trim(),
            ),
          )
          .toList();
    }

    final input = CreateEventInput(
      title: _namaController.text.trim(),
      description: _deskripsiController.text.trim(),
      type: _tipe!,
      visibility: _visibilitas!,
      location: _lokasiController.text.trim(),
      contactPerson: _narahubungController.text.trim(),
      sessions: sessions,
    );

    final errorMsg =
        await ref.read(createEventControllerProvider.notifier).submit(input);

    if (!mounted) return;

    if (errorMsg != null) {
      _showError(errorMsg);
    } else {
      ref.read(createEventControllerProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kegiatan berhasil dibuat')),
      );
      context.pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Formatting Helpers
  // ---------------------------------------------------------------------------

  String _formatTanggal(DateTime dt) {
    final p = (int v) => v.toString().padLeft(2, '0');
    return '${p(dt.day)}/${p(dt.month)}/${dt.year}';
  }

  String _formatJam(TimeOfDay t) {
    final p = (int v) => v.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}';
  }

  String _formatDateShort(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = ref.watch(createEventControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          GradientHeader(
            onBack: () => context.pop(),
            title: 'Tambah Kegiatan',
            subtitle: 'Isi informasi kegiatan baru',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Informasi Kegiatan'),
                    const SizedBox(height: 12),

                    // ── Nama Kegiatan ────────────────────────────────────────
                    CustomInputCard(
                      child: TextFormField(
                        controller: _namaController,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Nama Kegiatan',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Jenis Kegiatan ───────────────────────────────────────
                    CustomInputCard(
                      child: DropdownButtonFormField<EventType>(
                        value: _tipe,
                        isExpanded: true,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Jenis Kegiatan',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        hint: Text(
                          'Jenis Kegiatan',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        items: EventType.values
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  _labelTipe(t),
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _tipe = v;
                          _polaPengulangan = null;
                          _jumlahPertemuanController.clear();
                          _generatedSessions = [];
                        }),
                        validator: (v) => v == null ? 'Wajib dipilih' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Deskripsi ────────────────────────────────────────────
                    CustomInputCard(
                      child: TextFormField(
                        controller: _deskripsiController,
                        maxLines: 3,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Deskripsi Kegiatan',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Waktu Kegiatan ───────────────────────────────────────
                    _SectionLabel(label: 'Waktu Kegiatan'),
                    const SizedBox(height: 12),

                    // Tanggal Kegiatan (shared mulai & selesai)
                    CustomInputCard(
                      child: InkWell(
                        onTap: _pickTanggal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _tanggal != null
                                  ? _formatTanggal(_tanggal!)
                                  : 'Tanggal Kegiatan',
                              style: textTheme.bodyMedium?.copyWith(
                                color: _tanggal != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Jam Mulai & Jam Selesai berdampingan
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputCard(
                            child: InkWell(
                              onTap: _pickJamMulai,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _jamMulai != null
                                        ? _formatJam(_jamMulai!)
                                        : 'Jam Mulai',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _jamMulai != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomInputCard(
                            child: InkWell(
                              onTap: _pickJamSelesai,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _jamSelesai != null
                                        ? _formatJam(_jamSelesai!)
                                        : 'Jam Selesai',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _jamSelesai != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Pengaturan Series ────────────────────────────────────
                    if (_tipe == EventType.series) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Pengaturan Series'),
                      const SizedBox(height: 12),

                      // Pola Pengulangan
                      CustomInputCard(
                        child: DropdownButtonFormField<_RepeatPattern>(
                          value: _polaPengulangan,
                          isExpanded: true,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Pola Pengulangan',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          hint: Text(
                            'Pola Pengulangan',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: _RepeatPattern.mingguan,
                              child: Text('Mingguan'),
                            ),
                            DropdownMenuItem(
                              value: _RepeatPattern.bulanan,
                              child: Text('Bulanan'),
                            ),
                            DropdownMenuItem(
                              value: _RepeatPattern.custom,
                              child: Text('Custom'),
                            ),
                          ],
                          onChanged: (v) => setState(() {
                            _polaPengulangan = v;
                            _jumlahPertemuanController.clear();
                            _generatedSessions = [];
                          }),
                          validator: (v) =>
                              (_tipe == EventType.series && v == null)
                                  ? 'Wajib dipilih'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Jumlah Pertemuan
                      CustomInputCard(
                        child: TextFormField(
                          controller: _jumlahPertemuanController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Jumlah Pertemuan',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onChanged: (_) => setState(_regenerateSessions),
                          validator: (v) {
                            if (_tipe == EventType.series &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Wajib diisi untuk Series';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Jadwal sesi ter-generate
                      if (_generatedSessions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Jadwal Sesi (${_generatedSessions.length} pertemuan)',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _generatedSessions
                              .asMap()
                              .entries
                              .map(
                                (e) => Chip(
                                  label: Text(
                                    '${e.key + 1}. ${_formatDateShort(e.value)}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  backgroundColor:
                                      colorScheme.primaryContainer,
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],

                    const SizedBox(height: 20),

                    // ── Lokasi & Kontak ──────────────────────────────────────
                    _SectionLabel(label: 'Lokasi & Kontak'),
                    const SizedBox(height: 12),

                    // Lokasi
                    CustomInputCard(
                      child: TextFormField(
                        controller: _lokasiController,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Lokasi Pelaksanaan',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Narahubung
                    CustomInputCard(
                      child: TextFormField(
                        controller: _narahubungController,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Narahubung',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Pengaturan ───────────────────────────────────────────
                    _SectionLabel(label: 'Pengaturan'),
                    const SizedBox(height: 12),

                    // Visibilitas
                    CustomInputCard(
                      child: DropdownButtonFormField<EventVisibility>(
                        value: _visibilitas,
                        isExpanded: true,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Visibilitas',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        hint: Text(
                          'Visibilitas',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        items: EventVisibility.values
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  _labelVisibilitas(v),
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _visibilitas = v),
                        validator: (v) => v == null ? 'Wajib dipilih' : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Tombol Simpan ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: isLoading ? null : _onSimpan,
                        style: FilledButton.styleFrom(
                          backgroundColor: KegiatinCustomTheme.appBarTop,
                          disabledBackgroundColor:
                              KegiatinCustomTheme.appBarTop.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Simpan Kegiatan',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Label Helpers
  // ---------------------------------------------------------------------------

  String _labelTipe(EventType t) => switch (t) {
        EventType.single => 'Single Event',
        EventType.series => 'Series Event',
      };

  String _labelVisibilitas(EventVisibility v) => switch (v) {
        EventVisibility.open => 'Terbuka untuk Umum',
        EventVisibility.inviteOnly => 'Undangan Saja',
      };
}

// ---------------------------------------------------------------------------
// Widget Helper
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}
