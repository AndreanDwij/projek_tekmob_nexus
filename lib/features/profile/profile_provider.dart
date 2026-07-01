import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../auth/auth_provider.dart';
import '../auth/user_model.dart';

class ProfileState {
  final UserModel? user;
  final int totalLaporan;
  final int totalEvent;
  final int totalCarbon;
  final int totalRedemptions;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.user,
    this.totalLaporan = 0,
    this.totalEvent = 0,
    this.totalCarbon = 0,
    this.totalRedemptions = 0,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserModel? user,
    int? totalLaporan,
    int? totalEvent,
    int? totalCarbon,
    int? totalRedemptions,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      totalLaporan: totalLaporan ?? this.totalLaporan,
      totalEvent: totalEvent ?? this.totalEvent,
      totalCarbon: totalCarbon ?? this.totalCarbon,
      totalRedemptions: totalRedemptions ?? this.totalRedemptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  ProfileNotifier(this._ref) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return;

      final redemptionsSnapshot = await _firebaseService.firestore
          .collection(AppConstants.redemptionsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      state = state.copyWith(
        user: user,
        totalLaporan: user.totalLaporan,
        totalEvent: user.totalEvent,
        totalCarbon: user.totalCarbon,
        totalRedemptions: redemptionsSnapshot.docs.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat profil');
    }
  }

  Future<String?> updateProfile(Map<String, dynamic> data) async {
    try {
      final userNotifier = _ref.read(authProvider.notifier);
      final error = await userNotifier.updateProfile(data);
      if (error == null) {
        await loadProfile();
      }
      return error;
    } catch (e) {
      return 'Gagal memperbarui profil';
    }
  }

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final userNotifier = _ref.read(authProvider.notifier);
      final error = await userNotifier.uploadPhoto(filePath);
      if (error == null) {
        await loadProfile();
      }
      return error;
    } catch (e) {
      return 'Gagal mengunggah foto';
    }
  }

  Future<void> logout() async {
    await _ref.read(authProvider.notifier).logout();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});
