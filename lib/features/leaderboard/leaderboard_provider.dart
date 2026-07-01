import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../auth/user_model.dart';

class LeaderboardState {
  final List<UserModel> topUsers;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.topUsers = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<UserModel>? topUsers,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      topUsers: topUsers ?? this.topUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<UserModel> get top3 => topUsers.take(3).toList();
  List<UserModel> get rest => topUsers.skip(3).toList();
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final FirebaseService _firebaseService = FirebaseService();

  LeaderboardNotifier() : super(const LeaderboardState());

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snapshot = await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .orderBy('ecoPoint', descending: true)
          .limit(50)
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(topUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat leaderboard');
    }
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
