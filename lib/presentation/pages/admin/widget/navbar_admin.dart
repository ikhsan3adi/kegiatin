import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    final List<Widget> pages = [
      // Index 0: Beranda
      authState.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              KegiatinAppBar(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/LogoKegiaTin 2.png',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'KEGIATIN',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: navigasi ke halaman notifikasi
                          },
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: colorScheme.onPrimary,
                            size: 26,
                          ),
                          tooltip: 'Notifikasi',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat Datang',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? '-',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kegiatan Terkini',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Belum ada kegiatan',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      // Index 1: Kegiatan
      SingleChildScrollView(
        child: Column(
          children: [
            KegiatinAppBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kegiatan',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '0 Kegiatan Tersedia',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Belum ada kegiatan',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      // Index 2: Profil
      SingleChildScrollView(
        child: Column(
          children: [
            KegiatinAppBar(
              child: Text(
                'Profil Saya',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Konten profil',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      // Index 3: Pengaturan
      SingleChildScrollView(
        child: Column(
          children: [
            KegiatinAppBar(
              child: Text(
                'Pengaturan',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Konten pengaturan',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          pages[_selectedIndex],
          // FAB tambah kegiatan — tampil di tab Beranda (index 0) dan Kegiatan (index 1)
          if (_selectedIndex == 0 || _selectedIndex == 1)
            Positioned(
              right: 24,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'fab_tambah_kegiatan',
                onPressed: () => context.push('/admin/create-event'),
                backgroundColor: KegiatinCustomTheme.appBarBottom,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4.0,
                tooltip: 'Tambah Kegiatan',
                child: const Icon(Icons.add, size: 28),
              ),
            ),
        ],
      ),
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
