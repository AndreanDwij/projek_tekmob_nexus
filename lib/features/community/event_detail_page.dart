import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../auth/auth_provider.dart';
import 'community_provider.dart';

class EventDetailPage extends ConsumerWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityProvider);
    final user = ref.watch(currentUserProvider);
    final event = state.events.where((e) => e.id == eventId).firstOrNull;

    if (event == null) {
      ref.read(communityProvider.notifier).loadData();
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Event')),
        body: const LoadingIndicator(),
      );
    }

    final isJoined = user != null && event.participants.contains(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Event')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              CachedNetworkImage(
                imageUrl: event.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.background,
                  height: 220,
                  child: const LoadingIndicator(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(Icons.calendar_today, _formatDate(event.eventDate)),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(Icons.access_time, _formatTime(event.eventDate)),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(Icons.location_on, event.location),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(Icons.people, '${event.currentParticipants}/${event.maxParticipants} peserta'),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (event.participants.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Peserta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: event.participants.map((id) {
                        return const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  CustomButton(
                    label: isJoined
                        ? 'Bergabung'
                        : (event.isFull ? 'Event Penuh' : 'Gabung Event'),
                    onPressed: (isJoined || event.isFull)
                        ? null
                        : () async {
                            final error = await ref
                                .read(communityProvider.notifier)
                                .joinEvent(eventId);
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          },
                    isOutlined: isJoined,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
