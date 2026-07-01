import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/location_service.dart';
import '../../shared/enums.dart';
import '../report/report_model.dart';

class MapState {
  final List<ReportModel> reports;
  final List<ReportModel> filteredReports;
  final ReportCategory? selectedCategory;
  final double? currentLatitude;
  final double? currentLongitude;
  final bool isLoading;
  final String? error;

  const MapState({
    this.reports = const [],
    this.filteredReports = const [],
    this.selectedCategory,
    this.currentLatitude,
    this.currentLongitude,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    List<ReportModel>? reports,
    List<ReportModel>? filteredReports,
    ReportCategory? selectedCategory,
    double? currentLatitude,
    double? currentLongitude,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      reports: reports ?? this.reports,
      filteredReports: filteredReports ?? this.filteredReports,
      selectedCategory: selectedCategory,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();

  MapNotifier() : super(const MapState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    await Future.wait([_loadCurrentLocation(), _loadReports()]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      state = state.copyWith(
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );
    }
  }

  Future<void> _loadReports() async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection(AppConstants.reportsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      final reports = snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(
        reports: reports,
        filteredReports: reports,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal memuat laporan');
    }
  }

  void filterByCategory(ReportCategory? category) {
    state = state.copyWith(selectedCategory: category);

    if (category == null) {
      state = state.copyWith(filteredReports: state.reports);
      return;
    }

    final filtered = state.reports
        .where((report) => report.category == category)
        .toList();
    state = state.copyWith(filteredReports: filtered);
  }

  Future<void> refresh() async {
    await _loadReports();
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
