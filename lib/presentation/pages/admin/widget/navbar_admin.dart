import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_event_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_materi_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_profile_page.dart';

class NavbarAdmin extends ConsumerStatefulWidget {
  const NavbarAdmin({super.key});

  @override
  ConsumerState<NavbarAdmin> createState() => _NavbarAdminState();
}

class _NavbarAdminState extends ConsumerState<NavbarAdmin> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    AdminDashboardPage(),
    AdminEventPage(),
    AdminMateriPage(),
    AdminProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _pages[_selectedIndex],
          // FAB tambah kegiatan — tampil di tab Dashboard (index 0) dan Kegiatan (index 1)
          if (_selectedIndex == 0 || _selectedIndex == 1)
            Positioned(
              right: 24,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'fab_tambah_kegiatan',
                onPressed: () => context.push('/admin/create-event'),
                backgroundColor: KegiatinCustomTheme.appBarBottom,
                foregroundColor: KegiatinCustomTheme.onGradient,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4.0,
                tooltip: 'Tambah Kegiatan',
                child: const Icon(Icons.add, size: 28),
              ),
            ),
        ],
      ),
      // --- Tombol Tengah (Pindai QR) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/scan'),
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
        shape: const CircularNotchedRectangle(), // Membuat efek potongan/lengkungan
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
                    _buildNavItem(Icons.home, 'Dashboard', 0, colorScheme),
                    _buildNavItem(Icons.calendar_month, 'Kegiatan', 1, colorScheme),
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
                    _buildNavItem(Icons.menu_book, 'Materi', 2, colorScheme),
                    _buildNavItem(Icons.person, 'Profil', 3, colorScheme),
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
  Widget _buildNavItem(IconData icon, String label, int index, ColorScheme colorScheme) {
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
