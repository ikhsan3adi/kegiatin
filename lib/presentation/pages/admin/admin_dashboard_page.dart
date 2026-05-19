import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_stats_controller.dart';
import 'package:kegiatin/presentation/pages/admin/widget/dashboard_card.dart';
import 'package:kegiatin/presentation/widgets/calender_card.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final statsState = ref.watch(eventStatsControllerProvider);
    final eventsState = ref.watch(eventListControllerProvider());

    // Build map of dates to events for calendar
    final eventsByDate = <DateTime, List<Event>>{};
    eventsState.maybeWhen(
      data: (paginatedResult) {
        for (final event in paginatedResult.data) {
          for (final session in event.sessions) {
            final dateKey = DateTime(
              session.startTime.year,
              session.startTime.month,
              session.startTime.day,
            );
            if (eventsByDate.containsKey(dateKey)) {
              eventsByDate[dateKey]!.add(event);
            } else {
              eventsByDate[dateKey] = [event];
            }
          }
        }
      },
      orElse: () {},
    );

    return authState.when(
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
                          Image.asset('assets/LogoKegiaTin 2.png', width: 32, height: 32),
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

            // Calendar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dashboard Admin',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CalendarCard(
              selectedDate: _selectedDate,
              eventsByDate: eventsByDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 24),

            // Dashboard Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Statistik Kegiatan',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            statsState.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    DashboardCard(
                      value: stats.eventsThisWeek.toString(),
                      label: 'Kegiatan\nMinggu Ini',
                      icon: Icons.event,
                      iconColor: colorScheme.primary,
                    ),
                    DashboardCard(
                      value: stats.eventsThisMonth.toString(),
                      label: 'Kegiatan\nBulan Ini',
                      icon: Icons.calendar_month,
                      iconColor: colorScheme.secondary,
                    ),
                    DashboardCard(
                      value: stats.incompleteEvents.toString(),
                      label: 'Kegiatan\nBelum Selesai',
                      icon: Icons.hourglass_empty,
                      iconColor: colorScheme.error,
                    ),
                    DashboardCard(
                      value: stats.totalAttendances.toString(),
                      label: 'Presensi\nEvent',
                      icon: Icons.people,
                      iconColor: colorScheme.tertiary,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Error: $e'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
