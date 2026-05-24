import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/utils/date_formatter.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/event/create_event_controller.dart';
import 'package:kegiatin/presentation/widgets/event_banner_picker.dart';
import 'package:kegiatin/presentation/widgets/gradient_header.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

import 'create_event_types.dart';
import 'widget/event_form_actions.dart';
import 'widget/event_form_header.dart';
import 'widget/event_metadata_fields.dart';
import 'widget/event_series_settings.dart';
import 'widget/event_time_section.dart';
import 'widget/event_type_selector.dart';

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

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _narahubungController = TextEditingController();
  final _jumlahPertemuanController = TextEditingController();

  EventType? _tipe;
  EventVisibility? _visibilitas;
  RepeatPattern? _polaPengulangan;
  String? _bannerImageUrl;
  DateTime? _tanggal;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;
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
  /// Untuk mode [RepeatPattern.custom], tanggal yang sudah diedit user
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

    final count = rawCount.clamp(1, kMaxSesi);

    if (_polaPengulangan == RepeatPattern.custom) {
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
        case RepeatPattern.bulanan:
          final m = _tanggal!.month + i;
          next = DateTime(_tanggal!.year + (m - 1) ~/ 12, ((m - 1) % 12) + 1, _tanggal!.day);
        case RepeatPattern.mingguan:
        case null:
          next = _tanggal!.add(Duration(days: 7 * i));
        case RepeatPattern.custom:
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
      imageUrl: _bannerImageUrl,
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

  // Build

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    EventBannerPicker(
                      currentImageUrl: _bannerImageUrl,
                      onImagePicked: (url) => setState(() => _bannerImageUrl = url),
                      onRemove: () => setState(() => _bannerImageUrl = null),
                    ),
                    const SizedBox(height: 20),
                    const SectionLabel(
                      label: 'Informasi Kegiatan',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    EventFormHeader(
                      namaController: _namaController,
                      deskripsiController: _deskripsiController,
                      typeSelector: EventTypeSelector(
                        value: _tipe,
                        onChanged: (v) => setState(() {
                          _tipe = v;
                          _polaPengulangan = null;
                          _jumlahPertemuanController.clear();
                          _generatedSessions = [];
                        }),
                        labelTipe: _labelTipe,
                      ),
                    ),
                    const SizedBox(height: 20),

                    EventTimeSection(
                      tanggal: _tanggal,
                      jamMulai: _jamMulai,
                      jamSelesai: _jamSelesai,
                      onPickTanggal: _pickTanggal,
                      onPickJamMulai: _pickJamMulai,
                      onPickJamSelesai: _pickJamSelesai,
                    ),

                    if (_tipe == EventType.series)
                      EventSeriesSettings(
                        polaPengulangan: _polaPengulangan,
                        onPolaPengulanganChanged: (v) => setState(() {
                          _polaPengulangan = v;
                          _jumlahPertemuanController.clear();
                          _generatedSessions = [];
                        }),
                        jumlahPertemuanController: _jumlahPertemuanController,
                        onJumlahPertemuanChanged: () => setState(_regenerateSessions),
                        generatedSessions: _generatedSessions,
                        isCustom: _polaPengulangan == RepeatPattern.custom,
                        onEditSession: _pickSessionDate,
                        formatDateShort: DateFormatter.formatDateShort,
                        kMaxSesi: kMaxSesi,
                      ),

                    const SizedBox(height: 20),

                    EventMetadataFields(
                      lokasiController: _lokasiController,
                      narahubungController: _narahubungController,
                      visibilitas: _visibilitas,
                      onVisibilitasChanged: (v) => setState(() => _visibilitas = v),
                      labelVisibilitas: _labelVisibilitas,
                    ),
                    const SizedBox(height: 32),

                    EventFormActions(isLoading: isLoading, onSimpan: _onSimpan),
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

  String _labelTipe(EventType t) => switch (t) {
    EventType.single => 'Single Event',
    EventType.series => 'Series Event',
  };

  String _labelVisibilitas(EventVisibility v) => switch (v) {
    EventVisibility.open => 'Terbuka untuk Umum',
    EventVisibility.inviteOnly => 'Undangan Saja',
  };
}
