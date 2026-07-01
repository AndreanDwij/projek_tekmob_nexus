import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';
import 'reward_provider.dart';

class RewardDetailPage extends ConsumerWidget {
  final String rewardId;

  const RewardDetailPage({super.key, required this.rewardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rewardProvider);
    final reward = state.rewards.where((r) => r.id == rewardId).firstOrNull;

    if (reward == null) {
      ref.read(rewardProvider.notifier).loadRewards();
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Reward')),
        body: const LoadingIndicator(),
      );
    }

    final canRedeem = state.userEcoPoint >= reward.pointRequired && !reward.isOutOfStock;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Reward')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward.imageUrl != null)
              CachedNetworkImage(
                imageUrl: reward.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.background,
                  height: 250,
                  child: const LoadingIndicator(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${reward.pointRequired} Eco Point',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        reward.isOutOfStock ? 'Stok habis' : 'Stok: ${reward.stock}',
                        style: TextStyle(
                          fontSize: 14,
                          color: reward.isOutOfStock
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${reward.totalRedeemed} reward telah ditukar',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Poin Anda: ${state.userEcoPoint}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (!canRedeem)
                          Text(
                            state.userEcoPoint < reward.pointRequired
                                ? 'Kurang ${reward.pointRequired - state.userEcoPoint}'
                                : 'Tidak tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              color: canRedeem
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomButton(
                    label: 'Tukar Reward',
                    onPressed: canRedeem
                        ? () async {
                            final error = await ref
                                .read(rewardProvider.notifier)
                                .redeemReward(rewardId);
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reward berhasil ditukar!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        : null,
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
}
