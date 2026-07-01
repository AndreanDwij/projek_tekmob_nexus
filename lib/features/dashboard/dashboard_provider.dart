import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../report/report_model.dart';
import '../auth/user_model.dart';
import '../auth/auth_provider.dart';

class DashboardState {
  final UserModel? user;
  final int totalReports;
  final int ecoPoint;
  final List<ReportModel> recentReports;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.user,
    this.totalReports = 0,
    this.ecoPoint = 0,
    this.recentReports = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    UserModel? user,
    int? totalReports,
    int? ecoPoint,
    List<ReportModel>? recentReports,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      user: user ?? this.user,
      totalReports: totalReports ?? this.totalReports,
      ecoPoint: ecoPoint ?? this.ecoPoint,
      recentReports: recentReports ?? this.recentReports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  DashboardNotifier(this._ref) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);

      final reportsSnapshot = await _firebaseService.firestore
          .collection(AppConstants.reportsCollection)
          .where('userId', isEqualTo: user?.uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final reports = reportsSnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(
        user: user,
        totalReports: user?.totalLaporan ?? 0,
        ecoPoint: user?.ecoPoint ?? 0,
        recentReports: reports,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat dashboard',
      );
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
