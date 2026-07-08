import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'community_provider.dart';

class EventTab extends ConsumerStatefulWidget {
  const EventTab({super.key});

  @override
  ConsumerState<EventTab> createState() => _EventTabState();
}

class _EventTabState extends ConsumerState<EventTab> {
  void _showCreateEventSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      builder: (ctx) => const _CreateEventSheet(),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);
    final upcomingEvents = state.events.where((e) => e.isUpcoming).toList();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(communityProvider.notifier).loadData(),
          child: upcomingEvents.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    EmptyStateWidget(
                      title: 'Belum Ada Event',
                      description: 'Belum ada kegiatan lingkungan yang akan datang.',
                      icon: Icons.event_outlined,
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 88),
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    return GestureDetector(
                      onTap: () => context.go('/community/detail/${event.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: AppElevation.level1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.large),
                                child: CachedNetworkImage(
                                  imageUrl: event.imageUrl!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (event.imageUrl != null) const SizedBox(height: AppSpacing.sm),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(event.eventDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${event.currentParticipants}/${event.maxParticipants} Peserta',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (event.isFull)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Penuh',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton(
            heroTag: 'event_fab',
            onPressed: _showCreateEventSheet,
            tooltip: 'Buat Event',
            child: const Icon(Icons.event),
          ),
        ),
      ],
    );
  }
}

class _CreateEventSheet extends ConsumerStatefulWidget {
  const _CreateEventSheet();

  @override
  ConsumerState<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<_CreateEventSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '50');
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Judul event wajib diisi')));
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lokasi wajib diisi')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tanggal & waktu wajib dipilih')));
      return;
    }

    setState(() => _isSubmitting = true);

    final eventDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final eventEndDate = eventDate.add(const Duration(hours: 3));

    final error = await ref.read(communityProvider.notifier).createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          latitude: AppConstants.defaultLatitude,
          longitude: AppConstants.defaultLongitude,
          eventDate: eventDate,
          eventEndDate: eventEndDate,
          maxParticipants: int.tryParse(_maxParticipantsController.text.trim()) ?? 50,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Judul event'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Deskripsi event'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Lokasi'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _maxParticipantsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Maksimal peserta'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(
                      _selectedTime == null ? 'Pilih Waktu' : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CustomButton(label: 'Buat Event', isLoading: _isSubmitting, onPressed: _submit),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}