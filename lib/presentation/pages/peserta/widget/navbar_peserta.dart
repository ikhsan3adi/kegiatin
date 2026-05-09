import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_dashboard_page.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_event_page.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_profile_page.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_riwayat_page.dart';

class NavbarPeserta extends ConsumerStatefulWidget {
  const NavbarPeserta({super.key});

  @override
  ConsumerState<NavbarPeserta> createState() => _NavbarPesertaState();
}

class _NavbarPesertaState extends ConsumerState<NavbarPeserta> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaPage(),
    AcaraPage(),
    RiwayatPage(),
    PesertaProfilePage(),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.primary,
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withValues(alpha: 0.54),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Acara'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
