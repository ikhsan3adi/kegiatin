import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/controllers/event/update_event_controller.dart';
import 'package:kegiatin/presentation/widgets/custom_input_card.dart';
import 'package:kegiatin/presentation/widgets/dropdown_item_row.dart';
import 'package:kegiatin/presentation/widgets/gradient_header.dart';
import 'package:kegiatin/presentation/widgets/section_label.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final String eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  ConsumerState<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _narahubungController;

  EventVisibility? _visibilitas;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _deskripsiController = TextEditingController();
    _lokasiController = TextEditingController();
    _narahubungController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _narahubungController.dispose();
    super.dispose();
  }

  void _initData(WidgetRef ref) {
    if (_initialized) return;
    final state = ref.read(eventDetailControllerProvider(widget.eventId));
    if (state is AsyncData && state.value != null) {
      final event = state.value!;
      _namaController.text = event.title;
      _deskripsiController.text = event.description;
      _lokasiController.text = event.location;
      _narahubungController.text = event.contactPerson;
      _visibilitas = event.visibility;
      _initialized = true;
    }
  }

  Future<void> _onSimpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final colorScheme = Theme.of(context).colorScheme;

    // Tampilkan dialog konfirmasi sebelum menyimpan
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simpan Perubahan?'),
        content: const Text(
          'Pastikan data yang diubah sudah benar. Apakah Anda yakin ingin menyimpan perubahan ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final input = UpdateEventInput(
      title: _namaController.text.trim(),
      description: _deskripsiController.text.trim(),
      visibility: _visibilitas!,
      location: _lokasiController.text.trim(),
      contactPerson: _narahubungController.text.trim(),
    );

    final errorMsg = await ref
        .read(updateEventControllerProvider.notifier)
        .submit(widget.eventId, input);

    if (!mounted) return;

    if (errorMsg != null) {
      _showError(errorMsg);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kegiatan berhasil diperbarui')),
      );
      context.pop(); // Go back
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventDetailControllerProvider(widget.eventId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: state.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Kegiatan tidak ditemukan'));
          }
          // Only init once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initData(ref);
            if (mounted) setState(() {});
          });

          if (!_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildForm();
        },
        error: (error, _) => Center(child: Text('Gagal memuat: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildForm() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoading = ref.watch(updateEventControllerProvider).isLoading;

    return Column(
      children: [
        GradientHeader(
          onBack: () => context.pop(),
          title: 'Edit Kegiatan',
          subtitle: 'Perbarui informasi kegiatan',
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
                  CustomInputCard(
                    child: TextFormField(
                      controller: _namaController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration.collapsed(
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel(label: 'Lokasi & Kontak', icon: Icons.place_outlined),
                  const SizedBox(height: 12),
                  CustomInputCard(
                    child: TextFormField(
                      controller: _lokasiController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration.collapsed(
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomInputCard(
                    child: TextFormField(
                      controller: _narahubungController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration.collapsed(
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel(label: 'Pengaturan', icon: Icons.tune_rounded),
                  const SizedBox(height: 12),
                  CustomInputCard(
                    child: DropdownButtonFormField<EventVisibility>(
                      value: _visibilitas,
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
                                        ? cs.primary
                                        : cs.error,
                                    label: vis == EventVisibility.open
                                        ? 'Publik'
                                        : 'Hanya Undangan',
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
                                      ? cs.primary
                                      : cs.error,
                                  label: vis == EventVisibility.open
                                      ? 'Publik'
                                      : 'Hanya Undangan',
                                  textStyle:
                                      tt.bodyMedium?.copyWith(color: cs.onSurface),
                                ),
                              ),
                            )
                            .toList();
                      },
                      validator: (v) => v == null ? 'Wajib dipilih' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _onSimpan,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
