import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';

class NavbarAdmin extends ConsumerStatefulWidget {
  const NavbarAdmin({super.key});

  @override
  ConsumerState<NavbarAdmin> createState() => _NavbarAdminState();
}

class _NavbarAdminState extends ConsumerState<NavbarAdmin> {
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
      // Index 0: Beranda (Konten dari AdminDashboardPage sebelumnya)
      Center(
        child: authState.when(
          data: (user) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Selamat datang, Admin ${user?.displayName ?? '-'}'),
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
      // Index 1: Kegiatan
      const Center(
        child: Text('Halaman Kegiatan', style: TextStyle(fontSize: 24)),
      ),
      // Index 2: Profil
      const Center(
        child: Text('Halaman Profil', style: TextStyle(fontSize: 24)),
      ),
      // Index 3: Pengaturan
      const Center(
        child: Text('Halaman Pengaturan', style: TextStyle(fontSize: 24)),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: pages[_selectedIndex],
      // --- Tombol Tengah (Pindai QR) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi ketika tombol Pindai QR ditekan
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Membuka Kamera QR...')));
        },
        backgroundColor: colorScheme.primaryContainer, // Menggunakan secondary color
        foregroundColor: colorScheme.onPrimaryContainer, // Warna icon FAB
        shape: const CircleBorder(), // Memastikan bentuknya bulat sempurna
        elevation: 4.0,
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),

      // Menempatkan FAB di tengah dan "merapat" ke bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Navigasi Bawah ---
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.primary, // Menggunakan primary color untuk navigasi
        shape:
            const CircularNotchedRectangle(), // Membuat efek potongan/lengkungan
        notchMargin: 8.0, // Jarak antara FAB dan lengkungan navigasi
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 70.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Kelompok menu sebelah kiri
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'Beranda', 0, colorScheme),
                    _buildNavItem(
                      Icons.calendar_month,
                      'Kegiatan',
                      1,
                      colorScheme,
                    ),
                  ],
                ),
              ),
              // Ruang kosong di tengah untuk memberi tempat bagi FloatingActionButton
              const SizedBox(width: 48),
              // Kelompok menu sebelah kanan
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.person, 'Profil', 2, colorScheme),
                    _buildNavItem(Icons.settings, 'Pengaturan', 3, colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembantu (helper) untuk membuat item navigasi agar kode lebih rapi
  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedIndex == index;
    final activeColor = colorScheme.onPrimary;
    final inactiveColor = colorScheme.onPrimary.withValues(alpha: 0.54);

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: isSelected ? 28 : 24, // Membesar sedikit saat aktif
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
