import 'package:flutter/material.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class PesertaRiwayatPage extends StatelessWidget {
  const PesertaRiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          KegiatinAppBar(
            child: Text(
              'Riwayat',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Belum ada riwayat',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
