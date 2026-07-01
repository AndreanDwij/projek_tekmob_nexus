import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../auth/auth_provider.dart';
import 'reward_model.dart';

class RewardState {
  final List<RewardModel> rewards;
  final int userEcoPoint;
  final List<RedemptionModel> redemptions;
  final bool isLoading;
  final String? error;

  const RewardState({
    this.rewards = const [],
    this.userEcoPoint = 0,
    this.redemptions = const [],
    this.isLoading = false,
    this.error,
  });

  RewardState copyWith({
    List<RewardModel>? rewards,
    int? userEcoPoint,
    List<RedemptionModel>? redemptions,
    bool? isLoading,
    String? error,
  }) {
    return RewardState(
      rewards: rewards ?? this.rewards,
      userEcoPoint: userEcoPoint ?? this.userEcoPoint,
      redemptions: redemptions ?? this.redemptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RewardNotifier extends StateNotifier<RewardState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  RewardNotifier(this._ref) : super(const RewardState());

  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);

      await Future.wait([
        _loadRewardsList(),
        _loadRedemptions(),
      ]);

      state = state.copyWith(
        userEcoPoint: user?.ecoPoint ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat reward');
    }
  }

  Future<void> _loadRewardsList() async {
    final snapshot = await _firebaseService.firestore
        .collection(AppConstants.rewardsCollection)
        .orderBy('pointRequired', descending: false)
        .get();

    final rewards = snapshot.docs
        .map((doc) => RewardModel.fromMap(doc.data(), doc.id))
        .toList();

    state = state.copyWith(rewards: rewards);
  }

  Future<void> _loadRedemptions() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final snapshot = await _firebaseService.firestore
        .collection(AppConstants.redemptionsCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    final redemptions = snapshot.docs
        .map((doc) => RedemptionModel.fromMap(doc.data(), doc.id))
        .toList();

    state = state.copyWith(redemptions: redemptions);
  }

  Future<String?> redeemReward(String rewardId) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final rewardDoc = await _firebaseService.firestore
          .collection(AppConstants.rewardsCollection)
          .doc(rewardId)
          .get();

      if (!rewardDoc.exists) return 'Reward tidak ditemukan';

      final reward = RewardModel.fromMap(rewardDoc.data()!, rewardDoc.id);

      if (reward.isOutOfStock) return 'Reward sudah habis';
      if (user.ecoPoint < reward.pointRequired) return 'Eco Point tidak mencukupi';

      final redemption = RedemptionModel(
        id: '',
        userId: user.uid,
        rewardId: rewardId,
        rewardName: reward.name,
        pointUsed: reward.pointRequired,
        createdAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection(AppConstants.redemptionsCollection)
          .add(redemption.toMap());

      await _firebaseService.firestore
          .collection(AppConstants.rewardsCollection)
          .doc(rewardId)
          .update({
        'stock': FieldValue.increment(-1),
        'totalRedeemed': FieldValue.increment(1),
      });

      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'ecoPoint': FieldValue.increment(-reward.pointRequired),
      });

      await loadRewards();
      return null;
    } catch (e) {
      return 'Gagal menukar reward';
    }
  }
}

final rewardProvider =
    StateNotifierProvider<RewardNotifier, RewardState>((ref) {
  return RewardNotifier(ref);
});
