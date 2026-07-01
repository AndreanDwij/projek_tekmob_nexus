import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../../shared/enums.dart';
import '../auth/auth_provider.dart';
import 'carbon_model.dart';

class CarbonState {
  final List<CarbonFootprintModel> footprints;
  final double totalEmission;
  final bool isLoading;
  final String? error;
  final double? lastCalculatedEmission;

  const CarbonState({
    this.footprints = const [],
    this.totalEmission = 0,
    this.isLoading = false,
    this.error,
    this.lastCalculatedEmission,
  });

  CarbonState copyWith({
    List<CarbonFootprintModel>? footprints,
    double? totalEmission,
    bool? isLoading,
    String? error,
    double? lastCalculatedEmission,
  }) {
    return CarbonState(
      footprints: footprints ?? this.footprints,
      totalEmission: totalEmission ?? this.totalEmission,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCalculatedEmission: lastCalculatedEmission ?? this.lastCalculatedEmission,
    );
  }
}

class CarbonNotifier extends StateNotifier<CarbonState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  CarbonNotifier(this._ref) : super(const CarbonState());

  Future<void> loadFootprints() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final snapshot = await _firebaseService.firestore
          .collection(AppConstants.carbonFootprintsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      final footprints = snapshot.docs
          .map((doc) => CarbonFootprintModel.fromMap(doc.data(), doc.id))
          .toList();

      final total = footprints.fold<double>(
        0,
        (sum, f) => sum + f.emission,
      );

      state = state.copyWith(
        footprints: footprints,
        totalEmission: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data karbon');
    }
  }

  double calculateEmission(TransportationType type, double distance) {
    return type.emissionFactor * distance;
  }

  Future<String?> saveFootprint({
    required TransportationType transportationType,
    required double distance,
  }) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final emission = calculateEmission(transportationType, distance);

      final footprint = CarbonFootprintModel(
        id: '',
        userId: user.uid,
        transportationType: transportationType,
        distance: distance,
        emission: emission,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection(AppConstants.carbonFootprintsCollection)
          .add(footprint.toMap());

      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'totalCarbon': FieldValue.increment(1),
        'ecoPoint': FieldValue.increment(AppConstants.carbonCalculationPoint),
      });

      state = state.copyWith(lastCalculatedEmission: emission);
      await loadFootprints();
      return null;
    } catch (e) {
      return 'Gagal menyimpan data karbon';
    }
  }

  Map<String, double> getEmissionsByType() {
    final map = <String, double>{};
    for (final f in state.footprints) {
      final type = f.transportationType.label;
      map[type] = (map[type] ?? 0) + f.emission;
    }
    return map;
  }
}

final carbonProvider =
    StateNotifierProvider<CarbonNotifier, CarbonState>((ref) {
  return CarbonNotifier(ref);
});
