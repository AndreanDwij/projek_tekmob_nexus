import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../../shared/enums.dart';
import '../auth/auth_provider.dart';
import 'report_model.dart';

class ReportListState {
  final List<ReportModel> reports;
  final ReportCategory? selectedCategory;
  final ReportStatus? selectedStatus;
  final bool isLoading;
  final String? error;

  const ReportListState({
    this.reports = const [],
    this.selectedCategory,
    this.selectedStatus,
    this.isLoading = false,
    this.error,
  });

  ReportListState copyWith({
    List<ReportModel>? reports,
    ReportCategory? selectedCategory,
    ReportStatus? selectedStatus,
    bool? isLoading,
    String? error,
  }) {
    return ReportListState(
      reports: reports ?? this.reports,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<ReportModel> get filteredReports {
    var result = reports;
    if (selectedCategory != null) {
      result = result.where((r) => r.category == selectedCategory).toList();
    }
    if (selectedStatus != null) {
      result = result.where((r) => r.status == selectedStatus).toList();
    }
    return result;
  }
}

class ReportNotifier extends StateNotifier<ReportListState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  ReportNotifier(this._ref) : super(const ReportListState());

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Pengguna tidak ditemukan');
        return;
      }

      final snapshot = await _firebaseService.firestore
          .collection(AppConstants.reportsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final reports = snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat laporan');
    }
  }

  void filterByCategory(ReportCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void filterByStatus(ReportStatus? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void clearFilters() {
    state = state.copyWith(selectedCategory: null, selectedStatus: null);
  }

  Future<String?> createReport({
    required ReportCategory category,
    required String description,
    required List<String> imageUrls,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final report = ReportModel(
        id: '',
        userId: user.uid,
        userName: user.nama,
        category: category,
        status: ReportStatus.pending,
        description: description,
        imageUrls: imageUrls,
        latitude: latitude,
        longitude: longitude,
        address: address,
        ecoPoint: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firebaseService.firestore
          .collection(AppConstants.reportsCollection)
          .add(report.toMap()..remove('id'));

      await _firebaseService.firestore
          .collection(AppConstants.reportsCollection)
          .doc(docRef.id)
          .update({'id': docRef.id});

      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'totalLaporan': FieldValue.increment(1),
        'ecoPoint': FieldValue.increment(AppConstants.reportPoint),
      });

      await loadReports();
      return null;
    } catch (e) {
      return 'Gagal membuat laporan';
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return null;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _firebaseService.storage
          .ref()
          .child('${AppConstants.reportImagesPath}/${user.uid}/$fileName');

      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportListState>((ref) {
  return ReportNotifier(ref);
});
