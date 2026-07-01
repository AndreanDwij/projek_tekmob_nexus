import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import 'reward_provider.dart';

class RewardPage extends ConsumerStatefulWidget {
  const RewardPage({super.key});

  @override
  ConsumerState<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends ConsumerState<RewardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rewardProvider.notifier).loadRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reward')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(rewardProvider.notifier).loadRewards(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RewardState state) {
    if (state.isLoading) {
      return const SkeletonLoading();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(rewardProvider.notifier).loadRewards(),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEcoPointCard(state.userEcoPoint),
          const SizedBox(height: AppSpacing.xl),
          if (state.redemptions.isNotEmpty) ...[
            const Text(
              'Riwayat Penukaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.redemptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final redemption = state.redemptions[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
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
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(height: 4),
                        Text(
                          '-${redemption.pointUsed}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          const Text(
            'Daftar Reward',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.rewards.isEmpty)
            const EmptyStateWidget(
              title: 'Belum Ada Reward',
              description: 'Belum ada reward yang tersedia.',
              icon: Icons.card_giftcard_outlined,
            )
          else
            ...state.rewards.map((reward) => GestureDetector(
                  onTap: () => context.go('/reward/detail/${reward.id}'),
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
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          child: reward.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: reward.imageUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.card_giftcard,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reward.isOutOfStock ? 'Stok habis' : 'Stok: ${reward.stock}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: reward.isOutOfStock
                                      ? AppColors.danger
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${reward.pointRequired} Pt',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildEcoPointCard(int ecoPoint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Colors.white, size: 36),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eco Point Anda',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$ecoPoint Poin',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
