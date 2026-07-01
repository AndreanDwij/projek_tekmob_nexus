import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../shared/enums.dart';

class CarbonFootprintModel extends Equatable {
  final String id;
  final String userId;
  final TransportationType transportationType;
  final double distance;
  final double emission;
  final DateTime date;
  final DateTime createdAt;

  const CarbonFootprintModel({
    required this.id,
    required this.userId,
    required this.transportationType,
    required this.distance,
    required this.emission,
    required this.date,
    required this.createdAt,
  });

  factory CarbonFootprintModel.fromMap(Map<String, dynamic> map, String id) {
    return CarbonFootprintModel(
      id: id,
      userId: map['userId'] ?? '',
      transportationType: TransportationType.values.firstWhere(
        (t) => t.name == map['transportationType'],
        orElse: () => TransportationType.motor,
      ),
      distance: (map['distance'] ?? 0.0).toDouble(),
      emission: (map['emission'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transportationType': transportationType.name,
      'distance': distance,
      'emission': emission,
      'date': date,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        transportationType,
        distance,
        emission,
        date,
        createdAt,
      ];
}

class CarbonStats {
  final double totalEmission;
  final double averageEmission;
  final int totalTrips;
  final Map<String, double> emissionsByType;

  const CarbonStats({
    this.totalEmission = 0,
    this.averageEmission = 0,
    this.totalTrips = 0,
    this.emissionsByType = const {},
  });
}
