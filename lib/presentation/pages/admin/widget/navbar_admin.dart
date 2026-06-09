import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_event_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_presensi_page.dart';
import 'package:kegiatin/presentation/pages/admin/admin_profile_page.dart';
import 'package:kegiatin/presentation/providers/providers.dart';

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
    AdminPresensiPage(),
    AdminProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      context.push('/admin/scan');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Connectivity().onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none) && mounted) {
          ref.read(syncAttendanceUseCaseProvider)(NoInput.instance);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
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
      // --- Navigasi Bawah ---
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.primary, // Menggunakan primary color untuk navigasi
        child: SizedBox(
          height: 70.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildNavItem(Icons.home, 'Dashboard', 0, colorScheme),
              _buildNavItem(Icons.calendar_month, 'Kegiatan', 1, colorScheme),
              _buildNavItem(Icons.qr_code_scanner, 'Presensi', 2, colorScheme),
              _buildNavItem(Icons.person, 'Profil', 3, colorScheme),
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
