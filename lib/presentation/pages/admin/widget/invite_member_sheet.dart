import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/usecases/rsvp/invite_user_usecase.dart';
import 'package:kegiatin/presentation/controllers/user/search_user_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';

class InviteMemberSheet extends ConsumerStatefulWidget {
  final String eventId;

  const InviteMemberSheet({super.key, required this.eventId});

  @override
  ConsumerState<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends ConsumerState<InviteMemberSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _inviting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchUserControllerProvider.notifier).search(query.trim());
    });
  }

  Future<void> _invite(UserSummary user) async {
    setState(() => _inviting = true);
    final useCase = ref.read(inviteUserUseCaseProvider);
    final result = await useCase(InviteUserParams(eventId: widget.eventId, userId: user.id));
    setState(() => _inviting = false);

    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Anggota berhasil diundang')));
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Undang Anggota',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau NPA',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ref
                    .watch(searchUserControllerProvider)
                    .when(
                      data: (result) {
                        if (result == null || result.data.isEmpty) {
                          return Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Ketik nama untuk mencari anggota'
                                  : 'Anggota tidak ditemukan',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          controller: scrollController,
                          itemCount: result.data.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final user = result.data[i];
                            return _UserCard(
                              user: user,
                              onInvite: _inviting ? null : () => _invite(user),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) =>
                          Center(child: Text('Error: $err', style: textTheme.bodyMedium)),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserSummary user;
  final VoidCallback? onInvite;

  const _UserCard({required this.user, required this.onInvite});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            _initials(user.displayName),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.displayName,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: user.npa != null
            ? Text(
                'NPA ${user.npa}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: FilledButton.tonal(onPressed: onInvite, child: const Text('Undang')),
      ),
    );
  }
}
