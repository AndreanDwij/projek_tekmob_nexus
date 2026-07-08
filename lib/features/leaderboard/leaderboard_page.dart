import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import 'leaderboard_provider.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leaderboardProvider.notifier).loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Leaderboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(leaderboardProvider.notifier).loadLeaderboard(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(LeaderboardState state) {
    if (state.isLoading) {
      return const SkeletonLoading();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(leaderboardProvider.notifier).loadLeaderboard(),
      );
    }

    if (state.topUsers.isEmpty) {
      return const EmptyStateWidget(
        title: 'Belum Ada Data',
        description: 'Belum ada pengguna yang terdaftar.',
        icon: Icons.leaderboard_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildTopThree(state.top3),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Peringkat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...state.rest.asMap().entries.map((entry) {
          final index = entry.key + 4;
          final user = entry.value;
          return _buildRankItem(index, user);
        }),
      ],
    );
  }

  Widget _buildTopThree(List users) {
    if (users.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (users.length > 1) ...[
            Expanded(
              child: _buildPodium(
                rank: 2,
                name: users[1].nama,
                point: users[1].ecoPoint,
                photoUrl: users[1].photoUrl,
                height: 140,
              ),
            ),
          ],
          // First place
          Expanded(
            child: _buildPodium(
              rank: 1,
              name: users[0].nama,
              point: users[0].ecoPoint,
              photoUrl: users[0].photoUrl,
              height: 180,
              isFirst: true,
            ),
          ),
          // Third place
          if (users.length > 2) ...[
            Expanded(
              child: _buildPodium(
                rank: 3,
                name: users[2].nama,
                point: users[2].ecoPoint,
                photoUrl: users[2].photoUrl,
                height: 110,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPodium({
    required int rank,
    required String name,
    required int point,
    String? photoUrl,
    required double height,
    bool isFirst = false,
  }) {
    final medals = ['', '🥇', '🥈', '🥉'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(medals[rank], style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: isFirst ? 24 : 20,
            backgroundImage:
                photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
            child: photoUrl == null
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: isFirst ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$point pt',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: double.infinity,
            height: height - 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isFirst
                    ? [AppColors.warning, AppColors.warning.withOpacity(0.6)]
                    : [AppColors.primary, AppColors.primary.withOpacity(0.4)],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.large),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(int rank, user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: AppElevation.level1,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 18,
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${user.totalLaporan} laporan',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${user.ecoPoint} pt',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}