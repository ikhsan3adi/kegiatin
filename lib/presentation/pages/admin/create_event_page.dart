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
import 'package:kegiatin/presentation/widgets/dropdown_item_row.dart';
import 'package:kegiatin/presentation/widgets/gradient_header.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

import 'create_event_sessions.dart';

// Enum internal untuk pola pengulangan Series Even
enum _RepeatPattern { mingguan, bulanan, custom }

/// Batas atas jumlah sesi untuk mencegah rendering yang berat.
const int _kMaxSesi = 15;

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

  /// Tanggal kegiatan â€” digunakan bersama oleh waktu mulai dan waktu selesai.
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

  // Date / Time Helpers

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
    final initial =
        _jamSelesai ??
        (_jamMulai != null
            ? TimeOfDay(hour: (_jamMulai!.hour + 1) % 24, minute: _jamMulai!.minute)
            : TimeOfDay.now());
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() => _jamSelesai = picked);
  }

  /// Bangun DateTime penuh dari [_tanggal] + [time].
  DateTime _buildDateTime(TimeOfDay time) =>
      DateTime(_tanggal!.year, _tanggal!.month, _tanggal!.day, time.hour, time.minute);

  // Series Session Generation

  /// Generate ulang daftar sesi berdasarkan pola.
  ///
  /// Untuk mode [_RepeatPattern.custom], tanggal yang sudah diedit user
  /// dipertahankan selama jumlah sesi tidak berubah (hanya sesi baru
  /// yang ditambahkan di akhir dengan interval 7 hari sebagai default).
  void _regenerateSessions() {
    if (_tipe != EventType.series || _tanggal == null) {
      _generatedSessions = [];
      return;
    }

    final rawCount = int.tryParse(_jumlahPertemuanController.text);
    if (rawCount == null || rawCount <= 0) {
      _generatedSessions = [];
      return;
    }

    final count = rawCount.clamp(1, _kMaxSesi);

    if (_polaPengulangan == _RepeatPattern.custom) {
      // Pertahankan tanggal yang sudah diedit. Hanya resize list.
      final prev = List<DateTime>.from(_generatedSessions);
      if (count == prev.length) return; // tidak ada perubahan
      final result = <DateTime>[];
      for (int i = 0; i < count; i++) {
        if (i < prev.length) {
          result.add(prev[i]);
        } else {
          // Sesi baru: pakai interval 7 hari dari tanggal awal sebagai default.
          result.add(_tanggal!.add(Duration(days: 7 * i)));
        }
      }
      _generatedSessions = result;
      return;
    }

    final sessions = <DateTime>[];
    for (int i = 0; i < count; i++) {
      final DateTime next;
      switch (_polaPengulangan) {
        case _RepeatPattern.bulanan:
          final m = _tanggal!.month + i;
          next = DateTime(_tanggal!.year + (m - 1) ~/ 12, ((m - 1) % 12) + 1, _tanggal!.day);
        case _RepeatPattern.mingguan:
        case null:
          next = _tanggal!.add(Duration(days: 7 * i));
        case _RepeatPattern.custom:
          // Ditangani di blok atas; tidak akan masuk ke sini.
          next = _tanggal!.add(Duration(days: 7 * i));
      }
      sessions.add(next);
    }
    _generatedSessions = sessions;
  }

  /// Buka DatePicker untuk mengedit tanggal sesi ke-[index] (mode Custom).
  Future<void> _pickSessionDate(int index) async {
    final current = _generatedSessions[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _generatedSessions = List<DateTime>.from(_generatedSessions)..[index] = picked;
    });
  }

  // Submit

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
              startTime: tanggalSesi.copyWith(hour: _jamMulai!.hour, minute: _jamMulai!.minute),
              endTime: tanggalSesi
                  .copyWith(hour: _jamMulai!.hour, minute: _jamMulai!.minute)
                  .add(durasi),
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

    final errorMsg = await ref.read(createEventControllerProvider.notifier).submit(input);

    if (!mounted) return;

    if (errorMsg != null) {
      _showError(errorMsg);
    } else {
      ref.read(createEventControllerProvider.notifier).reset();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil dibuat')));
      context.pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
      );
  }

  // Formatting Helpers

  String _formatTanggal(DateTime dt) {
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(dt.day)}/${p(dt.month)}/${dt.year}';
  }

  String _formatJam(TimeOfDay t) {
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}';
  }

  String _formatDateShort(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // Build

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
                    const SectionLabel(
                      label: 'Informasi Kegiatan',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    // â”€â”€ Nama Kegiatan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    CustomInputCard(
                      child: TextFormField(
                        controller: _namaController,
                        style: textTheme.bodyMedium,
                        decoration:
                            InputDecoration.collapsed(
                              hintText: 'Nama Kegiatan',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.event_outlined,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 0,
                              ),
                            ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // â”€â”€ Jenis Kegiatan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    CustomInputCard(
                      child: DropdownButtonFormField<EventType>(
                        initialValue: _tipe,
                        isExpanded: true,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
                                child: Builder(
                                  builder: (ctx) {
                                    final cs = Theme.of(ctx).colorScheme;
                                    final tt = Theme.of(ctx).textTheme;
                                    return DropdownItemRow(
                                      icon: t == EventType.single
                                          ? Icons.event_outlined
                                          : Icons.event_repeat_outlined,
                                      iconColor: t == EventType.single ? cs.primary : cs.secondary,
                                      label: _labelTipe(t),
                                      textStyle: tt.bodyMedium,
                                    );
                                  },
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
                        selectedItemBuilder: (ctx) {
                          final tt = Theme.of(ctx).textTheme;
                          final cs = Theme.of(ctx).colorScheme;
                          return EventType.values
                              .map(
                                (t) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: DropdownItemRow(
                                    icon: t == EventType.single
                                        ? Icons.event_outlined
                                        : Icons.event_repeat_outlined,
                                    iconColor: t == EventType.single ? cs.primary : cs.secondary,
                                    label: _labelTipe(t),
                                    textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        validator: (v) => v == null ? 'Wajib dipilih' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // â”€â”€ Deskripsi â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    CustomInputCard(
                      child: TextFormField(
                        controller: _deskripsiController,
                        maxLines: 3,
                        style: textTheme.bodyMedium,
                        decoration:
                            InputDecoration.collapsed(
                              hintText: 'Deskripsi Kegiatan',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ).copyWith(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.notes_rounded,
                                  size: 18,
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 0,
                              ),
                            ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // â”€â”€ Waktu Kegiatan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    const SectionLabel(label: 'Waktu Kegiatan', icon: Icons.schedule_outlined),
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
                              _tanggal != null ? _formatTanggal(_tanggal!) : 'Tanggal Kegiatan',
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
                                    _jamMulai != null ? _formatJam(_jamMulai!) : 'Jam Mulai',
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
                                    _jamSelesai != null ? _formatJam(_jamSelesai!) : 'Jam Selesai',
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

                    // â”€â”€ Pengaturan Series â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (_tipe == EventType.series) ...[
                      const SizedBox(height: 20),
                      const SectionLabel(label: 'Pengaturan Series', icon: Icons.repeat_rounded),
                      const SizedBox(height: 12),

                      // Pola Pengulangan
                      CustomInputCard(
                        child: DropdownButtonFormField<_RepeatPattern>(
                          initialValue: _polaPengulangan,
                          isExpanded: true,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
                          items: [
                            for (final p in _RepeatPattern.values)
                              DropdownMenuItem(
                                value: p,
                                child: Builder(
                                  builder: (ctx) {
                                    final cs = Theme.of(ctx).colorScheme;
                                    final tt = Theme.of(ctx).textTheme;
                                    return DropdownItemRow(
                                      icon: switch (p) {
                                        _RepeatPattern.mingguan =>
                                          Icons.calendar_view_week_outlined,
                                        _RepeatPattern.bulanan => Icons.calendar_month_outlined,
                                        _RepeatPattern.custom => Icons.tune_rounded,
                                      },
                                      iconColor: switch (p) {
                                        _RepeatPattern.mingguan => cs.primary,
                                        _RepeatPattern.bulanan => cs.tertiary,
                                        _RepeatPattern.custom => cs.secondary,
                                      },
                                      label: switch (p) {
                                        _RepeatPattern.mingguan => 'Mingguan',
                                        _RepeatPattern.bulanan => 'Bulanan',
                                        _RepeatPattern.custom => 'Custom',
                                      },
                                      textStyle: tt.bodyMedium,
                                    );
                                  },
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() {
                            _polaPengulangan = v;
                            _jumlahPertemuanController.clear();
                            _generatedSessions = [];
                          }),
                          selectedItemBuilder: (ctx) {
                            final tt = Theme.of(ctx).textTheme;
                            final cs = Theme.of(ctx).colorScheme;
                            return _RepeatPattern.values
                                .map(
                                  (p) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: DropdownItemRow(
                                      icon: switch (p) {
                                        _RepeatPattern.mingguan =>
                                          Icons.calendar_view_week_outlined,
                                        _RepeatPattern.bulanan => Icons.calendar_month_outlined,
                                        _RepeatPattern.custom => Icons.tune_rounded,
                                      },
                                      iconColor: switch (p) {
                                        _RepeatPattern.mingguan => cs.primary,
                                        _RepeatPattern.bulanan => cs.tertiary,
                                        _RepeatPattern.custom => cs.secondary,
                                      },
                                      label: switch (p) {
                                        _RepeatPattern.mingguan => 'Mingguan',
                                        _RepeatPattern.bulanan => 'Bulanan',
                                        _RepeatPattern.custom => 'Custom',
                                      },
                                      textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                                    ),
                                  ),
                                )
                                .toList();
                          },
                          validator: (v) =>
                              (_tipe == EventType.series && v == null) ? 'Wajib dipilih' : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Jumlah Pertemuan
                      CustomInputCard(
                        child: TextFormField(
                          controller: _jumlahPertemuanController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: textTheme.bodyMedium,
                          decoration:
                              InputDecoration.collapsed(
                                hintText: 'Jumlah Pertemuan (maks. $_kMaxSesi)',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ).copyWith(
                                prefixIcon: Icon(
                                  Icons.format_list_numbered_rounded,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 0,
                                ),
                              ),
                          onChanged: (_) => setState(_regenerateSessions),
                          validator: (v) {
                            if (_tipe != EventType.series) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Wajib diisi untuk Series';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0) {
                              return 'Minimal 1 pertemuan';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Jadwal sesi ter-generate
                      if (_generatedSessions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SessionListHeader(
                          count: _generatedSessions.length,
                          isCustom: _polaPengulangan == _RepeatPattern.custom,
                        ),
                        const SizedBox(height: 8),
                        SessionDateGrid(
                          sessions: _generatedSessions,
                          isCustom: _polaPengulangan == _RepeatPattern.custom,
                          onEdit: _pickSessionDate,
                          formatDate: _formatDateShort,
                        ),
                      ],
                    ],

                    const SizedBox(height: 20),

                    // â”€â”€ Lokasi & Kontak â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    const SectionLabel(label: 'Lokasi & Kontak', icon: Icons.place_outlined),
                    const SizedBox(height: 12),

                    // Lokasi
                    CustomInputCard(
                      child: TextFormField(
                        controller: _lokasiController,
                        style: textTheme.bodyMedium,
                        decoration:
                            InputDecoration.collapsed(
                              hintText: 'Lokasi Pelaksanaan',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: colorScheme.tertiary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 0,
                              ),
                            ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Narahubung
                    CustomInputCard(
                      child: TextFormField(
                        controller: _narahubungController,
                        style: textTheme.bodyMedium,
                        decoration:
                            InputDecoration.collapsed(
                              hintText: 'Narahubung',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: colorScheme.secondary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 0,
                              ),
                            ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // â”€â”€ Pengaturan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    const SectionLabel(label: 'Pengaturan', icon: Icons.tune_rounded),
                    const SizedBox(height: 12),

                    // Visibilitas
                    CustomInputCard(
                      child: DropdownButtonFormField<EventVisibility>(
                        initialValue: _visibilitas,
                        isExpanded: true,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
                              (vis) => DropdownMenuItem(
                                value: vis,
                                child: Builder(
                                  builder: (ctx) {
                                    final cs = Theme.of(ctx).colorScheme;
                                    final tt = Theme.of(ctx).textTheme;
                                    return DropdownItemRow(
                                      icon: vis == EventVisibility.open
                                          ? Icons.public_rounded
                                          : Icons.lock_outline_rounded,
                                      iconColor: vis == EventVisibility.open
                                          ? cs.tertiary
                                          : cs.secondary,
                                      label: _labelVisibilitas(vis),
                                      textStyle: tt.bodyMedium,
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _visibilitas = v),
                        selectedItemBuilder: (ctx) {
                          final tt = Theme.of(ctx).textTheme;
                          final cs = Theme.of(ctx).colorScheme;
                          return EventVisibility.values
                              .map(
                                (vis) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: DropdownItemRow(
                                    icon: vis == EventVisibility.open
                                        ? Icons.public_rounded
                                        : Icons.lock_outline_rounded,
                                    iconColor: vis == EventVisibility.open
                                        ? cs.tertiary
                                        : cs.secondary,
                                    label: _labelVisibilitas(vis),
                                    textStyle: tt.bodyMedium?.copyWith(color: cs.onSurface),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        validator: (v) => v == null ? 'Wajib dipilih' : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // â”€â”€ Tombol Simpan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: isLoading ? null : _onSimpan,
                        style: FilledButton.styleFrom(
                          backgroundColor: KegiatinCustomTheme.appBarTop,
                          disabledBackgroundColor: KegiatinCustomTheme.appBarTop.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: KegiatinCustomTheme.onGradient,
                                ),
                              )
                            : Text(
                                'Simpan Kegiatan',
                                style: textTheme.labelLarge?.copyWith(
                                  color: KegiatinCustomTheme.onGradient,
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

  // Label Helpers

  String _labelTipe(EventType t) => switch (t) {
    EventType.single => 'Single Event',
    EventType.series => 'Series Event',
  };

  String _labelVisibilitas(EventVisibility v) => switch (v) {
    EventVisibility.open => 'Terbuka untuk Umum',
    EventVisibility.inviteOnly => 'Undangan Saja',
  };
}
