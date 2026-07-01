import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../auth/auth_provider.dart';
import 'profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              _buildProfileHeader(user),
              const SizedBox(height: AppSpacing.xl),
              _buildStatsRow(state),
              const SizedBox(height: AppSpacing.xl),
              _buildMenuList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: user?.photoUrl != null
              ? CachedNetworkImageProvider(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null
              ? Text(
                  user?.nama.isNotEmpty == true
                      ? user!.nama[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.nama ?? 'Pengguna',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          label: 'Edit Profil',
          onPressed: () => context.go('/profile/edit'),
          isOutlined: true,
          width: 160,
          height: 40,
        ),
      ],
    );
  }

  Widget _buildStatsRow(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _buildStatItem(Icons.assignment_outlined, 'Laporan', state.totalLaporan),
          _buildStatItem(Icons.event_outlined, 'Event', state.totalEvent),
          _buildStatItem(Icons.cloud_outlined, 'Karbon', state.totalCarbon),
          _buildStatItem(Icons.card_giftcard, 'Tukar', state.totalRedemptions),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: AppElevation.level1,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Column(
      children: [
        _buildMenuItem(Icons.history, 'Riwayat Aktivitas', () => context.go('/report')),
        _buildMenuItem(Icons.card_giftcard, 'Reward Saya', () => context.go('/reward')),
        _buildMenuItem(Icons.leaderboard, 'Peringkat', () => context.go('/leaderboard')),
        _buildMenuItem(Icons.edit, 'Edit Profil', () => context.go('/profile/edit')),
        _buildMenuItem(Icons.notifications, 'Notifikasi', () => context.go('/notifications')),
        _buildMenuItem(Icons.settings, 'Pengaturan', () => context.go('/settings')),
        _buildMenuItem(Icons.help_outline, 'Bantuan', () => context.go('/help')),
        _buildMenuItem(Icons.logout, 'Keluar', () => _showLogoutDialog(), isDanger: true),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap,
      {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? AppColors.danger : AppColors.textPrimary),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? AppColors.danger : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(profileProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
