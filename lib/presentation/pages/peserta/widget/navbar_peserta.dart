import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/event_list_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final eventListState = ref.watch(eventListProvider());

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
                    // Logo + nama app + notifikasi
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
      eventListState.when(
        data: (paginatedEvents) {
          final events = paginatedEvents.data;
          return SingleChildScrollView(
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
                        '${events.length} Kegiatan Tersedia',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (events.isEmpty)
                  Center(
                    child: Text(
                      'Belum ada kegiatan',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.status.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat kegiatan: $err')),
      ),
      // Index 2: Riwayat
      SingleChildScrollView(
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
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      // Index 3: Profil
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
