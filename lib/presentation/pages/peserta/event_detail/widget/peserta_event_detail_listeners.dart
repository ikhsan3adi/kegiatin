import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/controllers/rsvp/create_rsvp_controller.dart';

/// Side-effect listener untuk aksi RSVP peserta.
///
/// Menampilkan snackbar sukses atau gagal saat [createRsvpControllerProvider]
/// menghasilkan state baru.
class PesertaEventDetailListeners extends ConsumerWidget {
  const PesertaEventDetailListeners({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(createRsvpControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mendaftar: $err'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        data: (rsvp) {
          if (rsvp != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Berhasil mendaftar ke kegiatan!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      );
    });

    return child;
  }
}
