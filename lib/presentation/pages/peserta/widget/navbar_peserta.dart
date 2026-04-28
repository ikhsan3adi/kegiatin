import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';

class NavbarPeserta extends ConsumerStatefulWidget {
  const NavbarPeserta({super.key});

  @override
  ConsumerState<NavbarPeserta> createState() => _NavbarPesertaState();
}

class _NavbarPesertaState extends ConsumerState<NavbarPeserta> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);

    // Daftar halaman untuk didemonstrasikan perpindahan tab
    final List<Widget> pages = [
      // Index 0: Beranda (Konten dari PesertaHomePage sebelumnya)
      Center(
        child: authState.when(
          data: (user) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text('Selamat datang, ${user?.displayName ?? '-'}'),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      // Index 1: Acara
      const Center(
        child: Text('Halaman Acara', style: TextStyle(fontSize: 24)),
      ),
      // Index 2: Riwayat
      const Center(
        child: Text('Halaman Riwayat', style: TextStyle(fontSize: 24)),
      ),
      // Index 3: Profil
      const Center(
        child: Text('Halaman Profil', style: TextStyle(fontSize: 24)),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface, // Menggunakan surface color

      body: pages[_selectedIndex],

      // --- Navigasi Bawah ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.primary, // Menggunakan primary color
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withValues(alpha: 0.54),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Acara',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
